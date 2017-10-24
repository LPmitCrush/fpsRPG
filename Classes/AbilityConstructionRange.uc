Class AbilityConstructionRange extends EngineerAbility
  abstract
  Config(fpsRPG);

var config float RangeBonus;
var int MinLev;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	if(Data.Level < default.MinLev && CurrentLevel == 0)
		return 0;

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

static simulated function ModifyConstruction (Pawn Other, int AbilityLevel)
{
  if ( (ASTurret(Other) != None) && (ASTurret(Other).Controller != None) )
  {
    Other.SightRadius += Other.SightRadius * Other.Default.SightRadius * AbilityLevel;
  }
}

defaultproperties
{
    RangeBonus=10.00
    MinLev=50
    AbilityName="ÿSentinel Range Upgrade"
    Description="Gives an Additional range bonus to your summoned sentinels. Each level Adds 10% range to your sentinels' max range.|(Max Level: 5)|Cost (per level): 10,20,30"
    StartingCost=10
    CostAddPerLevel=10
    MaxLevel=5
}