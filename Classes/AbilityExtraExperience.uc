Class AbilityExtraExperience extends RPGAbility
                abstract;


static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
                 if(Data.Level < (0.5*CurrentLevel))
                               return 0;

	return Super.Cost(Data, CurrentLevel);
}
                
static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
     local RPGPlayerDataObject Data;
     local RPGStatsInv StatsInv;

   if(bOwnedByKiller)
   {
      StatsInv = RPGStatsInv(Killer.Pawn.FindInventoryType(Class'RPGStatsInv'));
      Data = StatsInv.DataObject;
      Data.Experience += Monster(Killed.Pawn).default.ScoringValue+(0.1*AbilityLevel);
   }


}

defaultproperties
{
     AbilityName="Experience Surge"
     Description="Increases the amount of Experience you get for killing a monster by 1% per level"
     StartingCost=1
     CostAddPerLevel=3
     MaxLevel=5
}
