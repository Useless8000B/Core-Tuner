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

const MILLIAMPS_TO_AMPS: f64 = 1000.0;
const MICROVOLTS_TO_VOLTS: f64 = 1_000_000.0;
const MILLIDEGREES_C_TO_CELSIUS: f64 = 1000.0;
const KILOHERTZ_TO_GIGAHERTZ: f64 = 1_000_000.0;

pub fn battery_info() -> Result<Battery, ReaderError> {
    let sensors = Sensor::battery_sensors();
    let properties = Property::battery_properties();
    let level = Property::find_property(&properties, "level")?.read_property()?;
    let current = Sensor::find_sensor(&sensors, "current")?.read_sensor()?;
    let is_charging = Property::find_property(&properties, "is_charging")?.read_property()? == "Charging";
    let voltage = Sensor::find_sensor(&sensors, "voltage")?.read_sensor()?;

    Ok(Battery {
        level: level
            .parse::<u8>()
            .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?,
        current: current / MILLIAMPS_TO_AMPS,
        is_charging,
        voltage: voltage / MICROVOLTS_TO_VOLTS,
    })
}

pub fn battery_temperature() -> Result<f64, ReaderError> {
    let sensors = Sensor::battery_sensors();
    let temperature = Sensor::find_sensor(&sensors, "temperature")?.read_sensor()?;

    Ok(temperature as f64 / MILLIDEGREES_C_TO_CELSIUS)
}

pub fn cpu_temperature() -> Result<f64, ReaderError> {
    let sensors = Sensor::cpu_sensors();
    let cpu_temperature = Sensor::find_sensor(&sensors, "performance_core")?.read_sensor()?;

    Ok(cpu_temperature / MILLIDEGREES_C_TO_CELSIUS)
}

pub fn cpu_frequencies() -> Result<Vec<f64>, ReaderError> {
    let mut frequencies: Vec<f64> = Vec::new();

    for i in 0..10 {
        let path = format!("/sys/devices/system/cpu/cpu{i}/cpufreq/scaling_cur_freq");

        if !std::path::Path::new(&path).exists() {
            break;
        }

        if let Ok(content) = fs::read_to_string(&path) {
            let value = content
                .trim()
                .parse::<f64>()
                .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

            frequencies.push(value / KILOHERTZ_TO_GIGAHERTZ);
        } else {
            frequencies.push(0.0);
        }
    }

    Ok(frequencies)
}

pub fn cpu_governor() -> Result<String, ReaderError> {
    let properties = Property::cpu_properties();
    let governor = Property::find_property(&properties, "governor")?.read_property()?;

    Ok(governor)
}

pub fn ram_info() -> Result<Ram, ReaderError> {
    let properties = Property::ram_properties();
    let mem_info = Property::find_property(&properties, "mem_info")?;
    let total = extract_from_label(mem_info.path, "MemTotal")?;
    let available = extract_from_label(mem_info.path, "MemAvailable")?;

    Ok(Ram {
        total: total / (1024.0 * 1024.0),
        used: (total - available) / (1024.0 * 1024.0),
    })
}

pub fn zram_info() -> Result<Zram, ReaderError> {
    let properties = Property::zram_properties();
    let mm_stat = Property::find_property(&properties, "mm_stat")?;
    let disksize = Property::find_property(&properties, "disksize")?;
    let origin = extract_from_index(mm_stat.path, 0)?;
    let compressed = extract_from_index(mm_stat.path, 1)?;
    let used = extract_from_index(mm_stat.path, 2)?;
    let total = extract_from_index(disksize.path, 0)?;

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
    let swappiness = Property::find_property(&properties, "swappiness")?.read_property()?;
    let parsed_value: u8 = swappiness
        .parse()
        .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

    Ok(parsed_value)
}

pub fn dirty_ratio() -> Result<u8, ReaderError> {
    let properties = Property::kernel_properties();
    let dirty_ratio = Property::find_property(&properties, "dirty_ratio")?.read_property()?;
    let parsed_value = dirty_ratio
        .parse::<u8>()
        .map_err(|_| ReaderError::InvalidValue("Error parsing value".to_string()))?;

    Ok(parsed_value)
}

pub fn dirty_background_ratio() -> Result<u8, ReaderError> {
    let properties = Property::kernel_properties();
    let dirty_background_ratio = Property::find_property(&properties, "dirty_background_ratio")?.read_property()?;
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
