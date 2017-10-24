class AbilityShieldHealing extends RPGAbility
	config(fpsRPG)
	abstract;
var config float ShieldHealingPercent;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
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
	local Inventory OInv;
	local RW_EngineerLink EGun;
	local ArtifactShieldBlast ASB;

	if(Monster(Other) != None)
		return; //Not for pets

	EGun = None;
	// Now let's see if they have an EngineerLinkGun
	for (OInv=Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if(ClassIsChildOf(OInv.Class,class'RW_EngineerLink'))
		{
			EGun = RW_EngineerLink(OInv);
			break;
		}
	}
	if (EGun != None)
	{	// ok, they already have the EngineerLink. Let's set their healing level. If not, it will be set when they add the link
		// code duplicated in AbilityLoadedEngineer.SetShieldHealingLevel
		EGun.HealingLevel = AbilityLevel;
		EGun.ShieldHealingPercent = default.ShieldHealingPercent;
	}

	if(AbilityLevel == 3)
	{
		// lets give them the shield blast
		ASB = ArtifactShieldBlast(Other.FindInventoryType(class'ArtifactShieldBlast'));
		if(ASB == None)
		{
			ASB = Other.spawn(class'ArtifactShieldBlast', Other,,, rot(0,0,0));
			if(ASB == None)
				return; //get em next pass I guess?

			ASB.giveTo(Other);
			if(Other.SelectedItem == None)
				Other.NextItem();
		}
	}
}

defaultproperties
{
     ShieldHealingPercent=1.000000
     AbilityName="Shield Healing"
     Description="Allows Engineers to heal other people's shields.|Level 1 enables the Engineers Link Gun. |Level 2 Gives double the experience for healing, Level 3 triple the experience, and gives the Shield Blast artifact. (Max Level: 3)|You must be an Engineer to purchase this skill.|Cost (per level): 10,15,20"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=3
}
