class RW_Reflection extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var config float BaseChance;
var config float Growth;



function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
	//make the call first in case the weapon actually does the reflect on it's own.
	if(super.CheckReflect(HitLocation, RefNormal, Damage))
		return true;

	if(Damage > 0)
	{
		RefNormal=normal(HitLocation-Location);
		if(rand(99) < int((Growth^float(Modifier))*BaseChance))
		{
			Instigator.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			return true;
		}
	}
	return false;
}

defaultproperties
{
     BaseChance=30.000000
     Growth=1.210000
     ModifierOverlay=TexEnvMap'VMVehicles-TX.Environments.ReflectionEnv'
     AIRatingBonus=0.060000
     PrefixPos="Reflecting "
}
