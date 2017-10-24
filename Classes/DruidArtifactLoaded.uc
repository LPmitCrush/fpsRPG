class DruidArtifactLoaded extends RPGDeathAbility
	config(fpsRPG) 
	abstract;

var config Array< class<RPGArtifact> > SlowArtifact;
var config Array< class<RPGArtifact> > QuickArtifact;
var config Array< class<RPGArtifact> > ExtraArtifact;
var config Array< class<RPGArtifact> > TeamArtifact;

var config int level1;
var config int level2;
var config int level3;
var config int level4;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassAdrenalineMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	if (CurrentLevel == 0)
		return default.level1;
	if (CurrentLevel == 1)
		return default.level2;
	if (CurrentLevel == 2)
		return default.level3;
	if (CurrentLevel == 3)
		return default.level4;
	return 0;
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int x;
	local LoadedInv LoadedInv;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if(LoadedInv != None)
	{
		if(LoadedInv.type != 'Artifacts' || LoadedInv.AbilityLevel != AbilityLevel)
			LoadedInv.Destroy(); //for when they buy a new level of this skill
		else
			return;
	}

	LoadedInv = Other.spawn(class'LoadedInv');

	if(LoadedInv == None)
		return;

	LoadedInv.type = 'Artifacts';
	LoadedInv.AbilityLevel = AbilityLevel;

	if(AbilityLevel >= 3)
		LoadedInv.ProtectArtifacts = true;
	else
		LoadedInv.ProtectArtifacts = false;

	for(x = 0; x < default.SlowArtifact.length; x++)
		giveArtifact(other, default.SlowArtifact[x]);

	if(AbilityLevel > 1)
		for(x = 0; x < default.QuickArtifact.length; x++)
			giveArtifact(other, default.QuickArtifact[x]);

	if(AbilityLevel > 2)
		for(x = 0; x < default.ExtraArtifact.length; x++)
			giveArtifact(other, default.ExtraArtifact[x]);

	if(AbilityLevel > 3)
		for(x = 0; x < default.TeamArtifact.length; x++)
			giveArtifact(other, default.TeamArtifact[x]);

// I'm guessing that NextItem is here to ensure players don't start with
// no item selected.  So the if should stop wierd artifact scrambles.
	if(Other.SelectedItem == None)
		Other.NextItem();

	LoadedInv.giveTo(Other);
}

static function giveArtifact(Pawn other, class<RPGArtifact> ArtifactClass)
{
	local RPGArtifact Artifact;

	if(Other.IsA('Monster'))
		return;
	if(Other.findInventoryType(ArtifactClass) != None)
		return; //they already have one
		
	Artifact = Other.spawn(ArtifactClass, Other,,, rot(0,0,0));
	if(Artifact != None)
		Artifact.giveTo(Other);
}

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	Local Inventory inv;

// If we end up with some wierdness here, it would be because we haven't
// ejected the player.  However, we shouldn't have to worry about that
// any more; it should be handled elsewhere, if needed.
	if(Killed.isA('Vehicle'))
	{
		Killed = Vehicle(Killed).Driver;
	}
// Wierdness - looks like sometimes PD called twice, particularly in VINV?
// Killed can become "None" somewhere along the line.
	if(Killed == None)
	{
		return;
	}

	for (inv=Killed.Inventory ; inv != None ; inv=inv.Inventory)
	{
		if(ClassIsChildOf(inv.class, class'fpsRPG.RPGArtifact'))
		{
// Important note: *NO* artifact currently in possession will get dropped!
			inv.PickupClass = None;
		}
	}

	return;
}

defaultproperties
{
     SlowArtifact(0)=Class'fpsRPG.ArtifactFlight'
     SlowArtifact(1)=Class'fpsRPG.ArtifactTeleport'
     SlowArtifact(2)=Class'fpsRPG.DruidArtifactSpider'
     SlowArtifact(3)=Class'fpsRPG.DruidArtifactMakeMagicWeapon'
     QuickArtifact(0)=Class'fpsRPG.DruidDoubleModifier'
     QuickArtifact(1)=Class'fpsRPG.DruidMaxModifier'
     QuickArtifact(2)=Class'fpsRPG.DruidPlusOneModifier'
     QuickArtifact(3)=Class'fpsRPG.ArtifactInvulnerability'
     QuickArtifact(4)=Class'fpsRPG.DruidArtifactTripleDamage'
     QuickArtifact(5)=Class'fpsRPG.DruidArtifactLightningRod'
     ExtraArtifact(0)=Class'fpsRPG.ArtifactLightningBolt'
     ExtraArtifact(1)=Class'fpsRPG.ArtifactLightningBeam'
     ExtraArtifact(2)=Class'fpsRPG.ArtifactMegaBlast'
     ExtraArtifact(3)=Class'fpsRPG.ArtifactFreezeBomb'
     ExtraArtifact(4)=Class'fpsRPG.ArtifactPoisonBlast'
     ExtraArtifact(5)=Class'fpsRPG.ArtifactRepulsion'
     TeamArtifact(0)=Class'fpsRPG.ArtifactSphereInvulnerability'
     TeamArtifact(1)=Class'fpsRPG.ArtifactSphereDamage'
     TeamArtifact(2)=Class'fpsRPG.ArtifactRemoteDamage'
     TeamArtifact(3)=Class'fpsRPG.ArtifactRemoteInvulnerability'
     TeamArtifact(4)=Class'fpsRPG.ArtifactRemoteMax'
     level1=2
     level2=9
     level3=16
     level4=9
     AbilityName="Loaded Artifacts"
     Description="When you spawn:|Level 1: You are granted all slow drain artifacts and a magic weapon maker.|Level 2: You are granted all fast drain artifacts and some special artifacts.|Level 3: Your breakable artifacts are made unbreakable, and you get some extra artifacts.|Level 4: You get team artifacts. You must be an Adrenaline Master to purchase this skill.|Cost (per level): 2,9,16,9"
     StartingCost=2
     CostAddPerLevel=7
     MaxLevel=4
}
