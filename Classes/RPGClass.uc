class RPGClass extends RPGDeathAbility
	config(fpsRPG) 
	abstract;

var config int LowLevel;
var config int MediumLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	if(CurrentLevel > 1)
		return 0;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if(ClassIsChildOf(Data.Abilities[x], Class'RPGClass') && Data.Abilities[x] != default.Class)
			return 0;
	}
	return default.StartingCost;
}

static simulated function RPGStatsInv getPlayerStats(Controller c)
{
	Local GameRules G;
	Local RPGRules RPG;
	for(G = C.Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			RPG = RPGRules(G);
			break;
		}
	}

	if(RPG == None)
	{
		Log("WARNING: Unable to find RPGRules in GameRules.");
		return None;
	}
	return RPG.GetStatsInvFor(C);
}

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	local int y;
	local int GhostLevel;
	local int GhostIndex;
	GhostIndex = -1;
	
	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityGhost'))
 			{
 				GhostLevel = StatsInv.Data.AbilityLevels[y];
 				GhostIndex = y;
 			}
 		}

		if(StatsInv.DataObject.Level <= default.LowLevel)
		{
			if(GhostIndex >= 0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventDeath(Killed, Killer, DamageType, HitLocation, 2, false);
			else
				return class'DruidGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 2);
			
		}
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if(GhostIndex >= 0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventDeath(Killed, Killer, DamageType, HitLocation, 1, false);
			else
				return class'DruidGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 1);
		}
 	}
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	local int y;
	local int GhostLevel;
	local int GhostIndex;
	GhostIndex = -1;
	
	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityGhost'))
 			{
 				GhostLevel = StatsInv.Data.AbilityLevels[y];
 				GhostIndex = y;
 			}
 		}

		if(StatsInv.DataObject.Level <= default.LowLevel)
		{
			if(GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, 3);
			else
				return class'DruidGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 3);
		}
		else if(StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if(GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, Min(3, GhostLevel + 2));
			else
				return class'DruidGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 2);
		}
 	}
}

static simulated function ModifyVehicle(Vehicle V, int AbilityLevel)
{
	// called when player enters a vehicle
	// fpsRPG resets the vehicle health back to defaults when you get in. We need to reapply bonus
	local float Healthperc;

	if (V.SuperHealthMax == 199)
		return;					// not spawned by Engineer

	// need to undo the change done by the MutfpsRPG.DriverEnteredVehicle function
	Healthperc = float(V.Health) / V.HealthMax;	// current health percent
	V.HealthMax = V.SuperHealthMax;
	V.Health =Healthperc * V.HealthMax;		// now applied to new max

}

defaultproperties
{
     LowLevel=20
     MediumLevel=40
     StartingCost=1
     MaxLevel=1
}
