class DruidTurretSummon extends Summonifact
	config(fpsRPG);

function bool SpawnIt(TransBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local Vehicle NewTurret;
	local Vector SpawnLoc;

	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);
	if (SpawnLoc == vect(0,0,0))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	// just a turret
	if (ClassIsChildOf(SummonItem,class'ASTurret_Minigun'))
		SpawnLoc.z += 50;		// lift just off ground
	else if (ClassIsChildOf(SummonItem,class'DruidEnergyTurret'))
		SpawnLoc.z += 70;		// lift just off ground
	else
		SpawnLoc.z += 80;		// lift just off ground

	if (!CheckSpace(SpawnLoc,200,300))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	NewTurret = epi.SummonTurret(SummonItem, Points, P, SpawnLoc);
	if (NewTurret == None)
		return false;
	NewTurret.AutoTurretControllerClass = None;	// force it to be manual
	SetStartHealth(NewTurret);

	// now allow player to get xp bonus
	ApplyStatsToConstruction(NewTurret,Instigator);

	return true;
}

defaultproperties
{
     IconMaterial=Texture'fpsRPGTex.Icons.SummonTurretIcon'
     ItemName=""
}
