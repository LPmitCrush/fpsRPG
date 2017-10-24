//When a monster created by the Summoning Charm kills someone, this is placed on them and the death is prevented
//for a tick. This allows us to override the Killer with the monster's Master instead of the monster itself,
//which would otherwise be impossible for monsters with melee attacks.
class FriendlyMonsterKillMarker extends Inventory;

var Controller Killer;
var int Health;
var class<DamageType> DamageType;
var vector HitLocation;

function DropFrom(vector StartLocation)
{
	Destroy();
}

function Tick(float deltaTime)
{
	local Pawn P;

	P = Pawn(Owner);
	if (P != None)
	{
		P.LastHitBy = None; //we've already got our killer, don't want it to get overridden
		P.Health = Health;
		P.Died(Killer, DamageType, HitLocation);
	}

	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_None
}
