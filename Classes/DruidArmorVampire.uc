class DruidArmorVampire extends RPGAbility
	config(fpsRPG)
	abstract;

var config int AdjustableStartingDamage;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
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
	local int HealthVamped;
	local float VampDamage;
	local Vehicle v;

	if (!bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;
		
	// must be a vehicle
	if (Vehicle(Instigator) == None)
		return;

	v = Vehicle(Instigator);

	// but it must be also be manned
	if (v.Driver == None)
		if (TeamGame(Instigator.Level.Game) != None)	// no armorvampire for sentinels in teamgames
			return;

	if (ONSWeaponPawn(v) != None && ONSWeaponPawn(v).VehicleBase != None && !ONSWeaponPawn(v).bHasOwnHealth)
		 v = ONSWeaponPawn(v).VehicleBase;

	VampDamage = Damage;
	//if (Monster(Injured) != None && Instigator.HasUDamage())
	//	VampDamage *= 2;					// double damage will not be taken into account until later
		
	if (Injured != None && VampDamage > Injured.Health)
		VampDamage = Injured.Health;		// only get vampire on damage we actually do

	HealthVamped = int(VampDamage * 0.03 * AbilityLevel);
	if (HealthVamped == 0 && Damage > 0)
	{
		HealthVamped = 1;
	}

	// Give to the vehicle
	v.GiveHealth(HealthVamped, v.HealthMax);
}

defaultproperties
{
     AdjustableStartingDamage=50
     AbilityName="Armor Vampirism"
     Description="Whenever you damage another player from a vehicle or turret, it is healed for 3% of the damage per level (up to its starting health amount). You must have a Damage Bonus of at least 50 to purchase this ability. (Max Level: 10) You must be an Engineer to purchase this skill.|Cost (per level): 10,15,20,25,30,35,40,45,50,55"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=10
}
