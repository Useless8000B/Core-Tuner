use std::fs;
use sysinfo::Disks;

use crate::errors::reader_error::ReaderError;
use crate::models::battery::Battery;
use crate::models::ram::Ram;
use crate::models::storage::Storage;
use crate::models::zram::Zram;
use crate::system::properties::Property;
use crate::system::sensors::Sensor;
use crate::utils::extract_from_file::{extract_from_index, extract_from_label};

pub fn battery_info() -> Result<Battery, ReaderError> {
    let sensors = Sensor::battery_sensors();
    let properties = Property::battery_properties();

    let mut level = None;
    let mut current = None;
    let mut voltage = None;
    let mut is_charging = None;

    for property in properties {
        match property.name.as_str() {
            "level" => level = Some(property),
            "is_charging" => is_charging = Some(property),
            _ => {}
        }
    }

    for sensor in sensors {
        match sensor.name.as_str() {
            "current" => current = Some(sensor),
            "voltage" => voltage = Some(sensor),
            _ => {}
        }
    }

    let level = level
        .ok_or_else(|| ReaderError::PropertyNotFound("LEVEL property not found".to_string()))?
        .read_property()?;

    let current = current
        .ok_or_else(|| ReaderError::SensorNotFound("".to_string()))?
        .read_sensor()?;

    let is_charging = is_charging
        .ok_or_else(|| {
            ReaderError::PropertyNotFound("IS_CHARGING property not found!".to_string())
        })?
        .read_property()?;

    let is_charging = is_charging == "Charging";

    let voltage = voltage
        .ok_or_else(|| ReaderError::SensorNotFound("VOLTAGE sensor not found!".to_string()))?
        .read_sensor()?;

    Ok(Battery {
        level: level
            .parse::<u8>()
            .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?,
        current: current / 1000.0,
        is_charging,
        voltage: voltage / 1000000.0,
    })
}

pub fn battery_temperature() -> Result<f64, ReaderError> {
    let sensors = Sensor::battery_sensors();

    let temperature = sensors
        .iter()
        .find(|v| v.name == "temperature")
        .ok_or_else(|| ReaderError::SensorNotFound("TEMPERATURE sensor not found".to_string()))?
        .read_sensor()?;

    Ok(temperature as f64 / 1000.0)
}

pub fn cpu_temperature() -> Result<f32, ReaderError> {
    let sensors = Sensor::cpu_sensors();

    let cpu_temperature = sensors
        .iter()
        .find(|v| v.name == "performance_core")
        .ok_or_else(|| {
            ReaderError::SensorNotFound("PERFORMANCE_CORE sensor not found".to_string())
        })?
        .read_sensor()?;

    Ok(cpu_temperature / 1000.0)
}

pub fn cpu_frequencies() -> Result<Vec<f64>, ReaderError> {
    let mut frequencies: Vec<f64> = Vec::new();

    for i in 0..16 {
        let path = format!("/sys/devices/system/cpu/cpu{i}/cpufreq/scaling_cur_freq");

        if !std::path::Path::new(&path).exists() {
            break;
        }

        if let Ok(content) = fs::read_to_string(&path) {
            let value = content
                .trim()
                .parse::<f64>()
                .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

            frequencies.push(value / 1000000.0);
        } else {
            frequencies.push(0.0);
        }
    }

    Ok(frequencies)
}

pub fn cpu_governor() -> Result<String, ReaderError> {
    let properties = Property::cpu_path_properties();

    let governor = properties
        .iter()
        .find(|v| v.name == "governor")
        .ok_or_else(|| ReaderError::PropertyNotFound("GOVERNOR property not found".to_string()))?
        .read_property()?;

    Ok(governor)
}

pub fn ram_info() -> Result<Ram, ReaderError> {
    let properties = Property::ram_properties();

    let mem_info = properties
        .iter()
        .find(|v| v.name == "mem_info")
        .ok_or_else(|| ReaderError::PropertyNotFound("MEM_INFO property not found".to_string()))?;

    let total = extract_from_label(&mem_info.path, "MemTotal")?;
    let available = extract_from_label(&mem_info.path, "MemAvailable")?;

    Ok(Ram {
        total: total / (1024.0 * 1024.0),
        used: (total - available) / (1024.0 * 1024.0),
    })
}

pub fn zram_info() -> Result<Zram, ReaderError> {
    let properties = Property::zram_properties();
    let mut mm_stat = None;
    let mut disksize = None;

    for property in properties {
        match property.name.as_str() {
            "mm_stat" => mm_stat = Some(property),
            "disksize" => disksize = Some(property),
            _ => {}
        }
    }

    let mm_stat = mm_stat
        .ok_or_else(|| ReaderError::PropertyNotFound("MM_STAT property not found!".to_string()))?;

    let disksize = disksize
        .ok_or_else(|| ReaderError::PropertyNotFound("DISKSIZE property not found!".to_string()))?;

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

    Ok(Zram {
        origin: origin / (1024.0 * 1024.0),
        compressed: used / (1024.0 * 1024.0),
        total: total / (1024.0 * 1024.0 * 1024.0),
        ratio,
    })
}

pub fn swappiness() -> Result<u8, ReaderError> {
    let properties = Property::kernel_properties();

    let swappiness = properties
        .iter()
        .find(|v| v.name == "swappiness")
        .ok_or_else(|| ReaderError::PropertyNotFound("SWAPPINESS property not found!".to_string()))?
        .read_property()?;

    let parsed_value: u8 = swappiness
        .parse()
        .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

    Ok(parsed_value)
}

pub fn dirty_ratio() -> Result<u8, ReaderError> {
    let properties = Property::kernel_properties();

    let dirty_ratio = properties
        .iter()
        .find(|v| v.name == "dirty_ratio")
        .ok_or_else(|| {
            ReaderError::PropertyNotFound("DIRTY_RATIO property not found!".to_string())
        })?
        .read_property()?;

    let parsed_value = dirty_ratio
        .parse::<u8>()
        .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

    Ok(parsed_value)
}

pub fn dirty_background_ratio() -> Result<u8, ReaderError> {
    let properties = Property::kernel_properties();
    let dirty_background_ratio = properties
        .iter()
        .find(|v| v.name == "dirty_background_ratio")
        .ok_or_else(|| {
            ReaderError::PropertyNotFound("DIRTY_BACKGROUND_RATIO property not found".to_string())
        })?
        .read_property()?;

    let parsed_value = dirty_background_ratio
        .parse::<u8>()
        .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

    Ok(parsed_value)
}

pub fn storage() -> Result<Storage, String> {
    let disks = Disks::new_with_refreshed_list();

    if disks.is_empty() {
        return Err("No partitons found!".to_string());
    }

    let data_partition = disks
        .iter()
        .find(|disk| disk.mount_point().to_str() == Some("/data"));

    match data_partition {
        Some(disks) => {
            let total_bytes = disks.total_space();
            let available_bytes = disks.available_space();
            let used_bytes = total_bytes - available_bytes;

            Ok(Storage {
                total: total_bytes,
                used: used_bytes,
            })
        }

        None => Err("Couldn't isolate the /data partition!".to_string()),
    }
}
