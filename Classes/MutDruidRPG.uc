class MutDruidRPG extends Mutator;


var RPGRules rules;

function PostBeginPlay()
{
	Enable('Tick');
}

function Tick(float deltaTime)
{
	local GameRules G;

	if(rules != None)
	{
		Disable('Tick');
		return; //already initialized
	}

	if ( Level.Game.GameRulesModifiers == None )
		warn("Warning: There is no FPSRPG Loaded. DruidsRPG cannot function.");
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('RPGRules'))
				rules = RPGRules(G);
			if(G.NextGameRules == None)
			{
				if(rules == None)
				{
					warn("Warning: There is no FPSRPG Loaded. DruidsRPG cannot function.");
					return;
				}
				Level.Game.GameRulesModifiers.AddGameRules(spawn(class'DruidRPGGameRules'));
				Disable('Tick');
				return;
			}
		}
	}
}

defaultproperties
{
     GroupName="fpsRPG"
     FriendlyName="ÿFPS RPG Game Rules"
     Description="Game rules specific to DruidsRPG."
}
