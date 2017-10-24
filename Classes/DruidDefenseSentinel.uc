class DruidDefenseSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

var int ShieldHealingLevel;
var int HealthHealingLevel;
var int AdrenalineHealingLevel;
var int ResupplyLevel;
var int ArmorHealingLevel;
var float SpiderBoostLevel;

var config float HealthHealingAmount;       // the amount of health the defense sentinel heals per level (% of max health)
var config float ShieldHealingAmount;		// the amount of shield the defense sentinel heals per level (% of max shield)
var config float AdrenalineHealingAmount;	// the amount of adrenaline the defense sentinel heals per level (% of max adrenaline)
var config float ResupplyAmount;			// the amount of resupply the defense sentinel heals per level (% of max ammo)
var config float ArmorHealingAmount;		// the amount of armor the defense sentinel heals per level (% of max adrenaline)

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
	HealthHealingAmount=1.000000
	ShieldHealingAmount=1.000000
	AdrenalineHealingAmount=1.000000
	ResupplyAmount=1.000000
	ArmorHealingAmount=1.000000
    TurretBaseClass=Class'fpsRPG.DruidDefenseSentinelBase'
    DefaultWeaponClassName=""
    VehicleNameString="Defense Sentinel"
    bCanBeBaseForPawns=False
    Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
    DrawScale=0.500000
    AmbientGlow=10
    CollisionRadius=0.000000
    CollisionHeight=0.000000
}
