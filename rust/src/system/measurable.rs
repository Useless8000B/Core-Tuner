use std::path::Path;

use crate::errors::reader_error::ReaderError;

pub trait Measurable: Sized {
    fn name(&self) -> &'static str;
    fn path(&self) -> &'static str;

    fn exists(&self) -> bool {
        Path::new(self.path()).exists()
    }

    fn find<'a>(entry: &'a [Self], name: &str) -> Result<&'a Self, ReaderError> {
        entry
            .iter()
            .find(|v| v.name() == name && v.exists())
            .ok_or_else(|| ReaderError::ElementNotFound(format!("{name}")))
    }
}
