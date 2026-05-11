use std::fs;

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
        .ok_or("level property not found")?
        .read_property()?;

    let current = sensors
        .iter()
        .find(|v| v.name == "current")
        .ok_or("current sensor not found")?
        .read_sensor()?;

    let voltage = sensors
        .iter()
        .find(|v| v.name == "voltage")
        .ok_or("voltage sensor not found")?
        .read_sensor()?;

    let is_charging = properties
        .iter()
        .find(|v| v.name == "is_charging")
        .ok_or("is_charging property not found")?
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

pub fn battery_temperature() -> Result<f64, String> {
    let sensors = Sensor::battery_sensors();

    let temperature = sensors
        .iter()
        .find(|v| v.name == "temperature")
        .ok_or("temperature sensor not found")?
        .read_sensor()?;

    Ok(temperature as f64 / 1000.0)
}

pub fn cpu_temperature() -> Result<f32, String> {
    let sensors = Sensor::cpu_sensors();

    let cpu_temperature = sensors
        .iter()
        .find(|v| v.name == "performance_core")
        .ok_or("performance_core sensor not found")?
        .read_sensor()
        .map_err(|e| format!("Critical error reading sensor: {e}"))?;

    Ok(cpu_temperature / 1000.0)
}

pub fn cpu_frequencies() -> Result<Vec<f64>, String> {
    let mut frequencies: Vec<f64> = Vec::new();

    for i in 0..16 {
        let path = format!("/sys/devices/system/cpu/cpu{i}/cpufreq/scaling_cur_freq");

        if !std::path::Path::new(&path).exists() {
            break;
        }

        if let Ok(content) = fs::read_to_string(&path) {
            let value = content.
                trim()
                .parse::<f64>()
                .map_err(|e| format!("Error parsing value: {e}"))?;

            frequencies.push(value / 1000000.0);
        } else {
            frequencies.push(0.0);
        }
    }

    Ok(frequencies)
}

pub fn cpu_governor() -> Result<String, String> {
    let properties = Property::cpu_properties();

    let governor = properties
        .iter()
        .find(|v| v.name == "governor")
        .ok_or("governor property not found")?
        .read_property()?;

    Ok(governor)
}

pub fn ram_info() -> Result<RamModel, String> {
    let properties = Property::ram_properties();

    let mem_info = properties
        .iter()
        .find(|v| v.name == "mem_info")
        .ok_or("mem_info property not found")?;

    let total = extract_from_label(&mem_info.path, "MemTotal")?;
    let available = extract_from_label(&mem_info.path, "MemAvailable")?;

    Ok(RamModel {
        total: total / (1024.0 * 1024.0),
        used: (total - available) / (1024.0 * 1024.0),
    })
}

pub fn zram_info() -> Result<ZramModel, String> {
    let properties = Property::zram_properties();

    let mm_stat = properties
        .iter()
        .find(|v| v.name == "mm_stat")
        .ok_or("mm_stat property not found")?;

    let disksize = properties
        .iter()
        .find(|v| v.name == "disksize")
        .ok_or("disksize property not found")?;

    let origin = extract_from_index(&mm_stat.path, 0)?;
    let compressed = extract_from_index(&mm_stat.path, 1)?;
    let used = extract_from_index(&mm_stat.path, 2)?;
    let total = extract_from_index(&disksize.path, 0)?;

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
