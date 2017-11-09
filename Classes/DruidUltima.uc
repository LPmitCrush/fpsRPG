class DruidUltima extends RPGDeathAbility
	abstract
	config(fpsRPG);

/* Note that the comment below was in when we originally had
 * this class based off of AbilityUltima from fpsRPG.
 */
//single Inheritance, so we'll just simulate the AdjustCost. 

static function bool AbilityIsAllowed(GameInfo Game, MutfpsRPG RPGMut)
{
	return true;
}

// Basically like AbilityUltima's PreventDeath, but calling GhostUltimaCharger instead of UltimaCharger
static function PotentialDeathPending(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	if(Vehicle(Killed) != None)
		return;
// If this stops Ultima from going off, change it to:
//		Vehicle(Killed).Driver.spawn(class'GhostUltimaCharger', Vehicle(Killed).Driver.Controller).ChargeTime = 4.0 / AbilityLevel;
	else if(!Killed.Level.Game.IsA('ASGameInfo') && Killed.Location.Z > Killed.Region.Zone.KillZ &&
	  Killed.FindInventoryType(class'KillMarker') != None)
		Killed.spawn(class'GhostUltimaCharger', Killed.Controller).ChargeTime = 4.0 / AbilityLevel;
  
	return;
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
        if (!Killed.Level.Game.IsA('ASGameInfo'))
                class'AbilityUltima'.static.ScoreKill(Killer, Killed, bOwnedByKiller, AbilityLevel); 
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;

	if(Data == None)
		return 0;

	if (Data.Attack < 80)
		return 0;


	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'AbilityUltima')
			return 0;
		else if (Data.Abilities[x] == class'AbilityGhost')
			return 0;

	return super.Cost(Data, CurrentLevel);
}

defaultproperties
{
     AbilityName="Ultima"
     Description="This ability causes your body to release energy when you die. The energy will collect at a single point which will then cause a Redeemer-like nuclear explosion. Level 2 of this ability causes the energy to collect for the explosion in half the time. The ability will only trigger if you have killed at least one enemy during your life. You need to have a Damage Bonus stat of at least 80 to purchase this ability. (Max Level: 2)|Cost (per level): 50,50"
     StartingCost=50
     MaxLevel=2
}
