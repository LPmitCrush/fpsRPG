class ArtifactHeal extends RPGArtifact
	config(fpsRPG);



var float TargetRadius;
var int HealExtra, AbilityLevel;
var float HealPoints, HealthGiven;
var xEmitter HealEffectC_L, HealEffectC_R, HealEffectD;
var localized string NotInVehicleMessage;
var RPGRules rules;
var() config float EXPMultiplier, HealthPerAdren;

function Tick(float deltaTime)
{
	if (bActive)
	{
		Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
		HealPoints += deltaTime * CostPerSec;
		if (Instigator.Controller.Adrenaline <= 0.0)
		{
			Instigator.Controller.Adrenaline = 0.0;
			UsedUp();
		}
	}
}


function Activate()
{
	if (Vehicle(Instigator) == None)
		Super.Activate();
	else if (Instigator != None)
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2)
		return Default.NotInVehicleMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}



state Activated
{

	function SpawnEffects()
	{
		HealEffectC_L = Spawn(class'ArtifactHealEffectC',,, Instigator.Location);
		Instigator.AttachToBone(HealEffectC_L, 'Bip01 L Hand');
		HealEffectC_R = Spawn(class'ArtifactHealEffectC',,, Instigator.Location);
		Instigator.AttachToBone(HealEffectC_R, 'Bip01 R Hand');
		HealEffectD = Spawn(class'ArtifactHealEffectD',,, Instigator.Location);
		Instigator.AttachToBone(HealEffectD, 'Bip01');
	}

	function Timer()
	{
		SpawnEffects();
	}

	function BeginState()
	{
		SpawnEffects();
		SetTimer(1, true);
		HealPoints = 0.0;
		bActive = true;

	}

	function EndState()
	{
		local Controller C, NextC;
		local int Targets;
		local float TotalHealthGiven;
		local RPGStatsInv StatsInv;

		spawn(class'ArtifactHealProjectorBase',,, Instigator.Location); // All projectors get summoned here
		spawn(class'ArtifactHealEffectA',,, Instigator.Location);
		spawn(class'ArtifactHealEffectA',,, Instigator.Location);
		spawn(class'ArtifactHealEffectA',,, Instigator.Location);
		spawn(class'ArtifactHealEffectE',,, Instigator.Location+vect(0,0,128));

        HealPoints = HealPoints * HealthPerAdren;

		C = Level.ControllerList;
		while (C != None)
		{
			// get next controller here because C may be destroyed if its a nonplayer and C.Pawn is killed
			NextC = C.NextController;
			if ( C.Pawn != None && (C.Pawn == Instigator || C.SameTeamAs(Instigator.Controller)) && C.Pawn.Health > 0
			     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) )
			{
				C.Pawn.AttachToBone(spawn(class'ArtifactHealEffectB',C.Pawn),'Bip01');

				if (C.Pawn != Instigator)
					if ((C.Pawn.HealthMax + HealExtra - C.Pawn.Health) < HealPoints)
                    {
						TotalHealthGiven+=(C.Pawn.HealthMax + HealExtra - C.Pawn.Health);
						HealthGiven = (C.Pawn.HealthMax + HealExtra - C.Pawn.Health);
					}
					else
                    {
						TotalHealthGiven+=HealPoints;
						HealthGiven = HealPoints; //for showing how much each person is healed.
					}

				C.Pawn.GiveHealth(HealPoints, C.Pawn.HealthMax + HealExtra);
				C.Pawn.SetOverlayMaterial(Shader'fpsRPGTex.DomShaders.PulseBlueShader', 1.0, false);
				PlayerController(C).ReceiveLocalizedMessage(class'ArtifactHealConditionMessage', 0, Instigator.PlayerReplicationInfo);

				Targets++;
			}
			C = NextC;
		}

		setupRules();

		StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None && rules != None)
		{
			rules.ShareExperience(StatsInv, HealthGiven*EXPMultiplier);
		}
		else
		{
			log("Someone probably died while still charging, or something went really wrong");
		}


		SetTimer(0, false);
		bActive = false;
	}

	function setupRules()
	{
		Local GameRules G;
		if(rules != None)
			return;

		if ( Level.Game.GameRulesModifiers == None )
		{
			log("Unable to find RPG Rules. Will retry");
			return;
		}
		else
		{
			for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
			{
				if(G.isA('RPGRules'))
					break;
				if(G.NextGameRules == None)
					log("Unable to find RPG Rules. Will retry"); //well try again later
			}
		}
		rules = RPGRules(G);
	}
}

defaultproperties
{
     TargetRadius=512.000000
     HealExtra=150
     HealPoints=10.000000
     NotInVehicleMessage="Sorry, you can't cast spells from inside a vehicle."
     EXPMultiplier=0.035000
     HealthPerAdren=0.500000
     CostPerSec=10
     MinActivationTime=1.000000
     IconMaterial=Texture'fpsRPGTex.Icons.ArtifactHeal'
     ItemName="Healing Spell"
}
