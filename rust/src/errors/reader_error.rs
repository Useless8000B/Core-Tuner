use core::fmt;

pub enum ReaderError {
    FileNotFound(String),
    ElementNotFound(String),
    InvalidValue(String),
    ReadingError(String),
    Io(std::io::Error),
}

impl fmt::Display for ReaderError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ReaderError::FileNotFound(e) => write!(f, "File not found: {e}"),
            ReaderError::ElementNotFound(e) => write!(f, "Element not found: {e}"),
            ReaderError::InvalidValue(e) => write!(f, "Invalid value: {e}"),
            ReaderError::ReadingError(e) => write!(f, "Error reading {e}"),
            ReaderError::Io(e) => write!(f, "Io error: {e}"),
        }
    }
}

impl From<ReaderError> for String {
    fn from(error: ReaderError) -> Self {
        error.to_string()
    }
}
