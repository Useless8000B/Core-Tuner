use crate::system::{governor::Governor, properties::Property};

pub fn set_cpu_governor(governor: &str) -> Result<(), String> {
    let properties: Vec<Property> = Property::cpu_properties();

    let policy_0 = properties
        .iter()
        .find(|v| v.name == "policy0")
        .ok_or("policy0 property not found")?
        .read_property()?;

    let policy_4 = properties
        .iter()
        .find(|v| v.name == "policy4")
        .ok_or("policy4 property not found")?
        .read_property()?;

	let gov = Governor::from_input(governor).ok_or("Invalid governor")?;

	gov.apply(&policy_0)?;
	gov.apply(&policy_4)?;

    Ok(())
}
