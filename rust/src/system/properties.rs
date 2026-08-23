use crate::errors::reader_error::ReaderError;
use std::fs;

pub struct Property {
    pub name: &'static str,
    pub path: &'static str,
}

impl Property {
    pub const fn new(name: &'static str, path: &'static str) -> Self {
        Self { name, path }
    }

    pub fn read_property(&self) -> Result<String, ReaderError> {
        let content = fs::read_to_string(&self.path).map_err(|e| {
            if e.kind() == std::io::ErrorKind::NotFound {
                ReaderError::FileNotFound(format!("{:?} not found!", self.path))
            } else {
                ReaderError::Io(e)
            }
        })?;

        Ok(content.trim().to_string())
    }

    pub fn battery_properties() -> &'static [Property] {
        const BATTERY_PROPERTIES: &[Property] = &[
            Property::new("is_charging", "/sys/class/power_supply/battery/status"),
            Property::new("level", "/sys/class/power_supply/battery/capacity"),
        ];

        BATTERY_PROPERTIES
    }

    pub fn ram_properties() -> &'static [Property] {
        const RAM_PROPERTIES: &[Property] = &[Property::new("mem_info", "/proc/meminfo")];

        RAM_PROPERTIES
    }

    pub fn zram_properties() -> &'static [Property] {
        const ZRAM_PROPERTIES: &[Property] = &[
            Property::new("mm_stat", "/sys/block/zram0/mm_stat"),
            Property::new("disksize", "/sys/block/zram0/disksize"),
        ];

        ZRAM_PROPERTIES
    }

    pub fn cpu_properties() -> &'static [Property] {
        const CPU_PROPERTIES: &[Property] = &[
            Property::new(
                "governor",
                "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor",
            ),
            Property::new(
                "cpu_core",
                "/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor",
            ),
        ];

        CPU_PROPERTIES
    }

    pub fn kernel_properties() -> &'static [Property] {
        const KERNEL_PROPERTIES: &[Property] = &[
            Property::new("swappiness", "/proc/sys/vm/swappiness"),
            Property::new("dirty_ratio", "/proc/sys/vm/dirty_ratio"),
            Property::new(
                "dirty_background_ratio",
                "/proc/sys/vm/dirty_background_ratio",
            ),
        ];

        KERNEL_PROPERTIES
    }

    pub fn storage_properties() -> &'static [Property] {
        const STORAGE_PROPERTIES: &[Property] = &[
            Property::new("tombstones", "/data/tombstones/*"),
            Property::new("temp_files", "/data/local/tmp/*"),
            Property::new("anr", "/data/anr/*"),
        ];

        STORAGE_PROPERTIES
    }

    pub fn find_property<'a>(
        properties: &'a [Property],
        name: &'a str,
    ) -> Result<&'a Property, ReaderError> {
        properties
            .iter()
            .find(|v| v.name == name)
            .ok_or_else(|| ReaderError::PropertyNotFound(format!("{name} property not found")))
    }
}
