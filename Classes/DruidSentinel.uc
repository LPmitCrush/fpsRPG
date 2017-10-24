class DruidSentinel extends ASVehicle_Sentinel_Floor;

simulated event PostBeginPlay()
{
	DefaultWeaponClassName=string(class'DruidWeaponSentinel');

	super.PostBeginPlay();
}

defaultproperties
{
     DefaultWeaponClassName="DruidWeaponSentinel"
     bNoTeamBeacon=False
}
