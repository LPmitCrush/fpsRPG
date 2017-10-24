class AbilityLoadedArtifacts extends AdjustCost
	config(fpsRPG) 
	abstract;

var config Array< class<RPGArtifact> > Level1;
var config Array< class<RPGArtifact> > Level2;
var config Array< class<RPGArtifact> > Level3;
var config Array< class<RPGArtifact> > Level4;
var config Array< class<RPGArtifact> > Level5;

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

	return Super.Cost(Data, CurrentLevel);
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
		LoadedInv.ProtectMaker = true;
	else
		LoadedInv.ProtectArtifacts = false;

	if(AbilityLevel > 0)
		for(x = 0; x < default.Level1.length; x++)
			giveArtifact(other, default.Level1[x]);
	if(AbilityLevel > 1)
		for(x = 0; x < default.Level2.length; x++)
			giveArtifact(other, default.Level2[x]);
	if(AbilityLevel > 2)
		for(x = 0; x < default.Level3.length; x++)
			giveArtifact(other, default.Level3[x]);
	if(AbilityLevel > 3)
		for(x = 0; x < default.Level4.length; x++)
			giveArtifact(other, default.Level4[x]);
	if(AbilityLevel > 4)
		for(x = 0; x < default.Level5.length; x++)
			giveArtifact(other, default.Level5[x]);
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

defaultproperties
{
     Level1(0)=Class'fpsRPG.ArtifactFlight'
     Level1(1)=Class'fpsRPG.ArtifactTeleport'
     Level1(2)=Class'fpsRPG.ArtifactSpider'
     Level2(0)=Class'fpsRPG.ArtifactLightningRodB'
     Level2(1)=Class'fpsRPG.ArtifactTripleDamageB'
     Level2(2)=Class'fpsRPG.Artifact_GlobeInvulnerability'
     Level3(0)=Class'fpsRPG.ArtifactSuperMakeMagicWeapon'
     Level4(0)=Class'fpsRPG.ArtifactSphereDamage'
     Level5(0)=Class'fpsRPG.ArtifactSphereInvulnerability'
     AbilityName="ÿ¥Loaded Artifacts"
     Description="When you spawn:|Level 1: You are granted some slow drain artifacts.|Level 2: You are granted all slow drain artifacts.|Level 3: Your breakable artifacts are made unbreakable and are given Super Magic Weapon Maker|Level 4: You are given Sphere Damage|Level 5: You are fully loaded with a Safety Sphere|Cost: 15,10,25,30,35|Max Level: 5"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=5
}
