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
            .map_err(|e| format!("Error reading {}: {}", &self.name, e))?;

        Ok(content.trim().to_string())
    }

    pub fn battery_properties() -> Vec<Property> {
        vec![
            Property::new("is_charging", "/sys/class/power_supply/battery/status"),
            Property::new("level", "/sys/class/power_supply/battery/capacity"),
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
            Property::new("zram_block", "/sys/"),
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
        ]
    }
}
