class AbilityAdrenPerWave extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassAdrenalineMaster')
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
 	local RegenInv R;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	R = RegenInv(Other.FindInventoryType(class'RegenInv'));
	if (R == None)
	{
     	  R = Other.spawn(class'RegenInv', Other,,,rot(0,0,0));
	  R.GiveTo(Other);
	}
        if (R != none)
        {
	  R.bAdrenPerWave = true;
	  R.AdrenToGive = AbilityLevel;
        }       
}

defaultproperties
{
     AbilityName="ÿ¥Energy Per Wave"
     Description="Gives you +1% per level of your maximum adrenaline per wave.|Cost: 5,6,7,8,9,10...|Max Level: 50"
     StartingCost=5
     CostAddPerLevel=1
     MaxLevel=50
}
