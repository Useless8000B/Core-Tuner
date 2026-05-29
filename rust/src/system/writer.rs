use crate::system::governor::Governor;
use crate::system::lmk::Lmk;
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

    run_command::write_shell_command(
        "su",
        &[
            "-c",
            "settings put global wifi_scan_throttle_enabled",
            value,
        ],
    )
}

pub fn fstrim() -> Result<(), String> {
    run_command::write_shell_command("su", &["-c", "fstrim -v /data && fstrim -v /cache"])
}

pub fn clear_logs() -> Result<(), String> {
    let properties = Property::storage_properties();

    let tombstones = properties
        .iter()
        .find(|v| v.name == "tombstones")
        .ok_or("tombstones property not found")?;

    let anr = properties
        .iter()
        .find(|v| v.name == "anr")
        .ok_or("anr property not found")?;

    run_command::write_shell_command(
        "su",
        &["-c", "rm -rf", &tombstones.path, "&&", "rm -rf", &anr.path],
    )
}

pub fn clear_temp_files() -> Result<(), String> {
    let properties = Property::storage_properties();

    let temp_files = properties
        .iter()
        .find(|v| v.name == "temp_files")
        .ok_or("temp_files property not found")?;

    run_command::write_shell_command("su", &["-c", "rm -rf", &temp_files.path])
}

pub fn lmk_profile(choice: u8) -> Result<(), String> {
    let safe_value = choice.clamp(0, 3);
    let profile = Lmk::from_input(safe_value).ok_or("Couldn't get from input")?;

    run_command::write_shell_command(
        "su",
        &[
            "-c",
            "setprop persist.sys.lmk.minfree_levels",
            profile.as_string(),
            "&&",
            "setprop sys.lmk.minfree_levels",
            profile.as_string(),
        ],
    )
}
