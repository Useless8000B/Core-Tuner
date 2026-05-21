use crate::system::governor::Governor;
use crate::system::properties::Property;
use crate::utils::run_command;

pub fn set_cpu_governor(choice: &str) -> Result<(), String> {
    let properties = Property::cpu_cores_properties();
    let gov = Governor::from_input(choice).ok_or("Error reading from input")?;

    let entry = properties
        .iter()
        .find(|v| v.name == "cpu_core")
        .ok_or("cpu_core property not found")?;

    let cmd = format!("printf %s \"{}\" | tee {}", gov.as_string(), entry.path);

    run_command::write_shell_command("su", &["-c", &cmd])
}

pub fn set_swappiness(choice: u8) -> Result<(), String> {
    let properties = Property::kernel_properties();
    let entry = properties
        .iter()
        .find(|v| v.name == "swappiness")
        .ok_or("swappiness property not found")?;

    let safe_value = choice.clamp(0, 100);
    let cmd = format!("echo {} > {}", safe_value.to_string(), entry.path);

    run_command::write_shell_command("su", &["-c", &cmd])
}

pub fn set_dirty_ratio(choice: u8) -> Result<(), String> {
    let safe_value = choice.clamp(0, 100);
    let cmd = format!("sysctl -w vm.dirty_ratio={}", safe_value);
    run_command::write_shell_command("su", &["-c", &cmd])
}

pub fn set_background_ratio(choice: u8) -> Result<(), String> {
    let safe_value = choice.clamp(0, 100);
    let cmd = format!("sysctl -w vm.dirty_background_ratio={safe_value}");

    run_command::write_shell_command("su", &["-c", &cmd])
}

pub fn wifi_throttle(enable: bool) -> Result<(), String> {
    let value: &str = if enable { "1" } else { "0" };

    run_command::write_shell_command("su", &["-c", "settings put global wifi_scan_throttle_enabled ", value])
}
