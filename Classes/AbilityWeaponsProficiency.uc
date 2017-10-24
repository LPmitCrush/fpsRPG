class AbilityWeaponsProficiency extends RPGAbility
	config(fpsRPG) 
	abstract;

var config int RequiredLevel;
var config float LevMultiplier;
var config float MaxIncrease;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassWeaponsMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}
	
	if(Data.Level < (default.RequiredLevel + CurrentLevel))
		return 0;

	return Super.Cost(Data, CurrentLevel);
}

static function GetNumKillsForWeapon(out float incPerc, class<Weapon> WeaponClass, TeamPlayerReplicationInfo TPPI, int AbilityLevel)
{
	local int i;
	local int numKills;
	
	incPerc = 0.0;
	if (TPPI == None)
		return;

	for ( i=0; i<TPPI.WeaponStatsArray.Length && i<100; i++ )
	{
		if (ClassIsChildOf(WeaponClass, TPPI.WeaponStatsArray[i].WeaponClass))
		//if ( TPPI.WeaponStatsArray[i].WeaponClass == WeaponClass )
		{
			numKills = TPPI.WeaponStatsArray[i].Kills;
			i = TPPI.WeaponStatsArray.Length;
		}
	}
	incPerc = numKills * (AbilityLevel * default.LevMultiplier);
	if (incPerc > default.MaxIncrease)
		incPerc = default.MaxIncrease;
} 

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float incPerc;
	
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0 && Instigator != None && ClassIsChildOf(DamageType, class'WeaponDamageType'))
	{
		// find the number of kills. Can't store in a global, as abilities are abstract. Go to the scoreboard.
		GetNumKillsForWeapon(incPerc, class<WeapondamageType>(DamageType).default.WeaponClass, TeamPlayerReplicationInfo(Instigator.PlayerReplicationInfo), AbilityLevel);
			
		// ok, now check for DD
		if (Instigator.HasUDamage())
		{
			// shouldn't increase the DD bonus with this ability. To ensure just original damage gets DD boosted, half the proficiency bonus given
			// still allows the triple under some circumstances to give a bit extra, but that is rare, and those games will not normally have high kills
			incPerc = incPerc / 2.f;
		}
		Damage = damage * (incPerc + 1.0);
	}
}

// note what the proficiency of this weapon is 
static function ModifyWeapon(Weapon Weapon, int AbilityLevel)
{
	local float incPerc;
	local int intPerc;
	local Weapon W;
	if (Weapon == None || Weapon.Owner == None || Pawn(Weapon.Owner) == None || Pawn(Weapon.Owner).PlayerReplicationInfo == None || PlayerController(Pawn(Weapon.Owner).Controller) == None)
		return;
	if (Weapon.Role != ROLE_Authority)
		return;
		
	if (RPGWeapon(Weapon) != None)
		W = RPGWeapon(Weapon).ModifiedWeapon;
	else
		W = Weapon;
		
	if(instr(caps(string(W)), "AVRIL") > -1)//hack for vinv avril
		GetNumKillsForWeapon(incPerc, class'ONSAVRiL', TeamPlayerReplicationInfo(Pawn(Weapon.Owner).PlayerReplicationInfo), AbilityLevel);
	else
		GetNumKillsForWeapon(incPerc, W.Class, TeamPlayerReplicationInfo(Pawn(Weapon.Owner).PlayerReplicationInfo), AbilityLevel);
	intPerc = 100 * incPerc;
	PlayerController(Pawn(Weapon.Owner).Controller).ReceiveLocalizedMessage(Class'ProficiencyMessage', intPerc,,,W);
	
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;	// no enhanced or offensive artifacts allowed
		return true;
	}
	return false;
}

defaultproperties
{
     RequiredLevel=100
     LevMultiplier=0.010000
     MaxIncrease=1.000000
     AbilityName="ÿWeapons Proficiency"
     Description="Tracks the kills per weapon, and adds extra damage the more you kill|Required Level: 100 |Cost: 25,30,35,40|Max Level: 4"
     StartingCost=25
     CostAddPerLevel=5
     MaxLevel=4
}
