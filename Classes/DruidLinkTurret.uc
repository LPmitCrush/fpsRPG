class DruidLinkTurret extends ASTurret_LinkTurret;

var Pawn SaveP;
var RPGStatsInv SavePStats;

simulated event PostBeginPlay()
{
	TurretBaseClass=class'DruidLinkTurretBase';
	TurretSwivelClass=class'DruidLinkTurretSwivel';
	DefaultWeaponClassName=string(class'Weapon_DruidLink');

	super.PostBeginPlay();
}

static function RPGStatsInv GetStatsInvFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if ( Inv.IsA('RPGStatsInv') && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
						   || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);

	//fallback - shouldn't happen
	if (C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'RPGStatsInv');
		if ( Inv != None && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
				      || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);
	}

	return None;
}

function KDriverEnter(Pawn P)
{
	local RPGStatsInv InstigatedStatsInv;
	local Controller C;
	
	C = P.Controller;

	Super.KDriverEnter( P );

	// for sharing xp to work, the RPGStatsInv has to have Instigator set to the Link Turret
	// this is so LinkGun(InstigatorInv.Instigator.Weapon) is not None in RPGRules.ShareExperience
	if (C == None)
		return;
	InstigatedStatsInv = GetStatsInvFor(C);
	if (InstigatedStatsInv != None && InstigatedStatsInv.Instigator != self)
	{
		SaveP = InstigatedStatsInv.Instigator;
		SavePStats = InstigatedStatsInv;
		InstigatedStatsInv.Instigator = self;
	}
	// and make sure the link turret has the weapon selected
	if (Weapon == None)
		C.SwitchToBestWeapon();
}

event bool KDriverLeave( bool bForceLeave )
{
	if (SaveP != None)
	{
		if (SavePStats != None && SavePStats.Instigator == self)
		{
			SavePStats.Instigator = SaveP;
			SaveP = None;
			SavePStats = None;
		}
	}

	return super.KDriverLeave(  bForceLeave );
}

defaultproperties
{
     TurretBaseClass=fpsRPG.DruidLinkTurretBase
     TurretSwivelClass=fpsRPG.DruidLinkTurretSwivel
     DefaultWeaponClassName=""
     VehicleProjSpawnOffset=(X=170.000000)
     bRelativeExitPos=True
     ExitPositions(0)=(Y=100.000000,Z=100.000000)
     ExitPositions(1)=(Y=-100.000000,Z=100.000000)
     EntryRadius=120.000000
     DrawScale=0.200000
     CollisionRadius=60.000000
     CollisionHeight=90.000000
}
