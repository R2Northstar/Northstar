use parking_lot::Mutex;
use rrplug::{bindings::squirreldatatypes::SQObjectType, prelude::*};
use sqparse::{
    Flavor,
    ast::{
        EnumDefinitionStatement, Program, Statement, StructDefinitionStatement, Type,
        VarDefinitionStatement,
    },
    parse, tokenize,
};
use std::{collections::HashMap, sync::LazyLock};

type SQStructFields = Vec<(String, CompositeSQObjectType)>;
pub type SQStructsMap = HashMap<ScriptContext, HashMap<String, SQStructFields>>;
pub static STRUCT_INFO: LazyLock<Mutex<SQStructsMap>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

pub type SQEnumMap = HashMap<ScriptContext, HashMap<String, HashMap<String, i32>>>;
pub static ENUM_INFO: LazyLock<Mutex<SQEnumMap>> = LazyLock::new(|| Mutex::new(HashMap::new()));

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CompositeSQObjectType {
    Single(SQObjectType),
    Array(Box<CompositeSQObjectType>),
    ArraySized(Box<CompositeSQObjectType>, usize),
    Table(Box<CompositeSQObjectType>, Box<CompositeSQObjectType>),
    Nullable(Box<CompositeSQObjectType>),
    PossibleStructRef(String),
    Struct(Box<str>, SQStructFields),
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TypedType<'a> {
    Enum(String, HashMap<String, i32>),
    Struct(String, SQStructFields),
    FullType(CompositeSQObjectType),
    RefFullType(&'a CompositeSQObjectType),
}

impl TypedType<'_> {
    pub fn sq_name(&self) -> String {
        match self {
            TypedType::Enum(e, _) => e.to_owned(),
            TypedType::Struct(s, _) => s.to_owned(),
            &TypedType::RefFullType(ty) | TypedType::FullType(ty) => ty.sq_name(),
        }
    }

    pub fn is_of(&self, sq_ty: SQObjectType) -> bool {
        match self {
            TypedType::Enum(_, _) => sq_ty == SQObjectType::OT_INTEGER,
            TypedType::Struct(_, _) => sq_ty == SQObjectType::OT_STRUCT,
            &TypedType::RefFullType(ty) | TypedType::FullType(ty) => ty.is_of(sq_ty),
        }
    }
}

impl CompositeSQObjectType {
    pub fn sq_name(&self) -> String {
        match self {
            CompositeSQObjectType::Single(s) => match s {
                SQObjectType::OT_VECTOR => "vector",
                SQObjectType::OT_INTEGER => "int",
                SQObjectType::OT_FLOAT => "float",
                SQObjectType::OT_STRING => "string",
                SQObjectType::OT_ARRAY => "array",
                SQObjectType::OT_ASSET => "string",
                SQObjectType::OT_TABLE => "table",
                SQObjectType::OT_ENTITY => "entity",
                _ => "var",
            }
            .to_string(),
            CompositeSQObjectType::Array(base) => format!("array< {} >", base.sq_name()),
            CompositeSQObjectType::ArraySized(base, size) => format!("{} [{size}]", base.sq_name()),
            CompositeSQObjectType::Table(key, value) => {
                format!("table< {}, {} >", key.sq_name(), value.sq_name())
            }
            CompositeSQObjectType::Nullable(nullable) => "ornull".to_string() + &nullable.sq_name(),
            CompositeSQObjectType::PossibleStructRef(_) => "var".to_string(),
            CompositeSQObjectType::Struct(name, _) => name.to_string(), // don't have it's name :<
        }
    }

    pub fn is_of(&self, sq_ty: SQObjectType) -> bool {
        match self {
            CompositeSQObjectType::Single(ty) => sq_ty == *ty,
            CompositeSQObjectType::Array(_) => sq_ty == SQObjectType::OT_ARRAY,
            CompositeSQObjectType::ArraySized(_, _) => sq_ty == SQObjectType::OT_ARRAY,
            CompositeSQObjectType::Table(_, _) => sq_ty == SQObjectType::OT_TABLE,
            CompositeSQObjectType::Nullable(ty) => {
                sq_ty == SQObjectType::OT_NULL || ty.is_of(sq_ty)
            }
            CompositeSQObjectType::PossibleStructRef(_) => false,
            CompositeSQObjectType::Struct(_, _) => sq_ty == SQObjectType::OT_STRUCT,
        }
    }
}

impl TryFrom<&Type<'_>> for CompositeSQObjectType {
    type Error = String;

    fn try_from(value: &Type) -> Result<Self, Self::Error> {
        fn resolve_plain<'a, 'b: 'a>(ty: &'a Type<'b>) -> Option<&'a sqparse::ast::PlainType<'b>> {
            match ty {
                Type::Plain(plain) => Some(plain),
                _ => None,
            }
        }

        match value {
            Type::Local(_) => Err(format!("local is not a thing in structs : {value:?}")),
            Type::Plain(plain_type) => match plain_type.name.value {
                "bool" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_BOOL)),
                "int" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_INTEGER)),
                "float" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_FLOAT)),
                "string" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_STRING)),
                "asset" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_ASSET)),
                "vector" => Ok(CompositeSQObjectType::Single(SQObjectType::OT_VECTOR)),
                "var" => {
                    Err("variable types are not allowed, only concrete types here:".to_string())
                }
                "entity" => Err("entities cannot be serialized".to_string()),
                ty => Ok(CompositeSQObjectType::PossibleStructRef(ty.to_string())),
            },
            Type::Array(array) => Ok(CompositeSQObjectType::ArraySized(
                Box::new(array.base.as_ref().try_into()?),
                extract_constant(&array.len)?
                    .try_into()
                    .map_err(|_| format!("negative array : {array:?}"))?,
            )),
            Type::Generic(generic) => match resolve_plain(generic.base.as_ref())
                .ok_or_else(|| "unsupported base ty for generic ty".to_string())?
                .name
                .value
            {
                "array" => Ok(CompositeSQObjectType::Array(Box::new(
                    generic.params.last_item.as_ref().try_into()?,
                ))),
                "table" => Ok(CompositeSQObjectType::Table(
                    Box::new(
                        generic
                            .params
                            .items
                            .first()
                            .map(|(ty, _)| ty)
                            .ok_or_else(|| {
                                format!("table must have two generic parameters : {value:?}")
                            })?
                            .try_into()?,
                    ),
                    Box::new(generic.params.last_item.as_ref().try_into()?),
                )),
                _ => Err(format!(
                    "any generic types other than tables and arrays are not supported : {value:?}"
                )),
            },
            Type::FunctionRef(_) => Err(format!("functions refs are not supported : {value:?}")),
            Type::Struct(_) => Err(format!(
                "unregistered structs are not currently supported : {value:?}"
            )),
            Type::Reference(ref_ty) => ref_ty.base.as_ref().try_into(),

            Type::Nullable(nullable) => Ok(CompositeSQObjectType::Nullable(Box::new(
                nullable.base.as_ref().try_into()?,
            ))),
        }
    }
}

pub fn clear_cache(context: ScriptContext) {
    STRUCT_INFO.lock().entry(context).or_default().clear();
    ENUM_INFO.lock().entry(context).or_default().clear();
}

pub fn add_struct<'a>(
    context: ScriptContext,
    struct_def: &'a StructDefinitionStatement<'a>,
) -> Result<(), String> {
    let value = struct_def
        .definition
        .properties
        .iter()
        .map(|field| {
            Ok::<_, String>((
                field.name.value.to_string(),
                (&field.type_)
                    .try_into()
                    .map_err(|err| format!("{}: {err}", struct_def.name.value))?,
            ))
        })
        .collect::<Result<_, _>>()?;
    STRUCT_INFO
        .lock()
        .entry(context)
        .or_default()
        .entry(struct_def.name.value.to_string())
        .insert_entry(value);

    Ok(())
}

// TODO: fix enums
pub fn add_enum<'a>(
    context: ScriptContext,
    r#enum: &'a EnumDefinitionStatement<'a>,
) -> Result<(), String> {
    ENUM_INFO
        .lock()
        .entry(context)
        .or_default()
        .entry(r#enum.name.value.to_string())
        .insert_entry(
            r#enum
                .entries
                .iter()
                .try_fold((Vec::new(), i32::MIN), |(mut acc, mut counter), entry| {
                    // this just doesn't work
                    if let Some(value) = entry.initializer.as_ref().map(|initializer| {
                        extract_constant(&initializer.value).and_then(|i| {
                            i.try_into().map_err(|_| format!("enum is too fat: {i:?}"))
                        })
                    }) {
                        let value =
                            value.map_err(|err| format!("enum {} : {err}", r#enum.name.value))?;
                        if counter == value {
                            Err(format!(
                                "cannot have an enum entry of the value {value} for {}?",
                                r#enum.name.value
                            ))?;
                        } else if counter > value {
                            counter = value;
                        } else {
                            acc.iter_mut()
                                .for_each(|(_, prev_value)| *prev_value -= value - counter);
                            counter = value;
                        }
                    }

                    acc.push((entry.name.value.to_string(), counter));
                    Ok::<_, String>((acc, counter))
                })?
                .0
                .into_iter()
                .collect(),
        );

    Ok(())
}

pub fn seal_structs(context: ScriptContext) -> Vec<(String, Box<str>)> {
    let mut lock = STRUCT_INFO.lock();
    let structs = lock.entry(context).or_default();
    let reference_structs = structs.clone();

    let mut to_remove = Vec::new();
    let mut reasons = Vec::new();
    for (name, fields) in structs.iter_mut() {
        if let Err(source) = seal_struct(fields, &reference_structs) {
            to_remove.push(name.to_owned());
            reasons.push(source);
        }
    }
    for struct_name in to_remove.iter() {
        structs.remove(struct_name);
    }

    to_remove.into_iter().zip(reasons.into_iter()).collect()
}

fn seal_struct(
    fields: &mut SQStructFields,
    structs: &HashMap<String, SQStructFields>,
) -> Result<(), Box<str>> {
    for field in fields {
        seal_field(&mut field.1, structs)?
    }
    Ok(())
}

fn seal_field(
    field: &mut CompositeSQObjectType,
    structs: &HashMap<String, Vec<(String, CompositeSQObjectType)>>,
) -> Result<(), Box<str>> {
    match field {
        CompositeSQObjectType::Single(_) => Ok(()),
        CompositeSQObjectType::Array(ty) => seal_field(ty, structs),
        CompositeSQObjectType::ArraySized(ty, _) => seal_field(ty, structs),
        CompositeSQObjectType::Table(key, value) => {
            seal_field(key, structs).and(seal_field(value, structs))
        }
        CompositeSQObjectType::Nullable(nullable) => seal_field(nullable, structs),
        CompositeSQObjectType::PossibleStructRef(struct_ref)
            if let Some(fields) = structs.get(struct_ref) =>
        {
            let mut fields = fields.clone();
            seal_struct(&mut fields, structs)?;
            *field = CompositeSQObjectType::Struct(Box::from(struct_ref.as_str()), fields);

            Ok(())
        }
        CompositeSQObjectType::PossibleStructRef(name) => Err(Box::from(name.as_str())),
        CompositeSQObjectType::Struct(_, fields) => seal_struct(fields, structs),
    }
}

pub fn get_type(type_name: &String, context: ScriptContext) -> Option<TypedType<'static>> {
    let mut lock = STRUCT_INFO.lock();
    let structs = &*lock.entry(context).or_default();

    if let Ok(tokens) = tokenize(&format!("{type_name} e;"), Flavor::SquirrelRespawn)
        && let Some(sqparse::ast::StatementType::VarDefinition(VarDefinitionStatement {
            ref type_,
            definitions: _,
        })) = parse(&tokens)
            .ok()
            .and_then(|Program { statements }| statements.first().cloned())
            .map(|Statement { ty, semicolon: _ }| ty)
        && let mut ty = type_.try_into().ok()?
        && !matches!(ty, CompositeSQObjectType::PossibleStructRef(_))
    {
        seal_field(&mut ty, structs)
            .inspect_err(|_| {
                log::error!("couldn't seal {type_name}; missing struct reference possibly")
            })
            .ok()?;
        return Some(TypedType::FullType(ty));
    }

    let ty = structs
        .get(type_name)
        .map(|fields| TypedType::Struct(type_name.clone(), fields.clone()))
        .or_else(|| {
            ENUM_INFO
                .lock()
                .entry(context)
                .or_default()
                .get(type_name)
                .map(|fields| TypedType::Enum(type_name.clone(), fields.clone()))
        })?;

    Some(ty)
}

fn extract_constant<'a>(value: &sqparse::ast::Expression<'a>) -> Result<i64, String> {
    match value {
        sqparse::ast::Expression::Literal(literal_expression) => match literal_expression.literal {
            sqparse::token::LiteralToken::Int(value, _) => Ok(value),
            _ => Err(format!(
                "since when did enums have anything but an int? : {value:?}"
            )),
        },
        _ => Err(format!(
            "please I love you but use a constant value for my sanity thanks: {value:?}"
        )),
    }
}
