class ArtifactResurrection extends RPGArtifact;



var Emitter myEmitter;
var float AdrenalineUsed;

function RPGStatsInv GetStatsInvFor (Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	Inv = C.Inventory;
	if ( Inv != None )
	{
		if(Inv.IsA('RPGStatsInv') && ((!bMustBeOwner || Inv.Owner == C) || Inv.Owner == C.Pawn) || (Vehicle(C.Pawn) != none) && Inv.Owner == Vehicle(C.Pawn).Driver)
		{
			return RPGStatsInv(Inv);
		}
		Inv = Inv.Inventory;
	}
	if ( C.Pawn != None )
	{
		Inv = C.Pawn.FindInventoryType(Class'RPGStatsInv');
		if((Inv != none) && ((!bMustBeOwner || Inv.Owner == C) || Inv.Owner == C.Pawn) || (Vehicle(C.Pawn) != none) && Inv.Owner == Vehicle(C.Pawn).Driver)
		{
			return RPGStatsInv(inv);
		}
	}
	return None;
}

state Activated
{
	function BeginState()
	{


		local int x;

		myEmitter = spawn(class'ResurrectionEffect', Instigator,, Instigator.Location, Instigator.Rotation);
		myEmitter.SetBase(Instigator);
		if (Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None && Instigator.PlayerReplicationInfo.Team.TeamIndex == 1)
			for (x = 0; x < myEmitter.Emitters[0].ColorScale.Length; x++)
				myEmitter.Emitters[0].ColorScale[x].Color = class'Hud'.default.BlueColor;

		bActive = true;
		AdrenalineUsed = CostPerSec;
	}

	simulated function Tick(float deltaTime)
	{
		local float Cost;

		Cost = FMin(AdrenalineUsed, deltaTime * CostPerSec);
		AdrenalineUsed -= Cost;
		if (AdrenalineUsed <= 0.0)
		{
			//take the last bit of adrenaline from the player
			//add a tiny bit extra to fix float precision issues
			Instigator.Controller.Adrenaline -= Cost - 0.01;
			DoEffect();
		}
		else
		{
			Global.Tick(deltaTime);
		}
	}

	function DoEffect()
	{
            Local MutfpsRPG RPGMut;
	        Local Controller PersonToRez;
       		Local int PlayerLevel;
       		Local RPGStatsInv StatsInv;
       		local int EffectNum;

   		PersonToRez = PickTheOne();
   		RPGMut = Class'MutfpsRPG'.static.GetRPGMutator(Instigator.Level.Game);
                StatsInv = RPGMut.GetStatsInvFor(Instigator.Controller);
		PlayerLevel = StatsInv.DataObject.Level;


    		if (PersonToRez != None)
    		{
      		   PersonToRez.PlayerReplicationInfo.bOutOfLives = false;
     		   PersonToRez.PlayerReplicationInfo.NumLives = 0;
      		   Level.Game.RestartPlayer(PersonToRez);
     		   PersonToRez.ServerReStartPlayer();

      		   PlayerController(PersonToRez).PlayerReplicationInfo.SetWaitingPlayer(false);
      		   PlayerController(PersonToRez).ClientSetViewTarget(PersonToRez);
     	           PlayerController(PersonToRez).ClientSetBehindView(false);//bBehindView);
		   Level.Game.Broadcast(PersonToRez, PersonToRez.PlayerReplicationInfo.PlayerName$" was resurrected by"@Instigator.PlayerReplicationInfo.PlayerName$"!!!");


                     if( PersonToRez != None && PlayerLevel >= 200)
	 	       {
                          PersonToRez.Pawn.SetLocation(Instigator.Location + vect(50,50,50));
                          if (xPawn(PersonToRez.Pawn) != None)
                             if (PersonToRez.Pawn.PlayerReplicationInfo != None && PersonToRez.Pawn.PlayerReplicationInfo.Team != None)
                                 EffectNum = PersonToRez.Pawn.PlayerReplicationInfo.Team.TeamIndex;
				 PersonToRez.Pawn.SetOverlayMaterial(class'TransRecall'.default.TransMaterials[EffectNum], 1.0, false);
				 PersonToRez.Pawn.PlayTeleportEffect(false, false);
                       }
		}

		   GotoState('');
	}

	function EndState()
	{
		if (myEmitter != None)
			myEmitter.Destroy();
		bActive = false;
	}
}


function Controller PickTheOne()
{
  local Controller LastPickedOne;
  local Controller P;

  LastPickedOne = None;

  for ( P = Level.ControllerList; P != None; P = P.nextController )
  {
    if ((P != None && P.PlayerReplicationInfo != None) && (P.IsA('PlayerController') || P.PlayerReplicationInfo.bBot))
    {
      if (P.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) //check team (if player team equal to my team)
      {
        if (Instigator.PlayerReplicationInfo.PlayerName != P.PlayerReplicationInfo.PlayerName)
        {
          if (P.PlayerReplicationInfo.bOutOfLives && !P.PlayerReplicationInfo.bOnlySpectator)

          { 
              LastPickedOne = P;
            }
          }
        }
      }
    }
  return LastPickedOne;
}

defaultproperties
{
     CostPerSec=200
     MinActivationTime=1.00
     PickupClass=Class'fpsRPG.ArtifactResurrectionPickup'
     IconMaterial=Texture'fpsRPGTex.Icons.Resurrection'
     ItemName="Resurrection"
}