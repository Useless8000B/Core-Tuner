use crate::errors::reader_error::ReaderError;
use crate::errors::writer_error::WriterError;
use crate::models::battery::Battery;
use crate::models::ram::Ram;
use crate::models::storage::Storage;
use crate::models::zram::Zram;
use crate::system::reader;
use crate::system::writer;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn get_battery_info() -> Result<Battery, ReaderError> {
    reader::battery_info()
}

pub fn get_battery_temperature() -> Result<f64, ReaderError> {
    reader::battery_temperature()
}

pub fn set_wifi_throttle(enable: bool) -> Result<(), WriterError> {
    writer::wifi_throttle(enable)
}

pub fn get_cpu_temperature() -> Result<f64, ReaderError> {
    reader::cpu_temperature()
}

pub fn get_cpu_frequencies() -> Result<Vec<f64>, ReaderError> {
    reader::cpu_frequencies()
}

pub fn get_cpu_governor() -> Result<String, ReaderError> {
    reader::cpu_governor()
}

pub fn set_governor(governor: &str) -> Result<(), WriterError> {
    writer::set_cpu_governor(governor)
}

pub fn get_ram_info() -> Result<Ram, ReaderError> {
    reader::ram_info()
}

pub fn get_swap_info() -> Result<Zram, ReaderError> {
    reader::zram_info()
}

pub fn get_swappiness() -> Result<u8, ReaderError> {
    reader::swappiness()
}

pub fn set_swappiness(choice: u8) -> Result<(), WriterError> {
    writer::set_swappiness(choice)
}

pub fn get_vm_dirty_ratio() -> Result<u8, ReaderError> {
    reader::dirty_ratio()
}

pub fn set_vm_dirty_ratio(choice: u8) -> Result<(), WriterError> {
    writer::set_dirty_ratio(choice)
}

pub fn get_vm_dirty_background_ratio() -> Result<u8, ReaderError> {
    reader::dirty_background_ratio()
}

pub fn set_vm_background_dirty_ratio(choice: u8) -> Result<(), WriterError> {
    writer::set_background_ratio(choice)
}

pub fn get_storage() -> Result<Storage, String> {
    reader::storage()
}

pub fn write_fstrim() -> Result<(), WriterError> {
    writer::fstrim()
}

pub fn write_clear_logs() -> Result<(), WriterError> {
    writer::clear_logs()
}

pub fn write_clear_temp_files() -> Result<(), WriterError> {
    writer::clear_temp_files()
}

pub fn write_lmk_profile(choice: u8) -> Result<(), WriterError> {
    writer::lmk_profile(choice)
}
