class Artifact_DWRPGArtifactPickup extends RPGArtifactPickup
   HideDropDown
   NotPlaceable;

var bool bDisallowMultiplePickups;    //Whether we should allow multiple copies of the same artifact to be picked up (ex. Artifact_VariableWeaponGenerator)

var float          PickupSoundVolume; //1 = Standard, 1.2 higher than normal
var Emitter        GlowEffect;
var class<Emitter> GlowEffectClass;


simulated function PostBeginPlay()
{
   Super.PostBeginPlay();

   if ( Level.NetMode != NM_DedicatedServer )
   {
      if ( GlowEffectClass != None )
      {
         GlowEffect = Spawn(GlowEffectClass,self);
         GlowEffect.SetBase(self);
      }
   }
}

simulated function Destroyed()
{
   if ( GlowEffect != None )
      GlowEffect.Destroy();

   Super.Destroyed();
}



//Will also need to adjust ValidTouch in other states where you might pick up this pickup
auto state Pickup
{
   function bool ValidTouch( actor Other )
   {
      local Inventory MyInventory;

      // make sure its a live player
      if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
         return false;

      // make sure not touching through wall
      if ( !FastTrace(Other.Location, Location) )
         return false;

      if (Pawn(Other) != None)
      {
         MyInventory = Pawn(Other).FindInventoryType(InventoryType);
         if (MyInventory != None && MyInventory.class == InventoryType && bDisallowMultiplePickups)
            return false;
      }

      // make sure game will let player pick me up
      if( Level.Game.PickupQuery(Pawn(Other), self) )
      {
         TriggerEvent(Event, self, Pawn(Other));
         return true;
      }
      return false;
   }
}

state Fadeout
{
   function bool ValidTouch( actor Other )
   {
      local Inventory MyInventory;

      // make sure its a live player
      if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
         return false;

      // make sure not touching through wall
      if ( !FastTrace(Other.Location, Location) )
         return false;

      if (Pawn(Other) != None)
      {
         MyInventory = Pawn(Other).FindInventoryType(InventoryType);
         if (MyInventory != None && MyInventory.class == InventoryType && bDisallowMultiplePickups)
            return false;
      }

      // make sure game will let player pick me up
      if( Level.Game.PickupQuery(Pawn(Other), self) )
      {
         TriggerEvent(Event, self, Pawn(Other));
         return true;
      }
      return false;
   }
}

state FallingPickup
{
   function bool ValidTouch( actor Other )
   {
      local Inventory MyInventory;

      // make sure its a live player
      if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
         return false;

      // make sure not touching through wall
      if ( !FastTrace(Other.Location, Location) )
         return false;

      if (Pawn(Other) != None)
      {
         MyInventory = Pawn(Other).FindInventoryType(InventoryType);
         if (MyInventory != None && MyInventory.class == InventoryType && bDisallowMultiplePickups)
            return false;
      }

      // make sure game will let player pick me up
      if( Level.Game.PickupQuery(Pawn(Other), self) )
      {
         TriggerEvent(Event, self, Pawn(Other));
         return true;
      }
      return false;
   }
}

function AnnouncePickup( Pawn Receiver )
{
   Receiver.HandlePickup(self);
   PlaySound( PickupSound,SLOT_Interact, PickupSoundVolume);
}

defaultproperties
{
     bDisallowMultiplePickups=True
     PickupSoundVolume=1.000000
}
