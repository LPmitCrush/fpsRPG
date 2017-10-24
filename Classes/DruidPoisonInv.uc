class DruidPoisonInv extends PoisonInv
	config(fpsRPG);

var RPGRules RPGRules;

var config float BasePercentage;
var config float Curve;

simulated function Timer()
{
	local int PoisonDamage;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		PoisonDamage = 
			int
			(
				float
				(
					PawnOwner.Health
				) * 
				(
					Curve **
					(
						float
						(
							Modifier-1
						)
					)
					*BasePercentage
				)
			);

		if(PoisonDamage > 0)
		{
			if(PawnOwner.Controller == None || PawnOwner.Controller.bGodMode == False)
			{
				PawnOwner.Health -= PoisonDamage;
				if(Instigator != None && Instigator != PawnOwner.Instigator && RPGRules != None) //exp only for harming others.
					RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, PoisonDamage);
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'RPGDamageConditionMessage', 0);
	}
	//dont call super. Bad things will happen.
}

defaultproperties
{
     BasePercentage=0.050000
     curve=1.300000
}
