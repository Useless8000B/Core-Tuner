pub enum Lmk {
    Stock,
    Balanced,
    Aggressive,
    Extreme,
}

impl Lmk {
    pub fn as_string(&self) -> &str {
        match self {
            Lmk::Stock => "15360,19200,23040,26880,34415,43737",
            Lmk::Balanced => "18432,23040,27648,32256,55296,80640",
            Lmk::Aggressive => "23040,28160,33280,38400,61440,92160",
            Lmk::Extreme => "28160,33280,38400,43520,81920,115200",
        }
    }

    pub fn from_input(choice: u8) -> Option<Self> {
        match choice {
            0 => Some(Lmk::Stock),
            1 => Some(Lmk::Balanced),
            2 => Some(Lmk::Aggressive),
            3 => Some(Lmk::Extreme),
            _ => None,
        }
    }
}
