class RW_Experience extends OneDropRPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if (ClassIsChildOf(Weapon, class'ShockRifle') || ClassIsChildOf(Weapon, class'MiniGun') || ClassIsChildOf(Weapon, class'RocketLauncher') || ClassIsChildOf(Weapon, class'ONSMineLayer') || ClassIsChildOf(Weapon, class'LinkGun'))
		return true;


	return false;
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	local RPGStatsInv StatsInv;
	local MutfpsRPG RPGMut;
	local int Health;

	if (!bIdentified)
		Identify();

	if(Victim != Instigator && Pawn(Victim) != None && (Pawn(Victim).GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None) )
		return;

      if(Victim == Instigator)
           return;

	Health = int(float(Damage) * (0.1 * abs(Modifier)));
	if (Health == 0)
		Health = 1;
	if (Health > 10)
		Health = 10 * Modifier;

			RPGMut = class'MutfpsRPG'.static.GetRPGMutator(Level.Game);
			P = Instigator;
			StatsInv = RPGStatsInv(P.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
				return;

			StatsInv.DataObject.Experience += health;
			RPGMut.CheckLevelUp(StatsInv.DataObject, P.PlayerReplicationInfo);
			
   Super.AdjustTargetDamage(Damage,Victim,Hitlocation,Momentum,DamageType);
}

defaultproperties
{
     ModifierOverlay=Combiner'fpsRPGTex.DomShaders.ExperiencePickupInner'
     PostfixPos=" of Experience"
}
