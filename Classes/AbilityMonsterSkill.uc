class AbilityMonsterSkill extends MonsterAbility
	config(fpsRPG)
	abstract;

static simulated function ModifyMonster(Monster Other, int AbilityLevel)
{
	Local FriendlyMonsterInv FriendlyInv;
	FriendlyInv = FriendlyMonsterInv(Other.FindInventoryType(class'FriendlyMonsterInv'));
	if(FriendlyInv != None) //this should ALWAYS be the case...
		FriendlyInv.Skill = AbilityLevel;

	FriendlyMonsterController(Other.Controller).InitializeSkill(AbilityLevel); //start it out here. It will probably be re-initialized in a moment, but it's better to start it here.
}

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

defaultproperties
{
     AbilityName="Summons: Intelligence"
     Description="Increases your summoned monsters' intelligence. At each level, your pet monsters become more intelligent. (Max Level: 7)|You must be a Monster Master to purchase this skill.|Cost (per level): 2,3,4,5,6,7,8"
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=7
}
