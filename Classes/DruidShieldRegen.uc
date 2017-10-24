class DruidShieldRegen extends RPGAbility
	config(fpsRPG) 
	abstract;

var config int NoDamageDelay, ShieldPerLevel;
var config float ShieldRegenRate, RegenPerLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidShieldRegenInv R;
	local Inventory Inv;
	local int MaxShield;

	if (Other == None)
		return;
	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'DruidShieldRegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'DruidShieldRegenInv', Other,,,rot(0,0,0));
	if (R == None)
		return;	// ?
	R.NoDamageDelay = default.NoDamageDelay;
	MaxShield = default.ShieldPerLevel*AbilityLevel;
	R.MaxShieldRegen = MaxShield;
	// choice is to either have a flat regen rate, adding so much a second
	// or to have the amount regened based upon the level (e.g. 0.33 would generate level/3 per second)
	// so, whichever is best use.
	R.ShieldRegenRate = fmax(default.ShieldRegenRate,default.RegenPerLevel*float(AbilityLevel));

	R.GiveTo(Other);

	Other.AddShieldStrength(MaxShield);	// start off topped up

}

defaultproperties
{
     NoDamageDelay=3
     ShieldPerLevel=10
     ShieldRegenRate=1.000000
     RegenPerLevel=0.500000
     AbilityName="Shield Regeneration"
     Description="Regenerates your shield at 0.5 per level per second, minimum one, provided you haven't suffered damage recently. Does not regenerate past starting shield amount. (Max level 15) You must be an Engineer to purchase this skill.|Cost (per level): 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4"
     StartingCost=4
     MaxLevel=15
}
