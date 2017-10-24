class PoisonBlastInv extends PoisonInv;

var RPGRules RPGRules;
var float DrainAmount;

simulated function Timer()
{
	local int HealthDrained;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		HealthDrained = int((PawnOwner.Health * DrainAmount)/100);
		if(HealthDrained > 1)
		{
			if(PawnOwner.Controller == None || PawnOwner.Controller.bGodMode == False)
			{
				PawnOwner.Health -= HealthDrained;
				if(Instigator != None && Instigator != PawnOwner.Instigator) //exp only for harming others.
					RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, HealthDrained);
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		//PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'PoisonBlastConditionMessage', 0);
	}
	//dont call super. Bad things will happen.
}

defaultproperties
{
     DrainAmount=10.000000
}
