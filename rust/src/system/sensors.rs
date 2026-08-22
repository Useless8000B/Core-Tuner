use std::fs;

use crate::{errors::reader_error::ReaderError};

pub struct Sensor {
    pub name: String,
    path: String,
}

impl Sensor {
    pub fn new(name: &str, path: &str) -> Self {
        Sensor {
            name: name.to_string(),
            path: path.to_string(),
        }
    }

    pub fn battery_sensors() -> Vec<Sensor> {
        vec![
            Sensor::new("temperature", "/sys/class/thermal/thermal_zone40/temp"),
            Sensor::new("voltage", "/sys/class/power_supply/battery/voltage_now"),
            Sensor::new("current", "/sys/class/power_supply/battery/current_now"),
        ]
    }

    pub fn cpu_sensors() -> Vec<Sensor> {
        vec![Sensor::new(
            "performance_core",
            "/sys/class/thermal/thermal_zone7/temp",
        )]
    }

    pub fn read_sensor(&self) -> Result<f64, ReaderError> {
        let raw_content = match fs::read_to_string(&self.path) {
            Ok(c) => c,
            Err(_) => return Err(ReaderError::ReadingError(self.name.clone())),
        };

        match raw_content.trim().parse::<f64>() {
            Ok(c) => Ok(c),
            Err(_) => Err(ReaderError::InvalidValue(self.name.clone())),
        }
    }

    pub fn find_sensor<'a>(
        sensors: &'a [Sensor],
        name: &'a str,
    ) -> Result<&'a Sensor, ReaderError> {
        sensors
            .iter()
            .find(|v| v.name == name)
            .ok_or_else(|| ReaderError::SensorNotFound(format!("{name} sensor not found!")))
    }
}
