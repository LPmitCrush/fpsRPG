class AbilityLoadedMonsters extends RPGAbility
	config(fpsRPG)
	abstract;

struct MonsterConfig
{
	Var String FriendlyName;
	var Class<Monster> Monster;
	var int Adrenaline;
	var int MonsterPoints;
	var int Level;
};

var config Array<MonsterConfig> MonsterConfigs;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassMonsterMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return super.Cost(Data, CurrentLevel);
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int i;
	local LoadedInv LoadedInv;
	Local RPGArtifact Artifact;
	Local bool PreciseLevel;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if(LoadedInv != None)
	{
		if(LoadedInv.type != 'Monsters')
		{
			LoadedInv.Destroy(); 
		}
		else if(LoadedInv.AbilityLevel != AbilityLevel)
		{
			LoadedInv.Destroy();//for when they buy a new level of this skill
			PreciseLevel = true; //only giving artifacts for this level.
		}
		else
		{
			return;
		}
	}

	LoadedInv = Other.spawn(class'LoadedInv');

	if(LoadedInv == None)
		return;

	LoadedInv.type = 'Monsters';
	LoadedInv.AbilityLevel = AbilityLevel;
	LoadedInv.GiveTo(Other);

	for(i = 0; i < Default.MonsterConfigs.length; i++)
	{
		if(Default.MonsterConfigs[i].Monster != None) //make sure the object is sane.
		{
			if(PreciseLevel && Default.MonsterConfigs[i].Level != AbilityLevel) //checkertrap for purchases during a game.
				continue;
			if(Default.MonsterConfigs[i].Level <= AbilityLevel)
			{
				Artifact = Other.spawn(class'DruidMonsterMasterArtifactMonsterSummon', Other,,, rot(0,0,0));
				if(Artifact == None)
					continue; // wow.
				DruidMonsterMasterArtifactMonsterSummon(Artifact).Setup(Default.MonsterConfigs[i].FriendlyName, Default.MonsterConfigs[i].Monster, Default.MonsterConfigs[i].Adrenaline, Default.MonsterConfigs[i].MonsterPoints);
				Artifact.GiveTo(Other);
			}
		}
	}

	if(!PreciseLevel)
	{
		Artifact = Other.spawn(class'ArtifactKillAllPets', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
		Artifact = Other.spawn(class'ArtifactKillOnePet', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}
// I'm guessing that NextItem is here to ensure players don't start with
// no item selected.  So the if should stop wierd artifact scrambles.
	if(Other.SelectedItem == None)
		Other.NextItem();
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	// need to check that summoned monsters do not get xp for not doing damage to same species
	if(!bOwnedByInstigator || Instigator == None || Monster(Instigator) == None || Injured == None || Monster(Injured) == None)
		return;
		
	// now know this is damage done by a monster
	if ( Monster(Injured).SameSpeciesAs(Instigator) )
		Damage = 0;
}

defaultproperties
{
     MonsterConfigs(0)=(FriendlyName="Pupae",Monster=Class'SkaarjPack.SkaarjPupae',Adrenaline=15,MonsterPoints=1,Level=1)
     AbilityName="Loaded Monsters"
     Description="Learn new monsters to summon with Monster Points. At each level, you can summon a better monster. (Max Level: 15)|You must be a Monster Master to purchase this skill.|Cost (per level): 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16"
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=15
}
