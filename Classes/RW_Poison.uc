class RW_Poison extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var RPGRules RPGRules;

var config int PoisonLifespan;

function PostBeginPlay()
{
	Local GameRules G;
	super.PostBeginPlay();
	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			RPGRules = RPGRules(G);
			break;
		}
	}

	if(RPGRules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local PoisonInv Inv;
	local Pawn P;

	if (DamageType == class'DamTypePoison' || Damage <= 0)
		return;

	P = Pawn(Victim);
	if (P != None)
	{
		if (!bIdentified)
			Identify();

		Inv = PoisonInv(P.FindInventoryType(class'PoisonInv'));
		if (Inv == None)
		{
			Inv = spawn(class'PoisonInv', P,,, rot(0,0,0));
			Inv.Modifier = Modifier;
			Inv.LifeSpan = PoisonLifespan;
			Inv.GiveTo(P);
		}
		else
		{
			Inv.Modifier = Modifier;
			Inv.LifeSpan = PoisonLifespan;
		}
	}
	
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     PoisonLifespan=3
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.LinkHit'
     AIRatingBonus=0.020000
     PrefixPos="Poisoned "
}
