class AdjustCost extends RPGAbility
	abstract
	config(fpsRPG);

var config int AdjustableStartingCost, AdjustableCostAddPerLevel, AdjustableMaxLevel;

static simulated function int AdjustCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	return AdjustTheCost(default.AdjustableStartingCost, default.AdjustableCostAddPerLevel, default.AdjustableMaxLevel, default.StartingCost, default.CostAddPerLevel, default.MaxLevel, Data, CurrentLevel);
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	return AdjustTheCost(default.AdjustableStartingCost, default.AdjustableCostAddPerLevel, default.AdjustableMaxLevel, default.StartingCost, default.CostAddPerLevel, default.MaxLevel, Data, CurrentLevel);
}

//Method exposed so that other classes that cant inherit from this one can still use this functionality
static simulated function int AdjustTheCost(int AdjustableStartingCost, int AdjustableCostAddPerLevel, int AdjustableMaxLevel, int StartingCost, int CostAddPerLevel, int MaxLevel, RPGPlayerDataObject Data, int CurrentLevel)
{
	local int lrv;
	local int lmaximumLevel;
	local int lcostPerLevel;

	if(AdjustableStartingCost == 0)
		lrv = StartingCost;
	else
		lrv = AdjustableStartingCost;

	if(AdjustableMaxLevel == 0)
		lmaximumLevel = MaxLevel;
	else
		lmaximumLevel = AdjustableMaxLevel;

	if(AdjustableCostAddPerLevel == 0)
		lCostPerLevel = CostAddPerLevel;
	else
		lCostPerLevel = AdjustableCostAddPerLevel;

	if (CurrentLevel < lMaximumLevel)
		return lrv + (lCostPerLevel * CurrentLevel);
	else
		return 0;
}

defaultproperties
{
}
