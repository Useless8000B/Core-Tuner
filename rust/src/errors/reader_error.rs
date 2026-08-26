use core::fmt;

pub enum ReaderError {
    FileNotFound(String),
    SensorNotFound(String),
    PropertyNotFound(String),
    InvalidValue(String),
    ReadingError(String),
    Io(std::io::Error),
}

impl fmt::Display for ReaderError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ReaderError::FileNotFound(e) => write!(f, "File not found: {e}"),
            ReaderError::SensorNotFound(e) => write!(f, "Sensor not found: {e}"),
            ReaderError::PropertyNotFound(e) => write!(f, "Property not found: {e}"),
            ReaderError::InvalidValue(e) => write!(f, "Invalid value: {e}"),
            ReaderError::ReadingError(e) => write!(f, "Reading error: {e}"),
            ReaderError::Io(e) => write!(f, "Io error: {e}"),
        }
    }
}

impl From<ReaderError> for String {
    fn from(error: ReaderError) -> Self {
        error.to_string()
    }
}
