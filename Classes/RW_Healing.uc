class RW_Healing extends AUDRPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;
	local class<ProjectileFire> ProjFire;
	local RPGStatsInv StatsInv;

	// compatibility hack - old version clients don't have this class, so it's not allowed for them
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None && StatsInv.ClientVersion <= 12)
	{
		return false;
	}
	// if it's a team game, always allowed (no matter what it is player can use it to heal teammates)
	else if (Other.Level.Game.bTeamGame)
	{
		return true;
	}
	else
	{
		//otherwise only allowed on splash damage weapons
		for (x = 0; x < NUM_FIRE_MODES; x++)
			if (!ClassIsChildOf(Weapon.default.FireModeClass[x], class'InstantFire'))
			{
				ProjFire = class<ProjectileFire>(Weapon.default.FireModeClass[x]);
				if (ProjFire == None || ProjFire.default.ProjectileClass == None || ProjFire.default.ProjectileClass.default.DamageRadius > 0)
				{
					return true;
				}
			}
	}

	return false;
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	local int BestDamage;

	BestDamage = Max(Damage, OriginalDamage);
	if (BestDamage > 0)
	{
		P = Pawn(Victim);
		if (P != None && ( P == Instigator
					|| (P.Controller.IsA('FriendlyMonsterController') && FriendlyMonsterController(P.Controller).Master == Instigator.Controller)
					|| (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None) ) )
		{
			if (!bIdentified)
			{
				Identify();
			}
			P.GiveHealth(Max(1, BestDamage * (0.05 * Modifier)), P.HealthMax + 50);
			P.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			Damage = 0;
			//I'd like to give EXP here, but some people would exploit it :(
		}
	}

	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=Shader'fpsRPGTex.DomShaders.PulseBlueShader'
     AIRatingBonus=0.020000
     PrefixPos="Healing "
}
