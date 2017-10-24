//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DroneInv extends Inventory;

var int dlevel;

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
     RemoteRole=ROLE_DumbProxy
}
