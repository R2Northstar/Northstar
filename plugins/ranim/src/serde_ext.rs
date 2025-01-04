use rrplug::{mid::utils::str_from_char_ptr, prelude::*};
use serde::{
    de::{SeqAccess, Visitor},
    ser::SerializeTuple,
    Deserialize, Deserializer, Serialize, Serializer,
};
use std::{fmt, marker::PhantomData, mem::MaybeUninit, ops::Not};

use crate::recording_impl::into_c_str;

pub fn serialize_arr<const N: usize, S, T>(t: &[T; N], serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
    T: Serialize,
{
    let mut ser_tuple = serializer.serialize_tuple(N)?;
    for elem in t {
        ser_tuple.serialize_element(elem)?;
    }
    ser_tuple.end()
}

pub fn deserialize_arr<'de, const N: usize, D, T>(deserialize: D) -> Result<[T; N], D::Error>
where
    D: Deserializer<'de>,
    T: Deserialize<'de>,
{
    struct TupleVisitor<const N: usize, TI> {
        marker: PhantomData<TI>,
    }

    impl<'de, const N: usize, TI> Visitor<'de> for TupleVisitor<N, TI>
    where
        TI: Deserialize<'de>,
    {
        type Value = [TI; N];

        fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
            formatter.write_fmt(format_args!("an array of size {}", N))
        }

        #[inline]
        fn visit_seq<A>(self, mut seq: A) -> Result<Self::Value, A::Error>
        where
            A: SeqAccess<'de>,
        {
            let mut arr = std::array::from_fn::<_, N, _>(|_| MaybeUninit::<TI>::uninit());

            for (i, elm) in arr.iter_mut().enumerate() {
                elm.write(
                    seq.next_element()?
                        .ok_or_else(|| serde::de::Error::invalid_length(i, &self))?,
                );
            }

            Ok(arr.map(|value| unsafe { value.assume_init() }))
        }
    }

    deserialize.deserialize_tuple(
        N,
        TupleVisitor::<N, T> {
            marker: PhantomData,
        },
    )
}

pub fn serialize_vector3<S>(vector: &Vector3, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serialize_arr(&[vector.x, vector.y, vector.z], serializer)
}

pub fn deserialize_vector3<'de, D>(deserialize: D) -> Result<Vector3, D::Error>
where
    D: Deserializer<'de>,
{
    Ok(Vector3::from(deserialize_arr::<3, _, _>(deserialize)?))
}

pub fn serialize_cstr_array<const N: usize, S>(
    arr: &[*const i8; N],
    serializer: S,
) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serialize_arr(
        &arr.map(|ptr| unsafe { ptr.as_ref() }).map(|ptr| {
            ptr.map(|ptr| unsafe { str_from_char_ptr(ptr).expect("sequences should be valid") })
                .unwrap_or("")
        }),
        serializer,
    )
}

pub fn deserialize_cstr_array<'de, const N: usize, D>(
    deserialize: D,
) -> Result<[*const i8; N], D::Error>
where
    D: Deserializer<'de>,
{
    Ok(deserialize_arr::<N, _, String>(deserialize)?.map(|str| {
        str.is_empty()
            .not()
            .then(|| unsafe { into_c_str(str).cast::<i8>().cast_const() })
            .unwrap_or(std::ptr::null())
    }))
}
