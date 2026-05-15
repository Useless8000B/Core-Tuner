use std::process::Command;

use crate::system::governor::Governor;
use crate::system::properties::Property;

pub fn set_cpu_governor(choice: &str) -> Result<(), String> {
    let properties = Property::cpu_cores_properties();
    let gov = Governor::from_input(choice)
        .ok_or("Error reading from input")?;

    let entry = properties
        .iter()
        .find(|v| v.name == "cpu_core")
        .ok_or("cpu_core property not found")?;

    let cmd = format!(
        "printf %s \"{}\" | tee {}",
        gov.as_string(),
        entry.path
    );

    let status = Command::new("su")
        .arg("-c")
        .arg(&cmd)
        .status()
        .map_err(|e| format!("Failed to execute su: {e}"))?;

    if status.success() {
        Ok(())
    } else {
        Err(format!("Command failed due to an error: {status}"))
    }
}

pub fn set_swappiness(choice: u8) -> Result<(), String> {
    let properties = Property::kernel_properties();
    let entry = properties
        .iter()
        .find(|v| v.name == "swappiness")
        .ok_or("swappiness property not found")?;

    let safe_value = choice.clamp(0, 100);

    let cmd = format!(
        "echo {} > {}",
        safe_value.to_string(),
        entry.path
    );

    let status = Command::new("su")
        .arg("-c")
        .arg(&cmd)
        .status()
        .map_err(|e| format!("Error appling swappiness: {e}"))?;

    if status.success() {
        Ok(())
    } else {
        Err(format!("Command failed due to an error: {status}"))
    }
}
