class DruidRPGGameRules extends GameRules;

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool bAlreadyPrevented;
	local int x;
	local RPGStatsInv StatsInv;
	local Controller KilledController;
	local class<RPGDeathAbility> DeathAbility;

	bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);
	if(bAlreadyPrevented)
		return true;

	if (Killed.Controller != None)
		KilledController = Killed.Controller;
	else if (Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
		KilledController = Killed.DrivenVehicle.Controller;
	if (KilledController != None)
		StatsInv = class'RPGClass'.static.getPlayerStats(KilledController);

	if (StatsInv != None && StatsInv.DataObject != None)
	{
		//FIXME Pawn should probably still call PreventDeath() in cases like this, 
		//but it might be wiser to ignore the value -- Mysterial
		//I dont have the knowledge to change this iflogic -- DRU
		if
		(
			!KilledController.bPendingDelete && 
			(
				KilledController.PlayerReplicationInfo == None || 
				!KilledController.PlayerReplicationInfo.bOnlySpectator
			)
		)
		{
			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.PrePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if(bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.PotentialDeathPending(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.GenuinePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if(bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.GenuineDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}
		}
	}
// Technically, by this point, bAlreadyPrevented should never be true.
// If it were, it would have already been returned so.  BF
	if (bAlreadyPrevented)
		return true;
	else
		return false;
}

defaultproperties
{
}
