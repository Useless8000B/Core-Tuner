use crate::models::ram_model::RamModel;
use crate::models::zram_model::ZramModel;
use crate::system::reader;
use crate::system::writer;
use crate::models::battery_model::BatteryModel;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn get_battery_info() -> Result<BatteryModel, String> {
    let battery_info = reader::battery_info()?;

    Ok(battery_info)
}

pub fn get_battery_temperature() -> Result<f64, String> {
    let battery_temperature = reader::battery_temperature()?;

    Ok(battery_temperature)
}

pub fn get_cpu_temperature() -> Result<f32, String> {
    let cpu_temperature = reader::cpu_temperature()?;
    
    Ok(cpu_temperature)
}

pub fn get_cpu_frequencies() -> Result<Vec<f64>, String> {
    let cpu_frequencies = reader::cpu_frequencies()?;

    Ok(cpu_frequencies)
}

pub fn get_cpu_governor() -> Result<String, String> {
    let cpu_governor = reader::cpu_governor()?;

    Ok(cpu_governor)
}

pub fn set_governor(governor: &str) -> Result<(), String> {
    writer::set_cpu_governor(governor)
}

pub fn get_ram_info() -> Result<RamModel, String> {
    let memory_info = reader::ram_info()?;

    Ok(memory_info)
}

pub fn get_swap_info() -> Result <ZramModel, String> {
    let zram_info = reader::zram_info()?;

    Ok(zram_info)
}

