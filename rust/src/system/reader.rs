use crate::models::battery_model::BatteryModel;
use crate::models::ram_model::RamModel;
use crate::models::zram_model::ZramModel;
use crate::system::properties::Property;
use crate::system::sensors::Sensor;
use crate::utils::extract_from_file::{extract_from_index, extract_from_label};

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

    let cpu_temperature = sensors
        .iter()
        .find(|v| v.name == "performance_core")
        .ok_or("Performance core sensor not found")?
        .read_sensor()
        .map_err(|e| format!("Critical error reading sensor: {e}"))?;

    Ok(cpu_temperature / 1000.0)
}

pub fn ram_info() -> Result<RamModel, String> {
    const MEM_INFO: &str = "/proc/meminfo";
    let total = extract_from_label(MEM_INFO, "MemTotal")?;
    let available = extract_from_label(MEM_INFO, "MemAvailable")?;

    Ok(RamModel {
        total: total / 1024.0 / 1024.0,
        used: (total - available) / 1024.0 / 1024.0,
    })
}

pub fn zram_info() -> Result<ZramModel, String> {
    const MM_STAT: &str = "/sys/block/zram0/mm_stat";
    const DISKSIZE: &str = "/sys/block/zram0/disksize";
    let origin = extract_from_index(MM_STAT, 0)?;
    let compressed = extract_from_index(MM_STAT, 1)?;
    let used = extract_from_index(MM_STAT, 2)?;
    let total = extract_from_index(DISKSIZE, 0)?;

    let safe_compression = if compressed >= 1e15 || compressed <= 0.0 {
        used
    } else {
        compressed
    };

    let ratio = if safe_compression > 0.0 {
        origin / safe_compression
    } else {
        1.0
    };

    Ok(ZramModel {
        origin: origin / (1024.0 * 1024.0),
        compressed: used / (1024.0 * 1024.0),
        total: total / (1024.0 * 1024.0 * 1024.0),
        ratio: ratio,
    })
}
