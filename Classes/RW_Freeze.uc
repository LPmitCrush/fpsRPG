class RW_Freeze extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var Sound FreezeSound;

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local FreezeInv Inv;
	local Pawn P;
	Local Actor A;

	if (!bIdentified)
		Identify();

	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;

		P = Pawn(Victim);
		if (P != None && canTriggerPhysics(P))
		{
			if (!bIdentified)
				Identify();
		
			Inv = FreezeInv(P.FindInventoryType(class'FreezeInv'));
			//dont add to the time a pawn is already frozen. It just wouldn't be fair.
			if (Inv == None)
			{
				Inv = spawn(class'FreezeInv', P,,, rot(0,0,0));
				Inv.Modifier = Modifier;
				Inv.LifeSpan = Modifier;
				Inv.GiveTo(P);
				if(Victim.isA('Pawn'))
				{
					A = P.spawn(class'IceSmoke', P,, P.Location, P.Rotation);
					if (A != None)
						A.PlaySound(FreezeSound,,2.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
				}
			}
		}
	}
	
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

static function bool canTriggerPhysics(Pawn victim)
{
	local GhostInv gInv;

	if(victim == None)
		return true;

	//cant heal the dead...
	gInv = GhostInv(Victim.FindInventoryType(class'GhostInv'));
	if(gInv != None && !gInv.bDisabled)
		return false;

	if(Victim.PlayerReplicationInfo != None && Victim.PlayerReplicationInfo.HasFlag != None)
		return false;
	
	return true;
}

defaultproperties
{
     FreezeSound=Sound'Slaughtersounds.Machinery.Heavy_End'
     ModifierOverlay=Shader'fpsRPGTex.DomShaders.PulseGreyShader'
     AIRatingBonus=0.025000
     PrefixPos="Freezing "
}
