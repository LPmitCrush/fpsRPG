class AbilityMonsterPoints extends RPGAbility
	config(fpsRPG)
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassMonsterMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local MonsterPointsInv Inv;

	if(Monster(Other) != None)
		return; //Not for pets

	Inv = MonsterPointsInv(Other.FindInventoryType(class'MonsterPointsInv'));

	if(Inv != None)
	{
		if(Inv.TotalMonsterPoints == AbilityLevel)
			return;
	}
	else
	{
		Inv = Other.spawn(class'MonsterPointsInv', Other,,, rot(0,0,0));
		if(Inv == None)
			return; //get em next pass I guess?

		Inv.giveTo(Other);
	}
	Inv.TotalMonsterPoints = AbilityLevel;
}

defaultproperties
{
     AbilityName="Monster Points"
     Description="Allows you to summon monsters with the loaded monsters skill. (Max Level: 20)|You must be a Monster Master to purchase this skill.|Cost (per level): 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21"
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=20
}
