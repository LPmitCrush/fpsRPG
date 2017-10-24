//Holder for a pawn's old weapon
//Used by AbilityNoWeaponDrop to keep a pawn's active weapon and ammo after the pawn dies
class OldWeaponHolder extends Actor;

var Weapon Weapon;
var int AmmoAmounts[2];

function PostBeginPlay()
{
	SetTimer(1.0, true);

	Super.PostBeginPlay();
}

function Timer()
{
	if (Controller(Owner) == None || Weapon == None)
		Destroy();
}

function Destroyed()
{
	if (Weapon != None)
		Weapon.Destroy();

	Super.Destroyed();
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
