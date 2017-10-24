class RPGWeaponLocker extends WeaponLocker
	notplaceable;

var MutfpsRPG RPGMut;
var WeaponLocker ReplacedLocker; //this is the locker we replaced

var array<RPGWeapon.ChaosAmmoTypeStructClone> ChaosAmmoTypes; // see Touch() for the miracle that goes with this

function Inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local RPGWeapon OldWeapon;
	local RPGStatsInv StatsInv;
	local class<RPGWeapon> NewWeaponClass;
	local int x;
	local bool bRemoveReference;

	if ( Inventory != None )
		Inventory.Destroy();

	//if player previously had a weapon of class InventoryType, force modifier to be the same
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
		for (x = 0; x < StatsInv.OldRPGWeapons.length; x++)
			if (StatsInv.OldRPGWeapons[x].ModifiedClass == InventoryType)
			{
				OldWeapon = StatsInv.OldRPGWeapons[x].Weapon;
				if (OldWeapon == None)
				{
					StatsInv.OldRPGWeapons.Remove(x, 1);
					x--;
				}
				else
				{
					NewWeaponClass = OldWeapon.Class;
					StatsInv.OldRPGWeapons.Remove(x, 1);
					bRemoveReference = true;
					break;
				}
			}

	if (NewWeaponClass == None)
		NewWeaponClass = RPGMut.GetRandomWeaponModifier(class<Weapon>(InventoryType), Other);

	Copy = spawn(NewWeaponClass,Other,,,rot(0,0,0));
	RPGWeapon(Copy).Generate(OldWeapon);
	RPGWeapon(Copy).SetModifiedWeapon(Weapon(spawn(InventoryType,Other,,,rot(0,0,0))), ((bDropped && OldWeapon != None && OldWeapon.bIdentified) || RPGMut.bNoUnidentified));

	Copy.GiveTo(Other, self);

	if (bRemoveReference)
		OldWeapon.RemoveReference();

	return Copy;
}

function Tick(float deltaTime)
{
	local int i;

	//steal attributes from WeaponLocker we replaced
	Weapons = ReplacedLocker.Weapons;
	bSentinelProtected = ReplacedLocker.bSentinelProtected;

	MaxDesireability = 0;

	if (bHidden)
		return;
	for (i = 0; i < Weapons.Length; i++)
		MaxDesireability += Weapons[i].WeaponClass.Default.AIRating;
	SpawnLockerWeapon();

	disable('Tick');
	bStasis = true;
}

auto state LockerPickup
{
	simulated function Touch( actor Other )
	{
		local Weapon Copy, RealWeapon;
		local int i, AmmoIndex;
		local Inventory Inv;
		local Pawn P;
		local Ammunition AmmoCopy;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			P = Pawn(Other);
			if ( (PlayerController(P.Controller) != None) && (Viewport(PlayerController(P.Controller).Player) != None) )
			{
				if ( (Effect != None) && !Effect.bHidden )
					Effect.TurnOff(30);
			}
			if ( Role < ROLE_Authority )
				return;
			if ( !AddCustomer(P) )
				return;
			TriggerEvent(Event, self, P);
			for ( i=0; i<Weapons.Length; i++ )
			{
				InventoryType = Weapons[i].WeaponClass;
				Copy = None;
				for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
					if ( Inv.Class == Weapons[i].WeaponClass
					     || (RPGWeapon(Inv) != None && RPGWeapon(Inv).ModifiedWeapon.Class == Weapons[i].WeaponClass) )
					{
						Copy = Weapon(Inv);
						break;
					}
				if ( Copy != None )
					Copy.FillToInitialAmmo();
				else if ( Level.Game.PickupQuery(P, self) )
				{
					Copy = Weapon(SpawnCopy(P));
					if ( Copy != None )
					{
						Copy.PickupFunction(P);
						if ( Weapons[i].ExtraAmmo > 0 )
							Copy.AddAmmo(Weapons[i].ExtraAmmo, 0);
					}
				}

				//hack for ChaosUT: randomly choose one of the chaos weapon's extra ammo types to give out
				//code ripped right out of ChaosWeaponLocker::GiveChaosWeaponAmmo()
				//except without any references to ChaosUT resources and additions to handle magical weapons
				if (RPGWeapon(Copy) != None)
				{
					RealWeapon = RPGWeapon(Copy).ModifiedWeapon;
				}
				else
				{
					RealWeapon = Copy;
				}
				if (RealWeapon != None && RealWeapon.IsA('ChaosWeapon') && !RealWeapon.bNoAmmoInstances)
				{
					//fill our clone ammo array with a copy of the contents from the weapon's array
					//can you believe this actually works?!
					//I'm still amazed every time I look at it
					SetPropertyText("ChaosAmmoTypes", RealWeapon.GetPropertyText("AmmoType"));

					AmmoIndex = Rand(ChaosAmmoTypes.length);
					if (AmmoIndex != 0)
					{
						InventoryType = ChaosAmmoTypes[AmmoIndex].AmmoClass;
						AmmoCopy = Ammunition(P.FindInventoryType(ChaosAmmoTypes[AmmoIndex].AmmoClass));
						if (AmmoCopy != None)
							AmmoCopy.AddAmmo(AmmoCopy.InitialAmount);
						else if (Level.Game.PickupQuery(P, self))
						{
							AmmoCopy = Ammunition(Super.SpawnCopy(P)); // use Super so we skip the magic weapon code
							if (AmmoCopy != None)
								AmmoCopy.PickupFunction(P);
						}
					}
				}
			}

			AnnouncePickup(P);
		}
	}
}

defaultproperties
{
     bStatic=False
     bGameRelevant=True
     bCollideWorld=False
}
