class CostRPGAbility extends RPGAbility
	abstract;

var int MinWeaponSpeed;
var int MinHealthBonus;
var int MinShieldBonus;
var int MinAdrenalineMax;
var int MinDB;
var int MinDR;
var int MinAmmo;

var int WeaponSpeedStep;
var int HealthBonusStep;
var int ShieldBonusStep;
var int AdrenalineMaxStep;
var int DBStep;
var int DRStep;
var int AmmoStep;

var int MinPlayerLevel;
var int PlayerLevelStep;
// or
var Array< int > PlayerLevelReqd;

// if LevelCost set, takes precedence over (default.StartingCost + default.CostAddPerLevel * CurrentLevel)
var Array< int > LevelCost;		

var Array<class<RPGAbility> > ExcludingAbilities;	// if you have one of these you cannot purchase
var Array<class<RPGAbility> > RequiredAbilities;	// you must have all of these

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local int ab;
	local bool gotab;
	
	if (Data == None)
		return 0;
	
	// check the stats
	if (Data.WeaponSpeed < default.MinWeaponSpeed + (CurrentLevel * default.WeaponSpeedStep))
		return 0;
	if (Data.HealthBonus < default.MinHealthBonus + (CurrentLevel * default.HealthBonusStep))
		return 0;
	if (Data.ShieldMax < default.MinShieldBonus + (CurrentLevel * default.ShieldBonusStep))
		return 0;
	if (Data.AdrenalineMax < default.MinAdrenalineMax + (CurrentLevel * default.AdrenalineMaxStep))
		return 0;
	if (Data.Attack < default.MinDB + (CurrentLevel * default.DBStep))
		return 0;
	if (Data.Defense < default.MinDR + (CurrentLevel * default.DRStep))
		return 0;
	if (Data.AmmoMax < default.MinAmmo + (CurrentLevel * default.AmmoStep))
		return 0;

	// now check the player level
	if(Data.Level < (default.MinPlayerLevel + CurrentLevel*default.PlayerLevelStep))
		return 0;

	if (default.PlayerLevelReqd.length > CurrentLevel+1)		// since zero based need +1
		if (default.PlayerLevelReqd[CurrentLevel+1] > Data.Level)
			return 0;

	// check if already maxed
	if (CurrentLevel >= default.MaxLevel)
		return 0;
		
	// check for excluding abilities
	for (ab = 0; ab < default.ExcludingAbilities.length; ab++)
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.ExcludingAbilities[ab])
				return 0;
	// now check for required abilities
	for (ab = 0; ab < default.RequiredAbilities.length; ab++)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.RequiredAbilities[ab])
				gotab = true;
		if (!gotab)
			return 0;
	}

	// wow. Can buy
	if (default.LevelCost.length <= CurrentLevel)
		return default.StartingCost + default.CostAddPerLevel * CurrentLevel;
	else
		return default.LevelCost[CurrentLevel+1];
}

defaultproperties
{
     MinAdrenalineMax=100
     AbilityName="Costed RPG Ability"
}
