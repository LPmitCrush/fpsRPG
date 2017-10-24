class ArtifactDoubleModifier extends RPGArtifact;

var Pawn RealInstigator;
var RPGWeapon Weapon;
var bool oldCanThrow;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
		Activate();
	else if ( !bActive && Instigator.Controller.Enemy != None && Instigator.Weapon != None && Instigator.Weapon.AIRating > 0.5
		  && Instigator.Controller.Enemy.Health > 70 && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

function Activate()
{
	Local ArtifactTripleDamageB trip;
	trip = ArtifactTripleDamageB(Instigator.findInventoryType(class'ArtifactTripleDamageB'));
	if(trip != None && trip.bActive)
		return;

	if (!bActive && Instigator.HasUDamage())
		return;

	Super.Activate();
}

state Activated
{
	function BeginState()
	{
		if(bActive)
			return;
		setTimer(0.1, true);
		beginWeapon();
		bActive = true;
	}
	
	function BeginWeapon()
	{
		local Vehicle V;

		if(Weapon != None)
			return; // something is already running.

		V = Vehicle(Instigator);
		if (V != None && V.Driver != None)
			RealInstigator = V.Driver;
		else
			RealInstigator = Instigator;

		Weapon = RPGWeapon(RealInstigator.Weapon);
		if (Weapon != None)
		{
			if(Weapon.isA('RW_Speedy'))
				(RW_Speedy(Weapon)).deactivate();
			Weapon.Modifier = Weapon.Modifier * 2;
			oldCanThrow = Weapon.bCanThrow;
			Weapon.bCanThrow = false;
			if(Weapon.isA('RW_Speedy'))
				(RW_Speedy(Weapon)).activate();
			IdentifyWeapon(Weapon);
		}
	}
	
	function Timer()
	{
		if(Instigator.HasUDamage())
		{
			GotoState('');
			bActive=false;
			return;
		}
		if(Instigator != None && Instigator.Weapon != None && Instigator.Weapon != Weapon)
		{
			EndWeapon();
			BeginWeapon();
		}
	}

	function EndState()
	{
		setTimer(0, true);
		EndWeapon();
		bActive = false;
	}
	
	function EndWeapon()
	{
		if(Weapon != None)
		{
			if(Weapon.isA('RW_Speedy'))
				(RW_Speedy(Weapon)).deactivate();
			Weapon.Modifier = Weapon.Modifier/2;
			Weapon.bCanThrow = oldCanThrow;

			if(Weapon.isA('RW_Speedy'))
				(RW_Speedy(Weapon)).activate();
			IdentifyWeapon(Weapon);
		}
		Weapon = None;
	}
}

function IdentifyWeapon(RPGWeapon weapon)
{
	local WeaponIdentifierInv inv;
	
	inv = Instigator.spawn(class'WeaponIdentifierInv');
	inv.Weapon = Weapon;
	inv.giveTo(Instigator);
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
     CostPerSec=10
     IconMaterial=TexPanner'XGameShaders.PlayerShaders.PlayerTransPanRed'
     ItemName="Double Modifier"
}
