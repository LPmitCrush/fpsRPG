class RegenInv extends Inventory;

var int RegenAmount,AdrenRegenAmount,AmmoRegenAmount,PreviousWave,AdrenToGive;
var bool bHealthRegen,bAdrenRegen,bAmmoRegen,bAdrenPerwave;

//Ammo Regen stuff, Since in the Ammo regen script it triggers every 3 seconds.
var int AmmoTimer;
var bool bCanRegen;

function PostBeginPlay()
{
	SetTimer(1.0, true);

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
      Local Controller C;
      Local Inventory Inv;
      Local Ammunition Ammo;
      Local Weapon W;
      
      	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

        if (bHealthRegen)
        {

        Instigator.GiveHealth(RegenAmount, Instigator.SuperHealthMax);
        if (Instigator.Health == Instigator.SuperHealthMax )
			Instigator.AddShieldStrength(RegenAmount);
         }

	if(bAdrenRegen)
	{
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

  	  if (!Instigator.InCurrentCombo() && !HasActiveArtifact())
		C.AwardAdrenaline(AdrenRegenAmount);
	}
	
       if (bAdrenPerWave && Invasion(Level.Game) != None)
       {
          if(Invasion(Level.Game).WaveNum != PreviousWave)
              Instigator.Controller.AwardAdrenaline((0.01*AdrenToGive)*Instigator.Controller.AdrenalineMax);

           PreviousWave = Invasion(Level.Game).WaveNum;
        }

        if (bAmmoRegen && bCanRegen)
        {

         for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	 {
	 	W = Weapon(Inv);
		if (W != None)
		{
			if (W.bNoAmmoInstances && W.AmmoClass[0] != None && !class'MutfpsRPG'.static.IsSuperWeaponAmmo(W.AmmoClass[0]))
			{
				W.AddAmmo(AmmoRegenAmount * (1 + W.AmmoClass[0].default.MaxAmmo / 100), 0);
				if (W.AmmoClass[0] != W.AmmoClass[1] && W.AmmoClass[1] != None)
					W.AddAmmo(AmmoRegenAmount * (1 + W.AmmoClass[1].default.MaxAmmo / 100), 1);
			}
		}
		else
		{
			Ammo = Ammunition(Inv);
			if (Ammo != None && !class'MutfpsRPG'.static.IsSuperWeaponAmmo(Ammo.Class))
				Ammo.AddAmmo(AmmoRegenAmount * (1 + Ammo.default.MaxAmmo / 100));
		}
	 }
	}

	 AmmoTimer++;
	 if (AmmoTimer >= 3)
	 {
	    bCanRegen = True;
	    AmmoTimer = 0; // Reset the count
         }
         else
         {
	   bCanRegen = False;
         }


}

defaultproperties
{
}
