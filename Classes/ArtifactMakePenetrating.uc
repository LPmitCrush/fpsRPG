class ArtifactMakePenetrating extends RPGArtifact;

#EXEC OBJ LOAD FILE=fpsRPGTex.utx

var Weapon ActivatedOldWeapon;

function PostBeginPlay ()
{
  Super.PostBeginPlay();
  Disable('Tick');
}

function Activate ()
{
  local Weapon OldWeapon;

  if ( bActive )
  {
    Instigator.ReceiveLocalizedMessage(MessageClass,4000,None,None,Class);
    GotoState('None');
    ActivatedOldWeapon = None;
    return;
  }
  if ( Instigator != None )
  {
    OldWeapon = Instigator.Weapon;
    ActivatedOldWeapon = OldWeapon;
    if ( RPGWeapon(OldWeapon) != None )
    {
      OldWeapon = RPGWeapon(OldWeapon).ModifiedWeapon;
    }
    if ( OldWeapon != None )
    {
      if ( (OldWeapon.Default.FireModeClass[0] != None) && (OldWeapon.Default.FireModeClass[0].Default.AmmoClass != None) && (OldWeapon.AmmoClass[0] != None) && (OldWeapon.AmmoClass[0].Default.MaxAmmo > 0) && Class'MutfpsRPG'.static.IsSuperWeaponAmmo(OldWeapon.Default.FireModeClass[0].Default.AmmoClass) || (OldWeapon.Default.FireModeClass[1] != None) && (OldWeapon.Default.FireModeClass[1].Default.AmmoClass != None) && (OldWeapon.AmmoClass[1] != None) && (OldWeapon.AmmoClass[1].Default.MaxAmmo > 0) && Class'MutfpsRPG'.static.IsSuperWeaponAmmo(OldWeapon.Default.FireModeClass[1].Default.AmmoClass) )
      {
        Instigator.ReceiveLocalizedMessage(MessageClass,3000,None,None,Class);
        GotoState('None');
        ActivatedOldWeapon = None;
        bActive = False;
        return;
      }
      if ( OldWeapon != None )
      {
        bActive = True;
      } else {
        Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
        GotoState('None');
        ActivatedOldWeapon = None;
        bActive = False;
        return;
      }
      RollToInInite();
    }
  }
}

function RollToInInite ()
{
  local Inventory Copy;
  local RPGStatsInv StatsInv;
  local Class<RPGWeapon> NewWeaponClass;
  local Class<Weapon> OldWeaponClass;
  local int X;

  if ( ActivatedOldWeapon == None )
  {
    Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
    GotoState('None');
    ActivatedOldWeapon = None;
    bActive = False;
    return;
  }
  if ( Instigator == None )
  {
    GotoState('None');
    ActivatedOldWeapon = None;
    bActive = False;
    return;
  }
  if ( RPGWeapon(ActivatedOldWeapon) != None )
  {
    if ( RPGWeapon(ActivatedOldWeapon).ModifiedWeapon == None )
    {
      Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
      GotoState('None');
      ActivatedOldWeapon = None;
      bActive = False;
      return;
    }
    OldWeaponClass = RPGWeapon(ActivatedOldWeapon).ModifiedWeapon.Class;
  } else {
    OldWeaponClass = ActivatedOldWeapon.Class;
  }
  if ( OldWeaponClass == None )
  {
    Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
    GotoState('None');
    ActivatedOldWeapon = None;
    bActive = False;
    return;
  }
  NewWeaponClass = Class'RW_Penetrating';
  Copy = Spawn(NewWeaponClass,Instigator,,,rot(0,0,0));
  if ( Copy == None )
  {
    Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
    GotoState('None');
    ActivatedOldWeapon = None;
    bActive = False;
    return;
  }
  StatsInv = RPGStatsInv(Instigator.FindInventoryType(Class'RPGStatsInv'));
  if ( StatsInv != None )
  {
    if ( X < StatsInv.OldRPGWeapons.Length )
    {
      if ( ActivatedOldWeapon == StatsInv.OldRPGWeapons[X].Weapon )
      {
        StatsInv.OldRPGWeapons.Remove (X,1);
      } 
      else 
      {

      }
    }
  }
  if ( RPGWeapon(Copy) == None )
  {
    Instigator.ReceiveLocalizedMessage(MessageClass,2000,None,None,Class);
    GotoState('None');
    ActivatedOldWeapon = None;
    bActive = False;
    return;
  }
  RPGWeapon(Copy).Modifier = 0;
  RPGWeapon(Copy).SetModifiedWeapon(Spawn(OldWeaponClass,Instigator,,,rot(0,0,0)),True);
  if ( ActivatedOldWeapon.IsA('RW_Speedy') )
  {
    RW_Speedy(ActivatedOldWeapon).Deactivate();
  }
  ActivatedOldWeapon.DetachFromPawn(Instigator);
  if ( ActivatedOldWeapon.IsA('RPGWeapon') )
  {
    RPGWeapon(ActivatedOldWeapon).ModifiedWeapon.Destroy();
    RPGWeapon(ActivatedOldWeapon).ModifiedWeapon = None;
  }
  ActivatedOldWeapon.Destroy();
  ActivatedOldWeapon = None;
  Copy.GiveTo(Instigator);
  Destroy();
  Instigator.NextItem();
  ActivatedOldWeapon = None;
  GotoState('None');
  bActive = False;
}

static function string GetLocalString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
  if ( Switch == 2000 )
  {
    return "Unable to create an Penetration Weapon.";
  }
  if ( Switch == 3000 )
  {
    return "Unable to create Penetration on Super Weapons.";
  }
  if ( Switch == 4000 )
  {
    return "your a retard";
  }
}

function bool shouldBreak ()
{
  return Rand(3) == 0;
}

defaultproperties
{
  MinActivationTime=0.00
  IconMaterial=Texture'fpsRPGTex.Modifiers.PenetratingIcon' // Set Icons here
  ItemName="Penetration Maker"
}
