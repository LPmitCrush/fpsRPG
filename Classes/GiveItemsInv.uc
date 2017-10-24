//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GiveItemsInv extends Inventory;

//client side only
var PlayerController PC;
var Player Player;
var DruidsRPGKeysInteraction DKInteraction;

var DruidsRPGKeysMut KeysMut;
var bool Initialized;
var int tickcount;
struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

replication
{
	reliable if (Role<ROLE_Authority)
		DropHealthPickup, DropAdrenalinePickup;
	reliable if (Role == ROLE_Authority)
		ClientReceiveKeys;
}

function PostBeginPlay()
{
	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		setTimer(5, true);
	super.postBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if(Level.NetMode != NM_DedicatedServer)
		enable('Tick');
	super.PostNetBeginPlay();
}

simulated function Tick(float deltaTime)
{
	local int x;

	if (Level.NetMode == NM_DedicatedServer || DKInteraction != None)
	{
		disable('Tick');
	}
	else
	{
		if (!Initialized)
		{
			tickcount++;
			if (tickcount>10)
				disable('Tick');
			return;
		}

		PC = Level.GetLocalPlayerController();
		if (PC != None)
		{
			Player = PC.Player;
			if(Player != None)
			{
				//first, find out if they have the interaction already.
				
				for(x = 0; x < Player.LocalInteractions.length; x++)
				{
					if(DruidsRPGKeysInteraction(Player.LocalInteractions[x]) != None)
					{
						DKInteraction = DruidsRPGKeysInteraction(Player.LocalInteractions[x]);
					}
				}
				if(DKInteraction == None) //they dont have one
					AddInteraction();
			}
			if(DKInteraction != None)
				disable('Tick');
		}
	}
}


//not done through the interaction master, because that requires a string with a package name.
simulated function AddInteraction()
{
	local int x;

	DKInteraction = new class'DruidsRPGKeysInteraction';

	if (DKInteraction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = DKInteraction;
		DKInteraction.ViewportOwner = Player;

		// Initialize the Interaction

		DKInteraction.Initialize();
		DKInteraction.Master = Player.InteractionMaster;
		
		// now copy the keys over
		DKInteraction.ArtifactKeyConfigs.Length = 0;
		for (x = 0; x < ArtifactKeyConfigs.Length; x++)
		{
			if(ArtifactKeyConfigs[x].Alias != "")
			{
				DKInteraction.ArtifactKeyConfigs.Length = x+1;
				DKInteraction.ArtifactKeyConfigs[x].Alias = ArtifactKeyConfigs[x].Alias;
				DKInteraction.ArtifactKeyConfigs[x].ArtifactClass = ArtifactKeyConfigs[x].ArtifactClass;
			}
		}
	}
	else
		Log("Could not create DruidsRPGKeysInteraction");

} 

function InitializeKeyArray()
{
	// create client side copy of keys
	local int x;

	if(!Initialized)
	{
		if(KeysMut != None)
		{
			for (x = 0; x < KeysMut.ArtifactKeyConfigs.Length; x++)
			{
				if(KeysMut.ArtifactKeyConfigs[x].Alias != "")
				{
					ClientReceiveKeys(x, KeysMut.ArtifactKeyConfigs[x].Alias, KeysMut.ArtifactKeyConfigs[x].ArtifactClass);
				}else
				{
					ClientReceiveKeys(x, "", None);
				}
			}
			ClientReceiveKeys(-1, "", None);
			Initialized = True;
		}
	}
}

simulated function ClientReceiveKeys(int index, string newAliasString, Class<RPGArtifact> newArtifactClass)
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		if (index < 0)
		{
			Initialized = True;
		}
		else
		{
			ArtifactKeyConfigs.Length = index+1;
			ArtifactKeyConfigs[index].Alias = newAliasString;
			ArtifactKeyConfigs[index].ArtifactClass = newArtifactClass;
		}
	}
}

simulated function Destroyed()
{	
	if(DKInteraction != None)
	{
		RemoveInteraction();
	}
	
	super.Destroyed();
}

simulated function RemoveInteraction()
{
	if(Player != None && Player.InteractionMaster != None && DKInteraction != None)
		Player.InteractionMaster.RemoveInteraction(DKInteraction);
	DKInteraction = None;
}

static function DropHealth(Pawn P)
{
	local GiveItemsInv GI;

	if (P == None)
		return;
	if (P.Health <= 25)
		return;

	// ok, lets try it
	GI = GiveItemsInv(P.FindInventoryType(class'GiveItemsInv'));
	if (GI != None)
	{
		GI.DropHealthPickup();
	}
}


function DropHealthPickup()
{
	local vector X, Y, Z;
	local Inventory Inv;
	local int HealthUsed;
	local RPGStatsInv StatsInv;
	local int ab;
	local Pawn PawnOwner;
	local Pickup NewPickup; 

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;

	HealthUsed = class'DruidHealthPack'.default.HealingAmount;

	// ok, now we need to check if this bod has smart healing, to avoid throw and pickup exploit
	for (Inv = PawnOwner.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}
	if (StatsInv == None) //fallback, should never happen
		StatsInv = RPGStatsInv(PawnOwner.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None) //this should always be the case
	{
		for (ab = 0; ab < StatsInv.Data.Abilities.length; ab++)
		{
			if (ClassIsChildOf(StatsInv.Data.Abilities[ab], class'AbilitySmartHealing'))
			{
				HealthUsed += 25 * 0.25 * StatsInv.Data.AbilityLevels[ab];
			}
		}
	}


	if (PawnOwner.Health <= HealthUsed)
		return;

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'DruidHealthPack',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'DruidHealthPack'.default.CollisionRadius) * Normal(Vector(PawnOwner.Controller.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(PawnOwner.Controller.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;

	PawnOwner.Health -= HealthUsed;
	if (PawnOwner.Health <= 0)
		PawnOwner.Health = 1;	// dont kill it by throwing health. Shouldn't really need this, but...
	// no exp for dropping health - too exploitable

}

static function DropAdrenaline(Pawn P)
{
	local GiveItemsInv GI;

	if (P == None)
		return;
	if (P.Health <= 5)
		return;

	// ok, lets try it
	GI = GiveItemsInv(P.FindInventoryType(class'GiveItemsInv'));
	if (GI != None)
	{
		GI.DropAdrenalinePickup();
	}
}


function DropAdrenalinePickup()
{
	local vector X, Y, Z;
	local Pawn PawnOwner;
	local AdrenalinePickup NewPickup; 
	Local XPawn xP;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;
	if (PawnOwner.Controller == None)
		return;
	if (PawnOwner.Controller.Adrenaline < 25)
		return;
	xP = xPawn(PawnOwner);
	if (xP != None && xP.CurrentCombo != None)
		return;		// can't drop while in combo

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'DruidAdrenalinePickup',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'DruidAdrenalinePickup'.default.CollisionRadius) * Normal(Vector(PawnOwner.Controller.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(PawnOwner.Controller.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;
	NewPickup.AdrenalineAmount = 25;
	NewPickup.SetDrawScale(class'AdrenalinePickup'.default.DrawScale * 2);	// bigger cos more adrenaline

	PawnOwner.Controller.Adrenaline -= 25;
	if (PawnOwner.Controller.Adrenaline < 0)
		PawnOwner.Controller.Adrenaline = 0;
	// no exp for dropping health - too exploitable

}

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_AutonomousProxy
}
