class AbilityMedicAwareness extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if (Data.Abilities[x] == class'AbilityLoadedHealing')
			if (Data.AbilityLevels[x] == 3)
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
	local MedicAwarenessInteraction Interaction;

	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	PC = PlayerController(Other.Controller);
	if (PC == None)
		return;

	for (x = 0; x < PC.Player.LocalInteractions.length; x++)
	{
		if (MedicAwarenessInteraction(PC.Player.LocalInteractions[x]) != None)
		{
			Interaction = MedicAwarenessInteraction(PC.Player.LocalInteractions[x]);
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
	local MedicAwarenessInteraction Interaction;

	Interaction = new class'MedicAwarenessInteraction';

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
		Log("Could not create MedicAwarenessInteraction");

} // AddInteraction

defaultproperties
{
     AbilityName="Medic Awareness"
     Description="Informs you of your friends' health with a display over their heads. At level 1 you get a small dully-colored indicator - blue for very healthy, green for reasonably healthy, yellow for hurt, and then red for near death. At level 2 you get a larger and more brightly colored health bar with a white background, that shrinks and changes colors as the target gains health. The bar will turn a full solid blue if the target is fully healed. You need to be a Loaded Medic level 3 to purchase this skill. Cost per level: 10, 15. (Max Level: 2)"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=2
}
