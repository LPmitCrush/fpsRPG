class AbilityEnergyVampire extends AdjustCost
	config(fpsRPG) 
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

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float AdrenalineBonus;

	if(Instigator.Weapon != None && Instigator.Weapon.isA('RW_Rage'))
		return; //no vamp for rage weapons

	if (Damage < 1 || !bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None || Injured == None ||  UnrealPlayer(Instigator.Controller) == None || Instigator.Controller.Adrenaline >= Instigator.Controller.AdrenalineMax || Instigator.InCurrentCombo() || HasActiveArtifact(Instigator))
		return;
	
	if (Damage > Injured.Health)
		AdrenalineBonus = Injured.Health;
	else
		AdrenalineBonus = Damage;
	AdrenalineBonus *= 0.01 * AbilityLevel;

	if (Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax)
		UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);

	Instigator.Controller.Adrenaline = FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
}

static function bool HasActiveArtifact(Pawn Instigator)
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

defaultproperties
{
     AbilityName="ÿ¥Energy Leech"
     Description="Whenever you damage another player, you gain 1% of the damage as adrenaline. Each level increases this by 1%. (Max Level: 10) |Cost: 10,15,20,25,30"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=10
}
