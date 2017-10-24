class RW_Protection extends AUDRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var config int HealthCap;
var config float ProtectionRepeatLifespan;

function AdjustPlayerDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	Local ProtectionInv inv;
	if (!bIdentified)
		Identify();

	Damage -= Damage * (0.01 * Modifier);
	
	if(Damage < 0)
	   Damage = 1;

	Super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

	if(Modifier > 0 && Damage >= Instigator.Health && Instigator.Health > HealthCap)
	{
		inv = ProtectionInv(Instigator.FindInventoryType(class'ProtectionInv'));
		if(Inv == None)
		{
			Damage = Instigator.Health - 1; //help protect them for the first shot Damage reduction still applies though.
			inv = spawn(class'ProtectionInv', Instigator,,, rot(0,0,0));
			inv.Lifespan = (ProtectionRepeatLifespan / float(Modifier));
			if(inv != None)
				inv.giveTo(Instigator);
		}
	}
}

defaultproperties
{
     HealthCap=10
     ProtectionRepeatLifespan=6.000000
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerShieldSh'
     AIRatingBonus=0.040000
     PostfixPos=" of Protection"
     PostfixNeg=" of Harm"
}
