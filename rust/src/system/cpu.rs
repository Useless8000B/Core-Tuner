use std::fs;

use crate::system::properties::Property;

pub struct Cpu {}

impl Cpu {
    pub fn new() -> Self {
        Cpu {}
    }

    pub fn count_cores() -> Result<u8, String> {
        let properties = Property::cpu_path_properties();

        let entry = properties
            .iter()
            .find(|v| v.name == "cpu_path")
            .ok_or("cpu_path property not found")?;

        let count = fs::read_dir(&entry.path)
            .map_err(|e| format!("Error in {}: {}", entry.path, e))?
            .flatten()
            .filter(|v| {
                let name = v
				.file_name()
				.to_string_lossy()
				.into_owned();

                name
				.starts_with("cpu") && name["cpu".len()..]
				.chars()
				.all(|c| c.is_ascii_digit())
            })
            .count();

        if count == 0 {
            return Err("No CPU cores found".to_string());
        }

        Ok(count.min(255) as u8)
    }
}
