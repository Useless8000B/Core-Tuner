use crate::models::battery_model::BatteryModel;
use crate::system::properties::Property;
use crate::system::sensors::Sensor;

pub fn battery_info() -> Result<BatteryModel, String> {
    let sensors = Sensor::battery_sensors();
    let properties = Property::battery_properties();

    let raw_level = properties
        .iter()
        .find(|v| v.name == "level")
        .ok_or("Level property not found")?
        .read_property()?;

    let current = sensors
		.iter()
		.find(|v| v.name == "current")
		.ok_or("Current sensor not found")?
		.read_sensor()?;

    let voltage = sensors
        .iter()
        .find(|v| v.name == "voltage")
        .ok_or("Voltage sensor not found")?
        .read_sensor()?;

    let is_charging = properties
        .iter()
        .find(|v| v.name == "is_charging")
        .ok_or("Is_charging property not found")?
        .read_property()?;

    let is_charging = is_charging == "Charging";

    Ok(BatteryModel {
        level: raw_level
            .parse::<u8>()
            .map_err(|e| format!("Couldn't parse battery level: {e}"))?,
        current: current / 1000.0,
        is_charging: is_charging,
        voltage: voltage / 1000000.0,
    })
}

pub fn cpu_temperature() -> Result<f32, String> {
    let sensors = Sensor::cpu_sensors();

    let cpu_temperature  = sensors
        .iter()
        .find(|v| v.name == "performance_core")
        .ok_or("Performance core sensor not found")?
        .read_sensor()
        .map_err(|e| format!("Critical error reading sensor: {e}"))?;

    Ok(cpu_temperature / 1000.0)
}
