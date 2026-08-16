use std::borrow::Cow;

use crate::models::ram_model::RamModel;
use crate::models::storage_model::StorageModel;
use crate::models::zram_model::ZramModel;
use crate::system::reader;
use crate::system::writer;
use crate::models::battery_model::BatteryModel;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn get_battery_info() -> Result<BatteryModel, Cow<'static, str>> {
    reader::battery_info()
}

pub fn get_battery_temperature() -> Result<f64, Cow<'static, str>> {
    reader::battery_temperature()
}

pub fn set_wifi_throttle(enable: bool) -> Result<(), String> {
    writer::wifi_throttle(enable)
}

pub fn get_cpu_temperature() -> Result<f32, Cow<'static, str>> {
    reader::cpu_temperature()
}

pub fn get_cpu_frequencies() -> Result<Vec<f64>, Cow<'static, str>> {
    reader::cpu_frequencies()
}

pub fn get_cpu_governor() -> Result<String, Cow<'static , str>> {
    reader::cpu_governor()
}

pub fn set_governor(governor: &str) -> Result<(), String> {
    writer::set_cpu_governor(governor)
}

pub fn get_ram_info() -> Result<RamModel, Cow<'static, str>> {
    reader::ram_info()
}

pub fn get_swap_info() -> Result <ZramModel, Cow<'static, str>> {
    reader::zram_info()
}

pub fn get_swappiness() -> Result<u8, Cow<'static, str>> {
    reader::swappiness()
}

pub fn set_swappiness(choice: u8) -> Result<(), String> {
    writer::set_swappiness(choice)
}

pub fn get_vm_dirty_ratio() -> Result<u8, Cow<'static, str>> {
    reader::dirty_ratio()
}

pub fn set_vm_dirty_ratio(choice: u8) -> Result<(), String> {
    writer::set_dirty_ratio(choice)
}

pub fn get_vm_dirty_background_ratio() -> Result<u8, Cow<'static, str>> {
    reader::dirty_background_ratio()
}

pub fn set_vm_background_dirty_ratio(choice: u8) -> Result<(), String> {
    writer::set_background_ratio(choice)
}

pub fn get_storage() -> Result<StorageModel, Cow<'static, str>> {
    reader::storage()
}

pub fn write_fstrim() -> Result<(), String> {
    writer::fstrim()
}

pub fn write_clear_logs() -> Result<(), String>  {
    writer::clear_logs()
}

pub fn write_clear_temp_files() -> Result<(), String> {
    writer::clear_temp_files()
}

pub fn write_lmk_profile(choice: u8) -> Result<(), String> {
    writer::lmk_profile(choice)
}
