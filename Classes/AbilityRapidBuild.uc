class AbilityRapidBuild extends EngineerAbility
	config(fpsRPG)
	abstract;

var config float ReduceRate;

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

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local EngineerPointsInv EInv;

	EInv = class'AbilityLoadedEngineer'.static.GetEngInv(Other);
	if (EInv != None)
		EInv.FastBuildPercent = 1.0 - (AbilityLevel*Default.ReduceRate);

}

defaultproperties
{
     ReduceRate=0.100000
     AbilityName="Constructions: Rapid Build"
     Description="Reduces the delay before you can buld the next item. Each level takes 10% health off your recovery time. (Max Level: 5)|You must be an Engineer to purchase this skill.|Cost (per level): 4,5,6,7,8"
     StartingCost=4
     CostAddPerLevel=1
     MaxLevel=5
}
