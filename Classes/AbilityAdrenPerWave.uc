class AbilityAdrenPerWave extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.AdrenalineMax < 450)
		return 0;
	else
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
     AbilityName="ÿEnergy Per Wave"
     Description="Gives you +1% per level of your maximum adrenaline per wave.|Cost: 5,6,7,8,9,10...|Max Level: 50"
     StartingCost=5
     CostAddPerLevel=1
     MaxLevel=50
}
