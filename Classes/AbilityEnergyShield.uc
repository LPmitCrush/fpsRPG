class AbilityEnergyShield extends RPGDeathAbility
	config(fpsRPG) 
	abstract;
	
var config int HealthLimit;
var config float HealthBonus;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.AdrenalineMax < 250)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local int DamageCouldHeal;
	local int AdrenalineReqd;
	
	//Log("***** EnergyShield PrePreventDeath Killed:" $ Killed @ "Killer:" $ Killer @ "Damagetype:" $ DamageType @ "Health:" $ Killed.Health);

	if (Killed.Controller != None)
	{
		DamageCouldHeal = Killed.Controller.Adrenaline * default.HealthBonus * AbilityLevel;
		AdrenalineReqd = Killed.Controller.Adrenaline;
		// is this enough?
		if (Killed.Health <= 0 && DamageCouldHeal + Killed.Health > 0)
		{
			// we can save them
			if (DamageCouldHeal + Killed.Health > default.HealthLimit)
			{
				DamageCouldHeal = default.HealthLimit - Killed.Health;
				AdrenalineReqd = DamageCouldHeal / (default.HealthBonus * AbilityLevel);
			}
			Killed.Controller.Adrenaline -= AdrenalineReqd;
			Killed.Health += DamageCouldHeal;
			//Log("**** EnergyShield PrePreventDeath restoring health:" $ DamageCouldHeal @ "to" @ Killed @ "new health:" $ Killed.health @ "using adrenaline:" $ AdrenalineReqd @ "leaving:" $ Killed.Controller.Adrenaline $ "left.");
			return true;
		}
	}
	
	// he is dead, so keep the adrenaline
	//Log("**** EnergyShield PrePreventDeath cannot save:" $ Killed @ "health:" $ Killed.health @ "Adrenaline:" $ Killed.Controller.Adrenaline );
	return false;
}


static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local int iCount;
	local float AdrenalineReqd;
	local int DamageAbsorbed;
	local int DamageLeft;
	
	if (bOwnedByInstigator || Injured == None || Injured.Controller == None)
		return;

	if(Damage <= 0 || Damage <= Injured.Health - default.HealthLimit)
		return;		// nothing to do
		
	// first take damage off shield
	if( DamageType.default.bArmorStops )
	{
		iCount = 0;
		while (Damage > 0 && Injured.ShieldStrength > 0 && iCount < 50)
		{
			Damage = Injured.ShieldAbsorb(Damage);	// take some more shield off

			iCount++;						// safety just in case
		}
	}

	// then see if damage would take the player below the kick-in health. If so, absord with adrenaline
	if(Damage <= 0 || Damage <= Injured.Health - default.HealthLimit)
		return;		// nothing to do. Just take any remaining damge if any
		
	// let's take off what extra damage we can
	if (Injured.Health <= default.HealthLimit)
		DamageLeft = 0;
	else
		DamageLeft = Injured.Health - default.HealthLimit;		// this is how much we should let pass through 
	DamageAbsorbed = Damage - DamageLeft;						// how much we need to absorb 
	
	// now can we absorb that much
	AdrenalineReqd = DamageAbsorbed / (default.HealthBonus * AbilityLevel);

	if (Injured.Controller.Adrenaline > AdrenalineReqd)
	{
		Injured.Controller.Adrenaline -= AdrenalineReqd;
		Damage = DamageLeft;
	}
	else
	{
		// not enough - have to pass more damage through
		DamageAbsorbed = Injured.Controller.Adrenaline * default.HealthBonus * AbilityLevel;
		Injured.Controller.Adrenaline = 0;
		Damage -= DamageAbsorbed;
	}

	// leave the rest of the damage to be processed normally
}

defaultproperties
{
     HealthLimit=10
     HealthBonus=0.500000
     AbilityName="ÿ§Energy Shield"
     Description="Uses adrenaline as a shield. You must be an Adrenaline Master to purchase this skill. |Cost (per level): 15. Max Level: 2."
     StartingCost=15
     MaxLevel=2
}
