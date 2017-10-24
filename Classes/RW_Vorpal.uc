class RW_Vorpal extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var config array<class<DamageType> > IgnoreDamageTypes;


static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if ( ClassIsChildOf(Weapon, class'ShieldGun') || ClassIsChildOf(Weapon, class'SniperRifle') || ClassIsChildOf(Weapon, class'ONSAVRiL') || ClassIsChildOf(Weapon, class'ShockRifle') || ClassIsChildOf(Weapon, class'ClassicSniperRifle'))
		return true;

	if(instr(caps(string(Weapon)), "AVRIL") > -1)//hack for vinv avril
		return true;

	return false;
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local int Chance, i;
	local Actor A;

	for(i = 0; i < IgnoreDamageTypes.length; i++)
		if(DamageType == IgnoreDamageTypes[i])
			return; //hack to work around vorpal redeemer exploit.

	if (!bIdentified)
		Identify();

	if(Victim == None)
		return; //nothing to do

	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	Chance = Modifier - MinModifier;

	if(Damage > 0 && Chance >= rand(99))
	{
		//this is a vorpal hit. Frag them.

		//fire the sound

		if(Victim != None && Victim.isA('Monster'))
		{
			A = spawn(class'RocketExplosion',,, Instigator.Location);
			if (A != None)
			{
				A.RemoteRole = ROLE_SimulatedProxy;
				A.PlaySound(sound'WeaponSounds.Misc.instagib_rifleshot',,2.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
			}
			
			if(Victim != None)
				Pawn(Victim).Died(Instigator.Controller, DamageType, Victim.Location);
				
			if(Victim != None)
			{
				A = spawn(class'RocketExplosion',,, Victim.Location);
				
				if (A != None)
				{
					A.RemoteRole = ROLE_SimulatedProxy;
					A.PlaySound(sound'WeaponSounds.Misc.instagib_rifleshot',,2.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
				}
			}
		}
	}
	
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     IgnoreDamageTypes(0)=Class'XWeapons.DamTypeRedeemer'
     IgnoreDamageTypes(1)=Class'XWeapons.DamTypeIonBlast'
     ModifierOverlay=Shader'XGameShaders.BRShaders.BombIconYS'
     AIRatingBonus=0.080000
     PrefixPos="Vorpal "
}
