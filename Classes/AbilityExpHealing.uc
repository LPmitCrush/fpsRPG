class AbilityExpHealing extends RPGAbility
	config(fpsRPG)
	abstract;

var config float EXPBonusPerLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local bool foundLoadedHealing;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if (Data.Abilities[x] == class'ClassMonsterMaster')
			ok = true;

		else if (Data.Abilities[x] == class'AbilityLoadedHealing')
			foundLoadedHealing = true;
	}

	if(!ok || !foundLoadedHealing)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return super.Cost(Data, CurrentLevel);
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArtifactMakeSuperHealer AMSH;
	if(Monster(Other) != None)
		return; //Not for pets

	AMSH = ArtifactMakeSuperHealer(Other.FindInventoryType(class'ArtifactMakeSuperHealer'));

	//spawn one. AbilityLoadedHealing will come along and populate the other data in a moment.
	if(AMSH == None)
	{
		AMSH = Other.spawn(class'ArtifactMakeSuperHealer', Other,,, rot(0,0,0));
		if(AMSH == None)
			return; //get em next pass I guess?

		AMSH.giveTo(Other);
	}
	AMSH.EXPMultiplier = class'RW_Healer'.default.EXPMultiplier + (Default.EXPBonusPerLevel * AbilityLevel);
}

defaultproperties
{
     EXPBonusPerLevel=0.010000
     AbilityName="Experienced Healing"
     Description="Allows you to gain additional experience for healing others with the Medic Gun.|Each level allows you to gain an additional 1% experience from healing. (Max Level: 9)|You must be a Monster Master and have Loaded Medic to purchase this skill.|Cost (per level): 5,8,11,14,17,20,23,26,29"
     StartingCost=5
     CostAddPerLevel=3
     MaxLevel=9
}
