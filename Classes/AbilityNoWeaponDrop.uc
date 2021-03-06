class AbilityNoWeaponDrop extends RPGAbility
	abstract
	config(fpsRPG);

var config int Level1Cost, Level2Cost, Level3Cost;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int rv;

	if (Data.Level < 25)
		return 0;
	if(CurrentLevel == 0)
		rv = default.Level1Cost;
	if(CurrentLevel == 1)
		rv = default.Level2Cost;
	if(CurrentLevel == 2)
		rv = default.Level3Cost;
	if(rv > 0)
	return rv;
	

	return 0;
}

static function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel, bool bAlreadyPrevented)
{
	local OldWeaponHolderB OldWeaponHolder;
	Local Inventory inv;
	local int x;
	Local Array<Weapon> Weapons;

	if(Killed.isA('Vehicle'))
		Killed = Vehicle(Killed).Driver;

	if(Killed.Controller == Killer)
		return false;

	if(DamageType == class'Suicided')
		return false;

	if (bAlreadyPrevented)
		return false;

	if (Killed.Controller != None && Killed.Weapon != None)
	{
		if (RPGWeapon(Killed.Weapon) != None)
			Killed.Controller.LastPawnWeapon = RPGWeapon(Killed.Weapon).ModifiedWeapon.Class;
		else
			Killed.Controller.LastPawnWeapon = Killed.Weapon.Class;
	}

	if (AbilityLevel == 2)
	{
		if(Killed.Weapon != None)
		{
			OldWeaponHolder = Killed.spawn(class'OldWeaponHolderB',Killed.Controller);
			storeOldWeapon(Killed, Killed.Weapon, OldWeaponHolder);
		}
	}
	else if(AbilityLevel == 3)
	{
		for (Inv = Killed.Inventory; Inv != None; Inv = Inv.Inventory)
			if(Weapon(Inv) != None)
				Weapons[Weapons.length] = Weapon(Inv);

		OldWeaponHolder = Killed.spawn(class'OldWeaponHolderB',Killed.Controller);

		for(x = 0; x < Weapons.length; x++)
			storeOldWeapon(Killed, Weapons[x], OldWeaponHolder);
	}

	Killed.Weapon = None;

	return false;
}

static function storeOldWeapon(Pawn Killed, Weapon Weapon, OldWeaponHolderB OldWeaponHolder)
{
	Local OldWeaponHolderB.WeaponHolder holder;

	if(Weapon == None)
		return;
	
	if(RPGWeapon(Weapon) != None)
	{
		if(instr(caps(string(RPGWeapon(Weapon).ModifiedWeapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}
	else
	{
		if(instr(caps(string(Weapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}

	Weapon.DetachFromPawn(Killed);
	holder.Weapon = Weapon;
	holder.AmmoAmounts1 = Weapon.AmmoAmount(0);
	holder.AmmoAmounts2 = Weapon.AmmoAmount(1);

	OldWeaponHolder.WeaponHolders[OldWeaponHolder.WeaponHolders.length] = holder;

	Killed.DeleteInventory(holder.Weapon);
	//this forces the weapon to stay relevant to the player who will soon reclaim it
	holder.Weapon.SetOwner(Killed.Controller); 
	if (RPGWeapon(holder.Weapon) != None)
		RPGWeapon(holder.Weapon).ModifiedWeapon.SetOwner(Killed.Controller);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local OldWeaponHolderB OldWeaponHolder;
	Local OldWeaponHolderB.WeaponHolder holder;

	if (Other.Role != ROLE_Authority || AbilityLevel < 2)
		return;

	foreach Other.DynamicActors(class'OldWeaponHolderB', OldWeaponHolder)
		if (OldWeaponHolder.Owner == Other.Controller)
		{
			while(OldWeaponHolder.WeaponHolders.length > 0)
			{
				Holder = oldWeaponHolder.WeaponHolders[0];
				if(Holder.Weapon != None)
				{
					Holder.Weapon.GiveTo(Other); //somehow it can be destroyed.
					if(Holder.Weapon == None)
						Continue;
					Holder.Weapon.AddAmmo
					(
						Holder.AmmoAmounts1 - Holder.Weapon.AmmoAmount(0), 
						0
					);
					Holder.Weapon.AddAmmo
					(
						Holder.AmmoAmounts2 - Holder.Weapon.AmmoAmount(1), 
						1
					);
				}
				OldWeaponHolder.WeaponHolders.remove(0, 1);
			}
			OldWeaponHolder.Destroy();
			return;
		}
}

defaultproperties
{
     Level1Cost=15
     Level2Cost=30
     Level3Cost=40
     AbilityName="ÿDenial"
     Description="The first level of this ability simply prevents you from dropping a weapon when you die (but you don't get it either). The second level allows you to respawn with the weapon and ammo you were using when you died. If you are an Adrenaline Master you may buy Level 3, which will save all your weapons when you die. You need to be at least Level 25 to purchase this ability. (Max Level: 2 or 3)|This ability does not trigger for self-inflicted death.|You must be an Adrenaline Master or a Weapons Master to purchase this skill.|Cost (per level): 15,20,20"
     MaxLevel=3
}