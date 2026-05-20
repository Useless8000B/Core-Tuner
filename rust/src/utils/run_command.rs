use std::process::Command;

pub fn write_shell_command(cmd: &str, args: &[&str]) -> Result<(), String> {
	let status = Command::new(cmd)
		.args(args)
		.status()
		.map_err(|e| format!("Error running write command: {e}"))?;

	if !status.success() {
		return Err(format!("Write command failed: {status}"));
	}

	Ok(())
}