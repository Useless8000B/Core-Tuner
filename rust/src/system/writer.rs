use crate::errors::writer_error::WriterError;
use crate::system::governor::Governor;
use crate::system::lmk::Lmk;
use crate::system::properties::Property;
use crate::utils::run_command;

pub fn set_cpu_governor(choice: &str) -> Result<(), WriterError> {
    let properties = Property::cpu_properties();
    let gov = Governor::from_input(choice).ok_or(WriterError::InvalidValue)?;
    let entry = Property::find_property(properties, "cpu_core")?;
    let cmd = format!("printf %s \"{}\" | tee {}", gov.as_string(), entry.path);

    run_command::write_shell_command("su", &["-c", &cmd])?;

    Ok(())
}

pub fn set_swappiness(choice: u8) -> Result<(), WriterError> {
    let properties = Property::kernel_properties();
    let entry = Property::find_property(properties, "swappiness")?;

    let safe_value = choice.clamp(0, 100);
    let cmd = format!("echo {} > {}", safe_value, entry.path);

    run_command::write_shell_command("su", &["-c", &cmd])?;

    Ok(())
}

pub fn set_dirty_ratio(choice: u8) -> Result<(), WriterError> {
    let safe_value = choice.clamp(0, 100);
    let cmd = format!("sysctl -w vm.dirty_ratio={safe_value}");

    run_command::write_shell_command("su", &["-c", &cmd])?;

    Ok(())
}

pub fn set_background_ratio(choice: u8) -> Result<(), WriterError> {
    let safe_value = choice.clamp(0, 100);
    let cmd = format!("sysctl -w vm.dirty_background_ratio={safe_value}");

    run_command::write_shell_command("su", &["-c", &cmd])?;

    Ok(())
}

pub fn wifi_throttle(enable: bool) -> Result<(), WriterError> {
    let value: &str = if enable { "1" } else { "0" };

    run_command::write_shell_command(
        "su",
        &[
            "-c",
            "settings put global wifi_scan_throttle_enabled",
            value,
        ],
    )?;

    Ok(())
}

pub fn fstrim() -> Result<(), WriterError> {
    run_command::write_shell_command("su", &["-c", "fstrim -v /data && fstrim -v /cache"])?;

    Ok(())
}

pub fn clear_logs() -> Result<(), WriterError> {
    let properties = Property::storage_properties();

    let tombstones = Property::find_property(properties, "tombstones")?;
    let anr = Property::find_property(properties, "anr")?;

    run_command::write_shell_command(
        "su",
        &["-c", "rm -rf", tombstones.path, "&&", "rm -rf", anr.path],
    )?;

    Ok(())
}

pub fn clear_temp_files() -> Result<(), WriterError> {
    let properties = Property::storage_properties();
    let temp_files = Property::find_property(properties, "temp_files")?;

    run_command::write_shell_command("su", &["-c", "rm -rf", temp_files.path])?;

    Ok(())
}

pub fn lmk_profile(choice: u8) -> Result<(), WriterError> {
    let safe_value = choice.clamp(0, 3);
    let profile = Lmk::from_input(safe_value).ok_or(WriterError::InvalidValue)?;

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
    )?;

    Ok(())
}
