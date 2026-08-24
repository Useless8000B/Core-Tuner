use crate::errors::{reader_error::ReaderError, shell_command_error::ShellCommandError};

pub enum WriterError {
    Reader(ReaderError),
    Shell(ShellCommandError),
    InvalidValue
}

impl From<ReaderError> for WriterError {
    fn from(error: ReaderError) -> Self {
        WriterError::Reader(error)
    }
}

impl From<ShellCommandError> for WriterError {
    fn from(error: ShellCommandError) -> Self {
        WriterError::Shell(error)
    }
}