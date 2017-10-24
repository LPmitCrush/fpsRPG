class AdrenRegenInv extends Inventory;

var int RegenAmount;

function PostBeginPlay()
{
	SetTimer(5.0, true);

	Super.PostBeginPlay();
}

function bool HasActiveArtifact()
{
	local Inventory Inv;

	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.IsA('RPGArtifact') && RPGArtifact(Inv).bActive)
		{
			return true;
		}
	}

	return false;
}

function Timer()
{
	local Controller C;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	C = Instigator.Controller;
	if (C == None && Instigator.DrivenVehicle != None)
	{
		// check for vehicle
		C = Instigator.DrivenVehicle.Controller;
		if (C == None)
		{
			// check for redeemer
			C = Controller(Instigator.Owner);
			if (C == None || C.Pawn == None || !C.Pawn.IsA('RedeemerWarhead'))
			{
				Destroy();
				return;
			}
		}
	}

	if (!Instigator.InCurrentCombo() && !HasActiveArtifact() && C != None)
	{
		C.AwardAdrenaline(RegenAmount);
	}
}

defaultproperties
{
}
