use std::fs;

pub struct Property {
    pub name: String,
    pub path: String,
}

impl Property {
    pub fn new(name: &str, path: &str) -> Self {
        Property {
            name: name.to_string(),
            path: path.to_string(),
        }
    }

    pub fn read_property(&self) -> Result<String, String> {
        let content = fs::read_to_string(&self.path)
            .map_err(|e| format!("Error reading {}: {}", self.name, e))?;

        Ok(content.trim().to_string())
    }

    pub fn battery_properties() -> Vec<Property> {
        vec![
            Property::new("is_charging", "/sys/class/power_supply/battery/status"),
            Property::new("level", "/sys/class/power_supply/battery/capacity"),
            Property::new("input_suspend", "/sys/class/power_supply/battery/input_suspend"),
        ]
    }

    pub fn ram_properties() -> Vec<Property> {
        vec![
            Property::new("mem_info", "/proc/meminfo")
        ]
    }

    pub fn zram_properties() -> Vec<Property> {
        vec![
            Property::new("mm_stat", "/sys/block/zram0/mm_stat"),
            Property::new("disksize", "/sys/block/zram0/disksize"),
        ]
    }

    pub fn cpu_cores_properties() -> Vec<Property> {
        vec![
            Property::new("cpu_core", "/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"),
        ]
    }

    pub fn cpu_path_properties() -> Vec<Property> {
        vec![
            Property::new("governor", "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"),
            Property::new("cpu_path", "/sys/devices/system/cpu"),
        ]
    }

    pub fn kernel_properties() -> Vec<Property> {
        vec![
            Property::new("swappiness", "/proc/sys/vm/swappiness"),
            Property::new("dirty_ratio", "/proc/sys/vm/dirty_ratio"),
            Property::new("dirty_background_ratio", "/proc/sys/vm/dirty_background_ratio"),
        ]
    }

    pub fn storage_properties() -> Vec<Property> {
        vec![
            Property::new("tombstones", "/data/tombstones/*"),
            Property::new("temp_files", "/data/local/tmp/*"),
            Property::new("anr", "/data/anr/*"),
        ]
    }
}
