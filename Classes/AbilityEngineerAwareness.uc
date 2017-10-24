class AbilityEngineerAwareness extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if (Data.Abilities[x] == class'AbilityShieldHealing')
			ok = true;
	}
	if (!ok)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int x;
	local PlayerController PC;
	local EngineerAwarenessInteraction Interaction;

	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	PC = PlayerController(Other.Controller);
	if (PC == None)
		return;

	for (x = 0; x < PC.Player.LocalInteractions.length; x++)
	{
		if (EngineerAwarenessInteraction(PC.Player.LocalInteractions[x]) != None)
		{
			Interaction = EngineerAwarenessInteraction(PC.Player.LocalInteractions[x]);
			break;
		}
	}
	if (Interaction == None)
		AddInteraction(PC,AbilityLevel);
	else
		if(Interaction.AbilityLevel != AbilityLevel)
		{
			Interaction.NotifyLevelChange();
			AddInteraction(PC,AbilityLevel);
		}
}

static simulated function AddInteraction(PlayerController PC,int AbilityLevel) //modified from MonsterPointsInv.uc
{
	local Player Player;
	local EngineerAwarenessInteraction Interaction;

	Interaction = new class'EngineerAwarenessInteraction';

	Player = PC.Player;
	if (Interaction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = Interaction;
		Interaction.ViewportOwner = Player;

		// Initialize the Interaction
		Interaction.Initialize();
		Interaction.Master = Player.InteractionMaster;
		Interaction.AbilityLevel = AbilityLevel;
	}
	else
		Log("Could not create EngineerAwarenessInteraction");

} // AddInteraction

defaultproperties
{
     AbilityName="Engineer Awareness"
     Description="Informs you of your friends' shield strength with a display over their heads. You get a large, brightly colored health bar with a white background, that shrinks and changes color as the target shield gains health. The bar will turn a full solid yellow if the shield is fully healed. You need to be an Engineer with Shield Healing to purchase this skill. Cost per level: 10. (Max Level: 1)"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=1
}
