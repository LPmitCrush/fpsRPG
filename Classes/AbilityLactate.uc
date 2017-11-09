Class AbilityLactate Extends RPGAbility
	Config(fpsRPG)
	Abstract;

Var Config int MinLev;

Static Simulated Function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	If(Data.Level < Default.MinLev && CurrentLevel == 0)
		Return 0;
	Return Super.Cost(Data, CurrentLevel);
}

Static Simulated Function ModifyPawn(Pawn Other, int AbilityLevel)
{
	Local Inventory Inv;
	Local Lactate Lac;

	If (Other.Role != ROLE_Authority)
		Return;

	Inv = Other.FindInventoryType(Class'Lactate');
	If (Inv == None)
	{
		Lac = Other.Spawn(Class'Lactate', Other,,,Rot(0,0,0));
		Lac.GiveTo(Other);
	}
}

defaultproperties
{
     MinLev=100
     AbilityName="ÿÙLactate"
     Description="This special ability will prevent anyone from receiving damage by a Milk Monster (milk bottles + googles)...most of the time|Beware: Killing the milk monster is not necessarily a good thing! You have been warned|Required Level: Level 100|Cost: 60|Max Level: 1"
     StartingCost=60
     CostAddPerLevel=0
     MaxLevel=1
}
