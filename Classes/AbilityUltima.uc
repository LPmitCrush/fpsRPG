class AbilityUltima extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Attack < 250)
		return 0;

	return Super.Cost(Data, CurrentLevel);
}

static function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel, bool bAlreadyPrevented)
{
	if (!bAlreadyPrevented && Killed.Location.Z > Killed.Region.Zone.KillZ && Killed.FindInventoryType(class'KillMarker') != None)
		Killed.spawn(class'UltimaCharger', Killed.Controller).ChargeTime = 4.0 / AbilityLevel;

	return false;
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	//ugh...I wish there was a faster way...
	if ( bOwnedByKiller && Killer.Pawn != None
	     && (Killed.Pawn == None || Killed.Pawn.HitDamageType != class'DamTypeUltima')
	     && Killer.Pawn.FindInventoryType(class'KillMarker') == None )
		Killer.Pawn.spawn(class'KillMarker', Killer.Pawn).GiveTo(Killer.Pawn);
}

defaultproperties
{
     AbilityName="Ultima"
     Description="This ability causes your body to release energy when you die. The energy will collect at a single point which will then cause a Redeemer-like nuclear explosion. Level 2 of this ability causes the energy to collect for the explosion in half the time. The ability will only trigger if you have killed at least one enemy during your life. You need to have a Damage Bonus stat of at least 250 to purchase this ability. You can't have both Ultima and Ghost at the same time. (Max Level: 20)"
     StartingCost=25
     MaxLevel=20
}
