use std::fs;

use crate::errors::reader_error::ReaderError;

pub struct Sensor {
    pub name: &'static str,
    path: &'static str,
}

impl Sensor {
    pub const fn new(name: &'static str, path: &'static str) -> Self {
        Self { name, path }
    }

    pub fn battery_sensors() -> &'static [Sensor] {
        const BATTERY_SENSORS: &[Sensor] = &[
            Sensor::new("temperature", "/sys/class/thermal/thermal_zone40/temp"),
            Sensor::new("voltage", "/sys/class/power_supply/battery/voltage_now"),
            Sensor::new("current", "/sys/class/power_supply/battery/current_now"),
        ];

        BATTERY_SENSORS
    }

    pub fn cpu_sensors() -> &'static [Sensor] {
        const CPU_SENSORS: &[Sensor] = &[Sensor::new(
            "performance_core",
            "/sys/class/thermal/thermal_zone7/temp",
        )];

        CPU_SENSORS
    }

    pub fn read_sensor(&self) -> Result<f64, ReaderError> {
        let raw_content = fs::read_to_string(self.path)
            .map_err(|e| ReaderError::ReadingError(format!("Error reading sensor: {e}")))?;

        raw_content
            .trim()
            .parse::<f64>()
            .map_err(|e| ReaderError::InvalidValue(format!("Invalid value: {e}")))
    }

    pub fn find_sensor<'a>(sensors: &'a [Sensor], name: &str) -> Result<&'a Sensor, ReaderError> {
        sensors
            .iter()
            .find(|v| v.name == name)
            .ok_or_else(|| ReaderError::SensorNotFound(format!("{name} sensor not found!")))
    }
}
