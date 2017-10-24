class DruidVampire extends AbilityVampire
	config(fpsRPG) 
	abstract;

var config int AdjustableStartingDamage;

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

	if (Data.Attack < default.AdjustableStartingDamage)
		return 0;

	return super.Cost(Data, CurrentLevel);
}

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(Instigator.Weapon != None && Instigator.Weapon.isA('RW_Rage'))
		return; //no vamp for rage weapons
	LocalHandleDamage(Damage, Injured, Instigator, Momentum, DamageType, bOwnedByInstigator, float(AbilityLevel));
}

static function LocalHandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, Float AbilityLevel)
{
	local float VampHealth;
	local Pawn P;

	if (!bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;

	if (Vehicle(Instigator) == None)
	{
		P = Instigator;
	}
	else
	{
		P = Vehicle(Instigator).Driver;
		if (P == None)
		{
			return;
		}
	}

	VampHealth = Damage;
	//if (Monster(Injured) != None && Instigator.HasUDamage())
	//	VampHealth *= 2;					// double damage will not be taken into account until later
		
	if (Injured != None && VampHealth > Injured.Health)
		VampHealth = Injured.Health;		// only get vampire on damage we actually do

	VampHealth *= 0.05 * AbilityLevel;
	if (VampHealth < 1.0 && Damage > 0)
	{
		VampHealth = 1.0;
	}

	P.GiveHealth(VampHealth, P.HealthMax + default.AdjustableStartingDamage);
}

defaultproperties
{
     AdjustableStartingDamage=50
     Description="Whenever you damage an opponent, you are healed for 5% of the damage per level (up to your starting health amount + 50). You can't gain health from self-damage and you can't gain health from damage caused by the Retaliation ability. You must have a Damage Bonus of at least 50 to purchase this ability. (Max Level: 10) You must be a Weapons Master to purchase this skill.|Cost (per level): 10,15,20,25,30,35,40,45,50"
}
