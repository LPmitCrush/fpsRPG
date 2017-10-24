class AbilityLoadedHealing extends RPGAbility
	config(fpsRPG)
	abstract;

var config int Lev2Cap;
var config int Lev3Cap;

var config bool enableSpheres;

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

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArtifactMakeSuperHealer AMSH;
	local ArtifactHealingBlast AHB;
	local ArtifactSphereHealing ASpH;

	if(Monster(Other) != None)
		return; //Not for pets

	AMSH = ArtifactMakeSuperHealer(Other.FindInventoryType(class'ArtifactMakeSuperHealer'));

	if(AMSH != None)
	{
		if(AMSH.AbilityLevel == AbilityLevel)
			return;
	}
	else
	{
		AMSH = Other.spawn(class'ArtifactMakeSuperHealer', Other,,, rot(0,0,0));
		if(AMSH == None)
			return; //get em next pass I guess?

		AMSH.giveTo(Other);
		// I'm guessing that NextItem is here to ensure players don't start with
		// no item selected.  So the if should stop wierd artifact scrambles.
		if(Other.SelectedItem == None)
			Other.NextItem();
	}
	AMSH.AbilityLevel = AbilityLevel;
	if(AbilityLevel == 2)
		AMSH.MaxHealth = Default.Lev2Cap;
	if(AbilityLevel == 3)
	{
		AMSH.MaxHealth = Default.Lev3Cap;
		if(default.enableSpheres)
		{
			// ok let's give them some artifacts
			AHB = ArtifactHealingBlast(Other.FindInventoryType(class'ArtifactHealingBlast'));
			if(AHB == None)
			{
				AHB = Other.spawn(class'ArtifactHealingBlast', Other,,, rot(0,0,0));
				if(AHB == None)
					return; //get em next pass I guess?

				AHB.giveTo(Other);
				// I'm guessing that NextItem is here to ensure players don't start with
				// no item selected.  So the if should stop wierd artifact scrambles.
				if(Other.SelectedItem == None)
					Other.NextItem();
			}
			ASpH = ArtifactSphereHealing(Other.FindInventoryType(class'ArtifactSphereHealing'));
			if(ASpH == None)
			{
				ASpH = Other.spawn(class'ArtifactSphereHealing', Other,,, rot(0,0,0));
				if(ASpH == None)
					return; //get em next pass I guess?

				ASpH.giveTo(Other);
				// I'm guessing that NextItem is here to ensure players don't start with
				// no item selected.  So the if should stop wierd artifact scrambles.
				if(Other.SelectedItem == None)
					Other.NextItem();
			}
		}
	}
}

defaultproperties
{
     Lev2Cap=100
     Lev3Cap=150
     AbilityName="Loaded Medic"
     Description="Gives you bonuses towards healing.|Level 1 gives you a Medic Weapon Maker. |Level 2 allows you to use the Medic Gun to heal teammates +100 beyond their max health. |Level 3 allows you to heal teammates +150 points beyond their max health. (Max Level: 3)|You must be a Monster Master to purchase this skill.|Cost (per level): 3,6,9"
     StartingCost=3
     CostAddPerLevel=3
     MaxLevel=3
}
