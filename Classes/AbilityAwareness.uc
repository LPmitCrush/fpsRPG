class AbilityAwareness extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if ( Data.WeaponSpeed < 10 || Data.HealthBonus < 10 || Data.ShieldMax < 10 || Data.AdrenalineMax < 110
	     || Data.Attack < 10 || Data.Defense < 10 || Data.AmmoMax < 10)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local PlayerController PC;
	local int x;
	local AwarenessInteraction I;

	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	PC = PlayerController(Other.Controller);
	if (PC == None)
		return;

	for (x = 0; x < PC.Player.LocalInteractions.length; x++)
		if (AwarenessInteraction(PC.Player.LocalInteractions[x]) != None)
		{
			I = AwarenessInteraction(PC.Player.LocalInteractions[x]);
			break;
		}
	if (I == None)
		I = AwarenessInteraction(PC.Player.InteractionMaster.AddInteraction("FlameRPG.AwarenessInteraction", PC.Player));
	I.AbilityLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="ÿ¿Awareness"
     Description="Informs you of your enemies' health with a display over their heads. At level 1 you get a colored indicator (green, yellow, or red)|level 2: you get a colored health bar and a shield bar|Level 3: Shows you the monsters health in numbers (above their head)|You need atleast 10 points into all stats to buy this ability"
     StartingCost=15
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=3
}
