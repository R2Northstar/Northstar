use rrplug::{high::filesystem, mid::squirrel::SQFunctionContext};
use std::{path::PathBuf, str::FromStr};

pub type WhenContext = SQFunctionContext;

type RsonScriptsBlock = (WhenContext, Vec<PathBuf>);

#[derive(Debug)]
pub struct Rson(pub Vec<RsonScriptsBlock>);

impl FromStr for Rson {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        // remove comments
        // comments will on even "splits" and will only run until the next new line
        let no_comments = s.split("//").enumerate().fold(
            String::with_capacity(s.len()),
            |mut acc, (i, split_comments)| {
                if i.is_multiple_of(2) {
                    acc += split_comments
                        .split_once('\n')
                        .map(|(_comment, useful)| useful)
                        .unwrap_or_default();
                } else {
                    acc += split_comments;
                }
                acc
            },
        );

        Ok(Rson(
            no_comments
                .split("When:")
                .filter_map(|context_scripts| context_scripts.trim().split_once("Scripts:"))
                .filter_map(|(context, scripts)| {
                    Some((
                        parse_context(context.trim())?,
                        parse_scripts(scripts.trim())?,
                    ))
                })
                .collect(),
        ))
    }
}

fn parse_scripts(scripts: &str) -> Option<Vec<PathBuf>> {
    Some(
        scripts
            .strip_prefix('[')?
            .strip_suffix(']')?
            .lines()
            .filter(|path| !path.is_empty())
            .map(|path| path.trim())
            .filter_map(|path| {
                Some(
                    PathBuf::new().join("scripts").join("vscripts").join(
                        PathBuf::from_str(
                            &path.strip_prefix('\\').unwrap_or(path).replace('/', "\\"),
                        )
                        .ok()?,
                    ),
                )
            })
            .collect(),
    )
}

#[allow(clippy::obfuscated_if_else)]
fn parse_context(context: &str) -> Option<WhenContext> {
    let context = context.strip_prefix('"')?.strip_suffix('"')?;
    Some(
        context
            .contains("SERVER")
            .then_some(WhenContext::SERVER)
            .unwrap_or(WhenContext::empty())
            | context
                .contains("CLIENT")
                .then_some(WhenContext::CLIENT)
                .unwrap_or(WhenContext::empty())
            | context
                .contains("UI")
                .then_some(WhenContext::UI)
                .unwrap_or(WhenContext::empty()),
    )
}

pub fn load_rson_string() -> Option<String> {
    filesystem::open(&PathBuf::from("scripts/vscripts/scripts.rson"))
        .ok()
        .as_ref()
        .map(ToString::to_string)
}

pub fn load_rson() -> Option<Rson> {
    Rson::from_str(&load_rson_string()?).ok()
}

// one day maybe
// use nom::{
//     branch::alt,
//     bytes::complete::{is_a, is_not, tag, take_while},
//     character::complete::{alpha1, char, digit1, multispace0, multispace1, one_of},
//     combinator::{cut, iterator, map, map_res, opt},
//     error::{context, ErrorKind, ParseError},
//     multi::{many, separated_list0, separated_list1},
//     sequence::{self, delimited, pair, preceded, terminated},
//     AsChar, IResult, Parser,
// };
// use nom_language::error::VerboseError;
// use rrplug::{high::filesystem, mid::squirrel::SQFunctionContext};
// use std::{path::PathBuf, str::FromStr};

// pub type WhenContext = SQFunctionContext;

// type RsonScriptsBlock = (WhenContext, Vec<PathBuf>);

// #[derive(Debug)]
// pub struct Rson(pub Vec<RsonScriptsBlock>);

// fn parse_rson(i: &str) -> IResult<&str, RsonScriptsBlock, VerboseError<&str>> {
//     let context = preceded(
//         preceded(
//             tag::<_, _, VerboseError<&str>>("When:"),
//             is_a::<_, _, VerboseError<&str>>(" "),
//         ),
//         map_res(
//             delimited(
//                 tag("\""),
//                 alt((is_a("SERVER"), is_a("CLIENT"), is_a("UI"), is_not("\""))),
//                 char('"'),
//             ),
//             context_parser,
//         ),
//     );

//     let scripts = preceded::<_, _, _, _, _>(
//         preceded(tag::<_, _, VerboseError<&str>>("Scripts:"), multispace0),
//         map_res(
//             separated_list1(
//                 tag("\n"),
//                 preceded::<_, _, VerboseError<&str>, _, _>(multispace0, is_path),
//             ),
//             |i| {
//                 i.iter()
//                     .map(|path| PathBuf::from_str(path))
//                     .collect::<Result<Vec<_>, _>>()
//             },
//         ),
//     );

//     pair(context, scripts).parse(i)
// }

// fn is_path<'a, E: ParseError<&'a str>>(i: &'a str) -> IResult<&'a str, &'a str, E> {
//     take_while(|c: char| !c.is_newline())(i)
// }

// #[allow(clippy::obfuscated_if_else)]
// fn context_parser(vm: &str) -> Result<SQFunctionContext, VerboseError<&str>> {
//     Ok(vm
//         .contains("SERVER")
//         .then_some(WhenContext::SERVER)
//         .unwrap_or(WhenContext::empty())
//         | vm.contains("CLIENT")
//             .then_some(WhenContext::CLIENT)
//             .unwrap_or(WhenContext::empty())
//         | vm.contains("UI")
//             .then_some(WhenContext::UI)
//             .unwrap_or(WhenContext::empty()))
// }

// impl FromStr for Rson {
//     type Err = ();

//     fn from_str(s: &str) -> Result<Self, Self::Err> {
//         Ok(Rson(iterator(s, parse_rson).by_ref().collect::<Vec<_>>()))
//     }
// }
