class RW_Speedy extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var Pawn PawnOwner;
var bool active;

var config float SpeedBonus;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	PawnOwner = Other;
	active = false;
	enable('tick');
	super.GiveTo(Other, Pickup);
}

/* Am I just missing something here? If I set this up, it breaks the speed...
function DetachFromPawn(Pawn Instigator)
{
	disable('tick');
	deactivate();
	PawnOwner = None;
	super.DetachFromPawn(Instigator);
}*/

function DropFrom(vector StartLocation)
{
	disable('tick');
	deactivate();
	PawnOwner = None;
	super.DropFrom(StartLocation);
}

function Tick(Float deltaTime)
{
	if(PawnOwner != None)
	{
		if(PawnOwner.Weapon != None && PawnOwner.Weapon == self)
			activate();
		else
		{
			if(PawnOwner.Weapon != None && PawnOwner.Weapon.isA('RW_Speedy'))
				active = false;
			else
				deactivate();
		}
	}
	super.Tick(deltaTime);
}

function activate()
{
	if(active)
		return;
	if(PawnOwner.FindInventoryType(class'FreezeInv') != None)
		return;

	quickfoot(Modifier, PawnOwner);
	active = true;
}

function deactivate()
{
	if(!active)
		return;
	if(PawnOwner.FindInventoryType(class'FreezeInv') != None)
		return;

	PawnOwner.GroundSpeed = PawnOwner.default.GroundSpeed;
	PawnOwner.WaterSpeed = PawnOwner.default.WaterSpeed;
	PawnOwner.AirSpeed = PawnOwner.default.AirSpeed;

	//if they have quickfoot, reactivate it here.
	quickfoot(0, PawnOwner);
	active = false;
}

static function quickfoot(int localModifier, Pawn PawnOwner)
{
	local int x;
	local bool found;
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(PawnOwner.FindInventoryType(class'RPGStatsInv'));
	found = false;

	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		if (StatsInv.Data.Abilities[x] == class'AbilitySpeed')
		{
			found = true;
			break;
		}

	if(!found)
		ModifyPawn(PawnOwner, localModifier);

	else
		ModifyPawn(PawnOwner, StatsInv.Data.AbilityLevels[x] + localModifier);
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	if(AbilityLevel > 0)
	{
		Other.GroundSpeed = Other.default.GroundSpeed * (1.0 + default.SpeedBonus * float(AbilityLevel));
		Other.WaterSpeed = Other.default.WaterSpeed * (1.0 + default.SpeedBonus * float(AbilityLevel));
		Other.AirSpeed = Other.default.AirSpeed * (1.0 + default.SpeedBonus * float(AbilityLevel));
	}
	else if(AbilityLevel < 0)
	{
		Other.GroundSpeed = Other.default.GroundSpeed / (1.0 + default.SpeedBonus * abs(float(AbilityLevel)));
		Other.WaterSpeed = Other.default.WaterSpeed / (1.0 + default.SpeedBonus * abs(float(AbilityLevel)));
		Other.AirSpeed = Other.default.AirSpeed / (1.0 + default.SpeedBonus * abs(float(AbilityLevel)));
	}
	else
	{
		Other.GroundSpeed = Other.default.GroundSpeed;
		Other.WaterSpeed = Other.default.WaterSpeed;
		Other.AirSpeed = Other.default.AirSpeed;
	}
}

defaultproperties
{
     SpeedBonus=1.000000
     ModifierOverlay=Shader'XGameShaders.BRShaders.BombIconBS'
     AIRatingBonus=0.050000
     PostfixPos=" of Quickfoot"
     PostfixNeg=" of Slowfoot"
}
