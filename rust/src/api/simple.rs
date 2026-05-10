use crate::system::reader;
use crate::models::battery_model::BatteryModel;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_battery_info() -> Result<BatteryModel, String> {
    let battery_info = reader::battery_info()?;

    Ok(battery_info)
}
