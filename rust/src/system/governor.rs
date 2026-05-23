pub enum Governor {
    Performance,
    Schedutil,
    Powersave,
}

impl Governor {
    pub fn as_string(&self) -> &str {
        match self {
            Governor::Performance => "performance",
            Governor::Schedutil => "schedutil",
            Governor::Powersave => "powersave",
        }
    }

    pub fn from_input(choice: &str) -> Option<Self> {
        match choice {
            "performance" => Some(Governor::Performance),
            "schedutil" => Some(Governor::Schedutil),
            "powersave" => Some(Governor::Powersave),
            _ => None,
        }
    }
}
