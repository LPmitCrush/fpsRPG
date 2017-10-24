Class AUDRPGWeaponPickup Extends RPGWeaponPickup;

var int WeaponEXP,WeaponNeededEXP,Modifier;

function InitFor(AUDRPGWeapon AUDWep)
{
   WeaponEXP = AUDWep.WeaponEXP;
   WeaponNeededEXP = AUDWep.WeaponNeededEXP;
   Modifier = AUDWep.Modifier;
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);

	if(Copy != None)
	  AUDRPGWeapon(Copy).InitFor(self);

 return copy;
}

defaultproperties
{
}
