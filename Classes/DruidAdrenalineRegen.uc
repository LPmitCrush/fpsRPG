class DruidAdrenalineRegen extends AbilityAdrenalineRegen
	config(fpsRPG) 
	abstract;

var config int PointsPerLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	if (Data.AdrenalineMax < 100 + default.PointsPerLevel * (CurrentLevel + 1))
		return 0;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassAdrenalineMaster' || Data.Abilities[x] == class'ClassMonsterMaster')
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
	local DruidAdrenRegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'DruidAdrenRegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'DruidAdrenRegenInv', Other,,,rot(0,0,0));
	R.GiveTo(Other);
	R.SetTimer((default.MaxLevel - AbilityLevel) + 1, true);
}

defaultproperties
{
     PointsPerLevel=25
     Description="Slowly drips adrenaline into your system.|At level 1 you get one adrenaline every 3 seconds.|At level 2 you get one adrenaline every 2 seconds.|At level 3 you get one adrenaline every second.|You must spend 25 points in your Adrenaline Max stat for each level of this ability you want to purchase. (Max Level: 3)|You must be an Adrenaline Master or a Monster Master to purchase this skill.|Cost (per level): 2,8,14"
     StartingCost=2
     CostAddPerLevel=6
}
