class DruidLoaded extends RPGAbility
	config(fpsRPG) 
	abstract;

var config Array< String > Weapons;
var config Array< String > ONSWeapons;
var config Array< String > SuperWeapons;

var config int MinLev2, MinLev3;

static function bool AbilityIsAllowed(GameInfo Game, MutfpsRPG RPGMut)
{
	if(RPGMut.WeaponModifierChance == 0)
		return false;

	return true;
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassWeaponsMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	if(Data.Level < default.MinLev2 && CurrentLevel > 0)
		return 0;
	if(Data.Level < default.MinLev3 && CurrentLevel > 1)
		return 0;

	return Super.Cost(Data, CurrentLevel);
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Mutator m;
	local MutfpsRPG RPGMut;
	local int x;
	local LoadedInv LoadedInv;
	local Inventory OInv;
	local Inventory SG;
	local Inventory AR;

	for (m = Other.Level.Game.BaseMutator; m != None; m = m.NextMutator)
		if (MutfpsRPG(m) != None)
		{
			RPGMut = MutfpsRPG(M);
			break;
		}

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if(LoadedInv != None)
	{
		if(LoadedInv.type != 'Weapons' || LoadedInv.AbilityLevel != AbilityLevel)
			LoadedInv.Destroy(); //for when they buy a new level of this skill
		else
			return;
	}
	LoadedInv = Other.spawn(class'LoadedInv');

	if(LoadedInv == None)
		return;

	LoadedInv.type = 'Weapons';
	LoadedInv.AbilityLevel = AbilityLevel;
	LoadedInv.ProtectArtifacts = false;

	for (OInv=Other.Inventory ; OInv != None && (SG == None || AR == None) ; OInv=OInv.Inventory)
	{
// You can't delete within the for, as Deleting results in OInv == None, so
// the AR is never found.  Instead, grab them both in their own var ...
		if(instr(caps(OInv.ItemName), "SHIELD GUN") > -1)
		{
			SG=OInv;
		}
		if(instr(caps(OInv.ItemName), "ASSAULT RIFLE") > -1)
		{
			AR=OInv;
		}
	}

// This stops the client from erroneously deleting the SG and AR - like
// after a ghost, getting into and out of a vehicle ... all those dumb
// cases where the client likes to run ModifyPawn when it probably
// shouldn't.
	if(Other.Role == ROLE_Authority)
	{
// And delete them after they're both found.
		if(SG != None && LoadedInv != None)
			Other.DeleteInventory(SG);
		if(AR != None && LoadedInv != None)
			Other.DeleteInventory(AR);
	}

	for(x = 0; x < default.Weapons.length; x++)
		giveWeapon(Other, default.Weapons[x], AbilityLevel, RPGMut);
	for(x = 0; AbilityLevel >= 2 && x < default.ONSWeapons.length; x++)
		giveWeapon(Other, default.ONSWeapons[x], AbilityLevel, RPGMut);
	for(x = 0; Other.Level.Game.IsA('Invasion') && AbilityLevel >= 3 && x < default.SuperWeapons.length; x++)
		giveWeapon(Other, default.SuperWeapons[x], AbilityLevel, RPGMut);
	LoadedInv.giveTo(Other);
}

static function giveWeapon(Pawn Other, String oldName, int AbilityLevel, MutfpsRPG RPGMut)
{
	Local string newName;
	local class<Weapon> WeaponClass;
	local class<RPGWeapon> RPGWeaponClass;
	local Weapon NewWeapon;
	local RPGWeapon RPGWeapon;
	local int x;

	if(Other.IsA('Monster'))
		return;

	if(oldName == "")
		return;

	newName = Other.Level.Game.BaseMutator.GetInventoryClassOverride(oldName);
	WeaponClass = class<Weapon>(Other.DynamicLoadObject(newName, class'Class'));
	newWeapon = Other.spawn(WeaponClass, Other,,, rot(0,0,0));
	if(newWeapon == None)
		return;
	while(newWeapon.isA('RPGWeapon'))
		newWeapon = RPGWeapon(newWeapon).ModifiedWeapon;

	if(AbilityLevel >= 4)
		RPGWeaponClass = GetRandomWeaponModifier(WeaponClass, Other, RPGMut);
	else
		RPGWeaponClass = RPGMut.GetRandomWeaponModifier(WeaponClass, Other);

	RPGWeapon = Other.spawn(RPGWeaponClass, Other,,, rot(0,0,0));
	if(RPGWeapon == None)
		return;
	RPGWeapon.Generate(None);
	
	//I'm checking the state of RPG Weapon a bunch because sometimes it becomes none mid method.
	if(RPGWeapon == None)
		return;

	if(AbilityLevel >= 5)
	{
			for(x = 0; x < 50; x++)
			{
				if(RPGWeapon.Modifier > -1)
					break;
				RPGWeapon.Generate(None);
				if(RPGWeapon == None)
					return;
			}
	}

	if(RPGWeapon == None)
		return;

	RPGWeapon.SetModifiedWeapon(newWeapon, true);

	if(RPGWeapon == None)
		return;

	RPGWeapon.GiveTo(Other);

	if(RPGWeapon == None)
		return;

	if(AbilityLevel == 1)
	{
		RPGWeapon.FillToInitialAmmo();
	}
	else if(AbilityLevel > 1)
	{
		if (oldName == "XWeapons.AssaultRifle")
		{
			RPGWeapon.Loaded();
		}
		RPGWeapon.MaxOutAmmo();
	}
}

static function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other, MutfpsRPG RPGMut)
{
	local int x, Chance;

	Chance = Rand(RPGMut.TotalModifierChance);
	for (x = 0; x < RPGMut.WeaponModifiers.Length; x++)
	{
		Chance -= RPGMut.WeaponModifiers[x].Chance;
		if (Chance < 0 && RPGMut.WeaponModifiers[x].WeaponClass.static.AllowedFor(WeaponType, Other))
			return RPGMut.WeaponModifiers[x].WeaponClass;
	}

	return class'RPGWeapon';
}

defaultproperties
{
     Weapons(0)="XWeapons.RocketLauncher"
     Weapons(1)="XWeapons.ShockRifle"
     Weapons(2)="fpsRPG.RPGLinkGun"
     Weapons(3)="XWeapons.SniperRifle"
     Weapons(4)="XWeapons.FlakCannon"
     Weapons(5)="XWeapons.MiniGun"
     Weapons(6)="XWeapons.BioRifle"
     Weapons(7)="XWeapons.ShieldGun"
     Weapons(8)="XWeapons.AssaultRifle"
     ONSWeapons(0)="UTClassic.ClassicSniperRifle"
     ONSWeapons(1)="Onslaught.ONSGrenadeLauncher"
     ONSWeapons(2)="Onslaught.ONSAVRiL"
     ONSWeapons(3)="Onslaught.ONSMineLayer"
     SuperWeapons(0)="XWeapons.Redeemer"
     SuperWeapons(1)="XWeapons.Painter"
     MinLev2=40
     MinLev3=55
     AbilityName="Loaded Weapons"
     Description="When you spawn:|Level 1: You are granted all regular weapons with the default percentage chance for magic weapons.|Level 2: You are granted onslaught weapons and all weapons with max ammo.|Level 3: You are granted super weapons (Invasion game types only).|Level 4: Magic weapons will be generated for all your weapons.|Level 5: You receive all positive magic weapons.|You must be a Weapons Master to purchase this skill.|You must be level 40 before you can buy level 2 and level 55 before you can buy level 3.|Cost (per level): 10,15,20,25,30"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=5
}
