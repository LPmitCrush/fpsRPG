class RW_Luck extends AUDRPGWeapon
	HideDropDown
	CacheExempt;

var float NextEffectTime;

function Generate(RPGWeapon ForcedWeapon)
{
	Super.Generate(ForcedWeapon);

	if (RW_Luck(ForcedWeapon) != None && RW_Luck(ForcedWeapon).NextEffectTime > 0)
		NextEffectTime = RW_Luck(ForcedWeapon).NextEffectTime;
	else if (Modifier > 0)
		NextEffectTime = float(Rand(15) + 25) / (Modifier + 1);
	else
		NextEffectTime = (1.25 + FRand() * 1.25) / -(Modifier - 1);
}

simulated function WeaponTick(float dt)
{
	local Pickup P;
	local class<Pickup> ChosenClass;
	local vector HitLocation, HitNormal, EndTrace;
	local Actor A;

	Super.WeaponTick(dt);

	if (Role < ROLE_Authority)
		return;

	NextEffectTime -= dt;
	if (NextEffectTime <= 0)
	{
		if (!bIdentified)
			Identify();

		if (Modifier < 0)
		{
			foreach Instigator.CollidingActors(class'Pickup', P, 300)
				if ( P.ReadyToPickup(0) && WeaponLocker(P) == None )
				{
					A = spawn(class'RocketExplosion',,, P.Location);
					if (A != None)
					{
						A.RemoteRole = ROLE_SimulatedProxy;
						A.PlaySound(sound'WeaponSounds.BExplosion3',,2.5*P.TransientSoundVolume,,P.TransientSoundRadius);
					}
					if (!P.bDropped && WeaponPickup(P) != None && WeaponPickup(P).bWeaponStay && P.RespawnTime != 0.0)
						P.GotoState('Sleeping');
					else
						P.SetRespawn();
					break;
				}
			NextEffectTime = (1.25 + FRand() * 1.25) / -(Modifier - 1);
		}
		else
		{
			ChosenClass = ChoosePickupClass();
			EndTrace = Instigator.Location + vector(Instigator.Rotation) * Instigator.GroundSpeed;
			if (Instigator.Trace(HitLocation, HitNormal, EndTrace, Instigator.Location) != None)
			{
				HitLocation -= vector(Instigator.Rotation) * 40;
				P = spawn(ChosenClass,,, HitLocation);
			}
			else
				P = spawn(ChosenClass,,, EndTrace);

			if (P == None)
				return;

			if (MiniHealthPack(P) != None)
				MiniHealthPack(P).HealingAmount *= 2;
			else if (AdrenalinePickup(P) != None)
				AdrenalinePickup(P).AdrenalineAmount *= 2;
			P.RespawnTime = 0.0;
			P.bDropped = true;
			P.GotoState('Sleeping');

			NextEffectTime = float(Rand(15) + 25) / (Modifier + 1);
		}
	}
}

//choose a pickup to spawn, favoring those that are most useful to Instigator
function class<Pickup> ChoosePickupClass()
{
	local array<class<Pickup> > Potentials;
	local Inventory Inv;
	local Weapon W;
	local class<Pickup> AmmoPickupClass;
	local int i, Count;

	if (Instigator.Health < Instigator.HealthMax)
	{
		Potentials[i++] = class'HealthPack';
		Potentials[i++] = class'MiniHealthPack';
	}
	else
	{
		if (Instigator.Health < Instigator.HealthMax + 100)
		{
			Potentials[i++] = class'MiniHealthPack';
			Potentials[i++] = class'MiniHealthPack';
		}
		if (Instigator.ShieldStrength < Instigator.GetShieldStrengthMax())
			Potentials[i++] = class'ShieldPack';
	}
	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		W = Weapon(Inv);
		if (W != None)
		{
			if (W.NeedAmmo(0))
			{
				AmmoPickupClass = W.AmmoPickupClass(0);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
			else if (W.NeedAmmo(1))
			{
				AmmoPickupClass = W.AmmoPickupClass(1);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
		}
		Count++;
		if (Count > 1000)
			break;
	}
	if (FRand() < 0.015 * Modifier)
		Potentials[i++] = class'UDamagePack';
	if (i == 0 || (Instigator.Controller != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax))
		Potentials[i++] = class'AdrenalinePickup';

	return Potentials[Rand(i)];
}

defaultproperties
{
     ModifierOverlay=FinalBlend'MutantSkins.Shaders.MutantGlowFinal'
     AIRatingBonus=0.025000
     PrefixPos="Lucky "
     PostfixNeg=" of Misfortune"
}
