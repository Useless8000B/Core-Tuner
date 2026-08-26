use std::process::ExitStatus;

pub enum ShellCommandError {
    Spawn,
    CommandFailed(ExitStatus),
}
