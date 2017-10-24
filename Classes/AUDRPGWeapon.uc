Class AUDRPGWeapon extends RPGWeapon;

var int WeaponEXP,WeaponNeededEXP;
var config float DamageBonus;

//This keeps the weapons info
function InitFor(AUDRPGWeaponPickup AUDWep)
{
   WeaponEXP = AUDWep.WeaponEXP;
   WeaponNeededEXP = AUDWep.WeaponNeededEXP;
   Modifier = AUDWep.Modifier;
}


replication
{
   reliable if(Role == Role_Authority)
       WeaponEXP,WeaponNeededEXP;
}

//Called by RPGRules:ScoreKill
Function ScoreKill(Controller Killer, Controller Killed)
{
  WeaponEXP++;
  if(WeaponEXP >= WeaponNeededEXP)
  {
     WeaponEXP=0;
     Modifier++;
     WeaponNeededEXP = (Modifier*2);
     IdentifyWeapon(self);
  }
}

function Generate(RPGWeapon ForcedWeapon);

function GiveTo(Pawn Other, Optional Pickup Pickup)
{
   Super.GiveTo(Other);

   Modifier = 1;
   WeaponNeededEXP = (Modifier*2);
}

function IdentifyWeapon(RPGWeapon weapon)
{
	local WeaponIdentifierInv inv;
	
	inv = Instigator.spawn(class'WeaponIdentifierInv');
	inv.Weapon = Weapon;
	inv.giveTo(Instigator);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();
	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		//Momentum *= 1.0 +DamageBonus * Modifier;
	}
}

function DropFrom(vector StartLocation)
{
    local int m;
    local Pickup Pickup;
    local Inventory Inv;
    local RPGWeapon W;
    local RPGStatsInv StatsInv;
    local RPGStatsInv.OldRPGWeaponInfo MyInfo;
    local bool bFoundAnother;

    if (!bCanThrow)
    {
    	// hack for default weapons so Controller.GetLastWeapon() will return the modified weapon's class
    	if (Instigator.Health <= 0)
    		Destroy();
        return;
    }
    if (!HasAmmo())
    {
    	return;
    }

    ClientWeaponThrown();

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m].bIsFiring)
            StopFire(m);
    }

	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity;
		References++;
        	if (Instigator.Health > 0)
        	{
			WeaponPickup(Pickup).bThrown = true;
			
			//Pfft tobad i cant get pickup from super...
			//All this for this 1 lil line... what a shame
			AUDRPGWeaponPickup(Pickup).InitFor(Self);

			//only toss 1 ammo if have another weapon of the same class
			for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				W = RPGWeapon(Inv);
				if (W != None && W != self && W.ModifiedWeapon.Class == ModifiedWeapon.Class)
				{
					bFoundAnother = true;
					if (W.bNoAmmoInstances)
					{
						if (AmmoClass[0] != None)
							W.ModifiedWeapon.AmmoCharge[0] -= 1;
						if (AmmoClass[1] != None && AmmoClass[0] != AmmoClass[1])
							W.ModifiedWeapon.AmmoCharge[1] -= 1;
					}
				}
			}
			if (bFoundAnother)
			{
				if (AmmoClass[0] != None)
				{
					WeaponPickup(Pickup).AmmoAmount[0] = 1;
					if (!bNoAmmoInstances)
						Ammo[0].AmmoAmount -= 1;
				}
				if (AmmoClass[1] != None && AmmoClass[0] != AmmoClass[1])
				{
					WeaponPickup(Pickup).AmmoAmount[1] = 1;
					if (!bNoAmmoInstances)
						Ammo[1].AmmoAmount -= 1;
				}
				if (!bNoAmmoInstances)
				{
					Ammo[0] = None;
					Ammo[1] = None;
					ModifiedWeapon.Ammo[0] = None;
					ModifiedWeapon.Ammo[1] = None;
				}
			}
		}
	}

    SetTimer(0, false);
    if (Instigator != None)
    {
	if (ModifiedWeapon != None)
        	StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
       	DetachFromPawn(Instigator);
        Instigator.DeleteInventory(self);
    }
    if (StatsInv != None)
    {
        MyInfo.ModifiedClass = ModifiedWeapon.Class;
        MyInfo.Weapon = self;
    	StatsInv.OldRPGWeapons[StatsInv.OldRPGWeapons.length] = MyInfo;
    	References++;
	DestroyModifiedWeapon();
    }
    else if (Pickup == None)
    	Destroy();
}

defaultproperties
{
     DamageBonus=0.030000
     bCanHaveZeroModifier=True
     bIdentified=True
     PickupClass=Class'fpsRPG.AUDRPGWeaponPickup'
}
