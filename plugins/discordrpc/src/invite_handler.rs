use parking_lot::Mutex;
use std::ffi::{c_char, CStr};

use crate::PLUGIN;

pub static JOIN_HANDLER_FUNCTION: Mutex<JoinHandler> = Mutex::new(default_join_handler);

type JoinHandler = extern "C" fn(*const c_char);

/// C Compatible Result Enum
///
/// fails if the string is non utf-8 or the pointer is null
#[repr(C)]
#[must_use]
pub enum IniviteHandlerResult {
    Ok,
    NullSecret,
    NonUtf8Secret,
}

/// registered as "InviteHandler001"
#[repr(C)]
pub(crate) struct InviteHandler;

#[rrplug::as_interface]
impl InviteHandler {
    pub fn new() -> Self {
        Self
    }

    /// Will always provide a valid null terminated string to the join handler.
    ///
    /// The join handler is called when the discord rpc client joins a party. Has to handled immediately.
    ///
    /// Discord doesn't track who is in the party. Discord only sends the secrets.
    pub fn set_join_handler(&self, handler: JoinHandler) {
        *JOIN_HANDLER_FUNCTION.lock() = handler;
    }

    /// sets a secret for party which will be provided to everyone that joins the party
    pub fn set_secret(&self, secret: *const c_char) -> IniviteHandlerResult {
        if secret.is_null() {
            return IniviteHandlerResult::NullSecret;
        }

        let Some(secret) = unsafe { CStr::from_ptr(secret) }.to_str().ok() else {
            return IniviteHandlerResult::NonUtf8Secret;
        };

        PLUGIN.wait().activity.lock().secrets.join = Some(secret.to_string());
        IniviteHandlerResult::Ok
    }

    /// removes the secret which destroys the party invite
    pub fn clear_secret(&self) {
        let secrets = &mut PLUGIN.wait().activity.lock().secrets;

        secrets.r#match = None;
        secrets.join = None;
        secrets.spectate = None;
    }
}

extern "C" fn default_join_handler(_secret: *const c_char) {}
