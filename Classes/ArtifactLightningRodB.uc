class ArtifactLightningRodB extends ArtifactLightningRod
	config(fpsRPG);

var config float CostPerHit;
var config float HealthMultiplier;
var config int MaxDamagePerHit;
var config int MinDamagePerHit;

state Activated
{
	function Timer()
	{
		local Controller C, NextC;
		local int DamageDealt;
		local xEmitter HitEmitter;
		local int lCost;

		if(Instigator == None || Instigator.Controller == None)
			return; //must have a controller when active. (Otherwise they're probably ghosting)

		//need to be moving for it to do anything... so can't just sit somewhere and camp
		if (VSize(Instigator.Velocity) ~= 0)
			return;

		C = Level.ControllerList;
		while (C != None)
		{
			// get next controller here because C may be destroyed if it's a nonplayer and C.Pawn is killed
			NextC = C.NextController;
			
			//Is this just some sort of weird unreal script bug? Sometimes C is None
			if(C == None)
			{
				C = NextC;
				break;
			}
			
			if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
			     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) )
			{
				//deviation from Mysterial's class to figure out the damage and adrenaline drain.
				DamageDealt = max(min(C.Pawn.HealthMax * HealthMultiplier, MaxDamagePerHit), MinDamagePerHit);
				
				lCost = DamageDealt * CostPerHit;
				
				if(lCost < 1)
					lCost = 1;
				
				if(lCost < Instigator.Controller.Adrenaline)
				{
					//Is this just some sort of weird unreal script bug? Sometimes C is None
					if(C == None)
					{
						C = NextC;
						break;
					}

					C.Pawn.TakeDamage(DamageDealt, Instigator, C.Pawn.Location, vect(0,0,0), class'DamTypeEnhLightningRod');
					Instigator.Controller.Adrenaline -=lCost;

					//Is this just some sort of weird unreal script bug? Sometimes C is None
					if(C == None)
					{
						C = NextC;
						break;
					}

					HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(C.Pawn.Location - Instigator.Location));
					if (HitEmitter != None)
						HitEmitter.mSpawnVecA = C.Pawn.Location;
				}
			}
			C = NextC;
		}
	}

	function BeginState()
	{
		SetTimer(0.5, true);
		bActive = true;
	}

	function EndState()
	{
		SetTimer(0, false);
		bActive = false;
	}
}

defaultproperties
{
     CostPerHit=0.150000
     HealthMultiplier=0.100000
     MaxDamagePerHit=100
     MinDamagePerHit=5
     CostPerSec=1
     PickupClass=Class'fpsRPG.ArtifactLightningRodPickupB'
}
