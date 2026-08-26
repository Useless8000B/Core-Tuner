use std::process::Command;

use crate::errors::shell_command_error::ShellCommandError;

pub fn write_shell_command(cmd: &str, args: &[&str]) -> Result<(), ShellCommandError> {
    let status = Command::new(cmd)
        .args(args)
        .status()
        .map_err(|_| ShellCommandError::Spawn)?;

    if !status.success() {
        return Err(ShellCommandError::CommandFailed(status));
    }

    Ok(())
}
