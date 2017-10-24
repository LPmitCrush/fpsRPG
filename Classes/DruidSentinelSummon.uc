class DruidSentinelSummon extends Summonifact
	config(fpsRPG);

function bool SpawnIt(TransBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local ASTurret NewSentinel;
	local DruidSentinelController DSC;
	local DruidBaseSentinelController DBSC;
	local DruidLightningSentinelController DLC;
	local DruidDefenseSentinelController DDC;
	local Vector SpawnLoc,SpawnLocCeiling;
	local bool bGotSpace;
	local class<Pawn> RealSummonItem;
	
	if (ClassIsChildOf(SummonItem,class'DruidEnergyWall'))
		return SpawnEnergyWall(Beacon, P, epi);

	RealSummonItem = SummonItem;
	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);	// look at the floor
	bGotSpace = CheckSpace(SpawnLoc,150,180);
	if (ClassIsChildOf(SummonItem,class'DruidSentinel') || ClassIsChildOf(SummonItem,class'DruidDefenseSentinel')
		 || ClassIsChildOf(SummonItem,class'DruidLightningSentinel'))
	{
		// need to check if ceiling variant is required
		SpawnLocCeiling = epi.FindCeiling(Beacon.Location);	// its a ceiling sentinel - special case.
		if (SpawnLocCeiling != vect(0,0,0) 
			&& (SpawnLoc == vect(0,0,0) || VSize(SpawnLocCeiling - Beacon.Location) < VSize(SpawnLoc - Beacon.Location)))
		{
			// its the ceiling one we want
			if (ClassIsChildOf(SummonItem,class'DruidSentinel')) 
				RealSummonItem = class'DruidCeilingSentinel';
			else if (ClassIsChildOf(SummonItem,class'DruidDefenseSentinel'))
				RealSummonItem = class'DruidCeilingDefenseSentinel';
			else if (ClassIsChildOf(SummonItem,class'DruidLightningSentinel'))
				RealSummonItem = class'DruidCeilingLightningSentinel';		
			SpawnLoc = SpawnLocCeiling;
			bGotSpace = CheckSpace(SpawnLoc,120,-160);
		}

	}

	if (SpawnLoc == vect(0,0,0))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	if (!bGotSpace)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	if (ClassIsChildOf(RealSummonItem,class'ASVehicle_Sentinel_Floor'))
	{	// its a sentinel
		SpawnLoc.z += 65;		// lift just off ground
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DSC = spawn(class'DruidSentinelController');
			if ( DSC != None )
			{
				DSC.SetPlayerSpawner(Instigator.Controller);
				DSC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'ASVehicle_Sentinel_Ceiling'))
	{	// its a ceiling sentinel
		SpawnLoc.z -= 80;		// leave on ceiling
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DSC = spawn(class'DruidSentinelController');
			if ( DSC != None )
			{
				DSC.SetPlayerSpawner(Instigator.Controller);
				DSC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'DruidLightningSentinel'))
	{	// its a lightning sentinel
		SpawnLoc.z += 30;		// lift just off ground
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DLC = spawn(class'DruidLightningSentinelController');
			if ( DLC != None )
			{
				DLC.SetPlayerSpawner(Instigator.Controller);
				DLC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'DruidCeilingLightningSentinel'))
	{	// its a ceiling lightning sentinel
		SpawnLoc.z -= 80;		// leave on ceiling
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DLC = spawn(class'DruidLightningSentinelController');
			if ( DLC != None )
			{
				DLC.SetPlayerSpawner(Instigator.Controller);
				DLC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'DruidCeilingDefenseSentinel'))
	{	// its a ceiling defense sentinel
		SpawnLoc.z -= 80;		// leave on ceiling
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DDC = spawn(class'DruidDefenseSentinelController');
			if ( DDC != None )
			{
				DDC.SetPlayerSpawner(Instigator.Controller);
				DDC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'DruidDefenseSentinel'))
	{	// its a defense sentinel
		SpawnLoc.z += 30;		// lift just off ground
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DDC = spawn(class'DruidDefenseSentinelController');
			if ( DDC != None )
			{
				DDC.SetPlayerSpawner(Instigator.Controller);
				DDC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else
	{	// its some other kind of sentinel
		SpawnLoc.z += 60;		// lift just off ground
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		// let's add the sentinel controller
		if ( Role == Role_Authority )
		{
			DBSC = spawn(class'DruidBaseSentinelController');
			if ( DBSC != None )
			{
				DBSC.SetPlayerSpawner(Instigator.Controller);
				DBSC.Possess(NewSentinel);

				// now allow player to get xp bonus
				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	} 

	return true;
}

function bool SpawnEnergyWall(TransBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	Local DruidEnergyWall NewEnergyWall;
	local DruidEnergyWallController EWC;
	local Actor A;
	local vector HitLocation, HitNormal;
	local vector Post1SpawnLoc, Post2SpawnLoc, SpawnLoc; 
	local vector Normalvect, XVect, YVect, ZVect;
	local class<DruidEnergyWall> WallSummonItem;
	
	WallSummonItem = class<DruidEnergyWall>(SummonItem);
	if (WallSummonItem == None)
	{
		bActive = false;
		GotoState('');
		return false;
	}
		
	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);	// look at the floor
	SpawnLoc.z += 20 + (WallSummonItem.default.Height/2);								// step up a bit off the ground
	
	// now work out the position of the posts
	NormalVect = Normal(SpawnLoc-Instigator.Location);
	NormalVect.Z = 0;
	YVect = NormalVect;
	ZVect = vect(0,0,1);	// always vertical
	XVect = Normal(YVect cross ZVect);	// vector at 90 degrees to the other two

	// first check the height
	if (!FastTrace(SpawnLoc, SpawnLoc + (ZVect*WallSummonItem.default.Height)))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	
	A = Trace(HitLocation, HitNormal, SpawnLoc + (XVect*WallSummonItem.default.MaxGap*0.5), SpawnLoc, true,, );
	if (A == None)
		Post1SpawnLoc = SpawnLoc + (XVect*WallSummonItem.default.MaxGap*0.5);
	else
		Post1SpawnLoc = HitLocation - 20*XVect;		// step back slightly from the object
	
	A = None;
	A = Trace(HitLocation, HitNormal, SpawnLoc - (XVect*WallSummonItem.default.MaxGap*0.5), SpawnLoc, true,, );
	if (A == None)
		Post2SpawnLoc = SpawnLoc - (XVect*WallSummonItem.default.MaxGap*0.5);
	else
		Post2SpawnLoc = HitLocation + 20*XVect;		// step back slightly from the object
		
	// ok now lets spawn it
	if ((Post1SpawnLoc == vect(0,0,0)) || (Post2SpawnLoc == vect(0,0,0)) || VSize(Post1SpawnLoc - Post2SpawnLoc) > WallSummonItem.default.MaxGap  || VSize(Post1SpawnLoc - Post2SpawnLoc) < WallSummonItem.default.MinGap)
	{
		// cant spawn one of the posts or one has gone awol
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	// have 2 valid post positions and a gap inbetween
	NewEnergyWall = epi.SummonEnergyWall(WallSummonItem, Points, P, SpawnLoc, Post1SpawnLoc, Post2SpawnLoc);
	if (NewEnergyWall == None)
		return false;
	SetStartHealth(NewEnergyWall);
	
	// now lets add the controller
	if ( Role == Role_Authority )
	{
		// create the controller for this energy wall
		EWC = DruidEnergyWallController(spawn(NewEnergyWall.default.DefaultController));
		if ( EWC != None )
		{
			EWC.SetPlayerSpawner(Instigator.Controller);
			EWC.Possess(NewEnergyWall);

			// now allow player to get xp bonus
			ApplyStatsToConstruction(NewEnergyWall,Instigator);
		}
	}
	return true;
}

defaultproperties
{
     IconMaterial=Texture'fpsRPGTex.Icons.SummonTurretIcon'
     ItemName="Sentinel"
}
