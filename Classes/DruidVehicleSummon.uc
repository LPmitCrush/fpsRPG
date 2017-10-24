class DruidVehicleSummon extends Summonifact
	config(fpsRPG);

function bool SpawnIt(TransBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local Vehicle NewVehicle;
	local Vector SpawnLoc;

	SpawnLoc = Beacon.Location;
	SpawnLoc.z += 30;		// lift just off ground
	if (!CheckSpace(SpawnLoc,500,300))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	NewVehicle = epi.SummonVehicle(SummonItem, Points, P, SpawnLoc);
	if (NewVehicle == None)
		return false;
	SetStartHealth(NewVehicle);

	// now allow player to get xp bonus
	ApplyStatsToConstruction(NewVehicle,Instigator);

	return true;
}

defaultproperties
{
     IconMaterial=Texture'fpsRPGTex.Icons.SummonVehicleIcon'
     ItemName="Vehicle"
}
