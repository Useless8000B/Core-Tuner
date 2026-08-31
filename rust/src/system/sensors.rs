use std::fs;

use crate::{errors::reader_error::ReaderError, system::measurable::Measurable};

pub struct Sensor {
    pub name: &'static str,
    path: &'static str,
}

impl Measurable for Sensor {
    fn name(&self) -> &'static str {
        self.name
    }

    fn path(&self) -> &'static str {
        self.path
    }
}

impl Sensor {
    const fn new(name: &'static str, path: &'static str) -> Self {
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
}

