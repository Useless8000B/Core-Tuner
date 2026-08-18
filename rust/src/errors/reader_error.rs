pub enum ReaderError {
    FileNotFound(String),
    SensorNotFound(String),
    PropertyNotFound(String),
    InvalidValue(String),
    ReadingError(String),
    Io(std::io::Error),
}
