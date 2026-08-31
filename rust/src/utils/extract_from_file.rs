use std::fs;

use crate::errors::reader_error::ReaderError;

pub fn extract_from_label(path: &'static str, label: &'static str) -> Result<f64, ReaderError> {
    let content = fs::read_to_string(path)
        .map_err(|_| ReaderError::ReadingError(format!("{label} at {path}")))?;

    let memory_value = content
        .lines()
        .find_map(|line| {
            if line.starts_with(label) {
                line.split_whitespace()
                    .nth(1)
                    .and_then(|v| v.parse::<f64>().ok())
            } else {
                None
            }
        })
        .ok_or_else(|| ReaderError::ReadingError(label.to_string()))?;

    Ok(memory_value)
}

pub fn extract_from_index(path: &'static str, index: usize) -> Result<f64, ReaderError> {
    let content = fs::read_to_string(path)
        .map_err(|_| ReaderError::ReadingError(format!("{:?}", path)))?;

    let content = content
        .split_whitespace()
        .nth(index)
        .and_then(|value| value.parse::<f64>().ok())
        .ok_or_else(|| ReaderError::ReadingError(format!("{content}")))?;

    Ok(content)
}
