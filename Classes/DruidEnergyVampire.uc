class DruidEnergyVampire extends RPGAbility
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
	
	if (!ClassIsChildOf(DamageType, class'WeaponDamageType'))
		return;		// no vampire if the damage is not done by a weapon. Most likely beam/bolt. Do not get leech for artifact damage

	AdrenalineBonus = Damage;
	//if (Monster(Injured) != None && Instigator.HasUDamage())
	//	AdrenalineBonus *= 2;					// double damage will not be taken into account until later

	if (AdrenalineBonus > Injured.Health)
		AdrenalineBonus = Injured.Health;

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
     AbilityName="Energy Leech"
     Description="Whenever you damage another player, you gain 1% of the damage as adrenaline. Each level increases this by 1%. (Max Level: 5) You must be an Adrenaline Master to purchase this skill.|Cost (per level): 2,8,14,20,26"
     StartingCost=2
     CostAddPerLevel=6
     MaxLevel=5
}
