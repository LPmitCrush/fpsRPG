//Indicates that this pawn has killed at least one enemy
class KillMarker extends Inventory;

function DropFrom(vector StartLocation)
{
	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}
