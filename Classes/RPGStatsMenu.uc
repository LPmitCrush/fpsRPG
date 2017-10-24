Class RPGStatsMenu extends GUIPage
	DependsOn(RPGStatsInv);



var RPGStatsInv StatsInv;

var AemoEditBox WeaponSpeedBox, HealthBonusBox, AdrenalineMaxBox, AttackBox, DefenseBox, AmmoMaxBox, ShieldMaxBox, PointsAvailableBox;
//Index of first stat display, first + button and first numeric edit in controls array
var int StatDisplayControlsOffset, ButtonControlsOffset, AmtControlsOffset;
var int NumButtonControls;
var GUIListBox Abilities;
var localized string CurrentLevelText, MaxText, CostText, CantBuyText;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	MyController.RegisterStyle(class'STY_AlterEgoButtonStyle', true);
	MyController.RegisterStyle(class'STY_AlterEgoEditBoxStyle', true);
	MyController.RegisterStyle(class'STY_AlterEgoSpinnerStyle', true);
	
	Super.InitComponent(MyController, MyOwner);
	
	WeaponSpeedBox = AemoEditBox(Controls[2]);
	HealthBonusBox = AemoEditBox(Controls[3]);
	ShieldMaxBox = AemoEditBox(Controls[4]);
	AdrenalineMaxBox = AemoEditBox(Controls[5]);
	AttackBox = AemoEditBox(Controls[6]);
	DefenseBox = AemoEditBox(Controls[7]);
	AmmoMaxBox = AemoEditBox(Controls[8]);
	PointsAvailableBox = AemoEditBox(Controls[9]);
	Abilities = GUIListBox(Controls[18]);

	//Controls[1].bVisible = true ;
	Controls[2].bVisible = true ;
	Controls[3].bVisible = true ;
	Controls[4].bVisible = true ;
	Controls[5].bVisible = true ;
	Controls[6].bVisible = true ;
	Controls[7].bVisible = true ;
	Controls[8].bVisible = true ;
	//Controls[9].bVisible = true ;
	Controls[10].bVisible = true ;
	Controls[11].bVisible = true ;
	Controls[12].bVisible = true ;
	Controls[13].bVisible = true ;
	Controls[14].bVisible = true ;
	Controls[15].bVisible = true ;
	Controls[16].bVisible = true ;
	Controls[17].bVisible = true ;
	Controls[18].bVisible = false ;
	Controls[18].WinWidth = 0.0 ;
	Abilities.MyScrollBar.WinWidth = 0.01 ;
	Controls[19].bVisible = false ;
	Controls[20].bVisible = false ;
	Controls[21].bVisible = true ;
	Controls[22].bVisible = true ;
	Controls[23].bVisible = true ;
	Controls[24].bVisible = true ;
	Controls[25].bVisible = true ;
	Controls[26].bVisible = true ;
	Controls[27].bVisible = true ;
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

function bool StatsClick(GUIComponent Sender)
{
	
	//Controls[1].bVisible = true ;
	Controls[2].bVisible = true ;
	Controls[3].bVisible = true ;
	Controls[4].bVisible = true ;
	Controls[5].bVisible = true ;
	Controls[6].bVisible = true ;
	Controls[7].bVisible = true ;
	Controls[8].bVisible = true ;
	//Controls[9].bVisible = true ;
	Controls[10].bVisible = true ;
	Controls[11].bVisible = true ;
	Controls[12].bVisible = true ;
	Controls[13].bVisible = true ;
	Controls[14].bVisible = true ;
	Controls[15].bVisible = true ;
	Controls[16].bVisible = true ;
	Controls[17].bVisible = true ;
	Controls[18].bVisible = false ;
	Controls[18].WinWidth = 0.0 ;
	Controls[19].bVisible = false ;
	Controls[20].bVisible = false ;
	Controls[21].bVisible = true ;
	Controls[22].bVisible = true ;
	Controls[23].bVisible = true ;
	Controls[24].bVisible = true ;
	Controls[25].bVisible = true ;
	Controls[26].bVisible = true ;
	Controls[27].bVisible = true ;
	Controls[31].bVisible = true ;
	Controls[32].bVisible = true ;
	Controls[33].bVisible = true ;
	InitFor(StatsInv);
	return true;
}

function bool AbilitiesClick(GUIComponent Sender)
{
	//Controls[1].bVisible = false ;
	Controls[2].bVisible = false ;
	Controls[3].bVisible = false ;
	Controls[4].bVisible = false ;
	Controls[5].bVisible = false ;
	Controls[6].bVisible = false ;
	Controls[7].bVisible = false ;
	Controls[8].bVisible = false ;
	Controls[9].bVisible = true ;
	Controls[10].bVisible = false ;
	Controls[11].bVisible = false ;
	Controls[12].bVisible = false ;
	Controls[13].bVisible = false ;
	Controls[14].bVisible = false ;
	Controls[15].bVisible = false ;
	Controls[16].bVisible = false ;
	Controls[17].bVisible = true ;
	Controls[18].bVisible = true ;
	Controls[18].WinWidth = 0.75 ;
	Controls[19].bVisible = true ;
	Controls[20].bVisible = true ;
	Controls[21].bVisible = false ;
	Controls[22].bVisible = false ;
	Controls[23].bVisible = false ;
	Controls[24].bVisible = false ;
	Controls[25].bVisible = false ;
	Controls[26].bVisible = false ;
	Controls[27].bVisible = false ;
	Controls[31].bVisible = true ;
	Controls[32].bVisible = true ;
	Controls[33].bVisible = true ;
	InitFor(StatsInv);
	return true;
}

function MyOnClose(optional bool bCanceled)
{
	if (StatsInv != None)
	{
		StatsInv.StatsMenu = None;
		StatsInv = None;
	}

	Super.OnClose(bCanceled);
}

function bool LevelsClick(GUIComponent Sender)
{
	Controller.OpenMenu("fpsRPG.RPGPlayerLevelsMenu");
	StatsInv.ProcessPlayerLevel = RPGPlayerLevelsMenu(Controller.TopPage()).ProcessPlayerLevel;
	StatsInv.ServerRequestPlayerLevels();

	return true;
}

//Initialize, using the given RPGStatsInv for the stats data and for client->server function calls
function InitFor(RPGStatsInv Inv)
{
	local int x, y, Index, Cost, Level, OldAbilityListIndex, OldAbilityListTop;
	local RPGPlayerDataObject TempDataObject;

	StatsInv = Inv;
	StatsInv.StatsMenu = self;

	WeaponSpeedBox.SetText(string(StatsInv.Data.WeaponSpeed));
	HealthBonusBox.SetText(string(StatsInv.Data.HealthBonus));
	ShieldMaxBox.SetText(string(StatsInv.Data.ShieldMax));
	AdrenalineMaxBox.SetText(string(StatsInv.Data.AdrenalineMax));
	AttackBox.SetText(string(StatsInv.Data.Attack));
	DefenseBox.SetText(string(StatsInv.Data.Defense));
	AmmoMaxBox.SetText(string(StatsInv.Data.AmmoMax));
	PointsAvailableBox.SetText(string(StatsInv.Data.PointsAvailable));
	GUILabel(Controls[29]).Caption = GUILabel(default.Controls[29]).Caption @ string(StatsInv.Data.Level);
	GUILabel(Controls[30]).Caption = GUILabel(default.Controls[30]).Caption @ string(StatsInv.Data.Experience) $ "/" $ string(StatsInv.Data.NeededExp);

	if (StatsInv.Data.PointsAvailable <= 0)
		DisablePlusButtons();
	else
		EnablePlusButtons();

	//show/hide buttons if stat caps reached
	for (x = 0; x < 7; x++)
		if ( StatsInv.StatCaps[x] >= 0
		     && int(AemoEditBox(Controls[StatDisplayControlsOffset+x]).GetText()) >= StatsInv.StatCaps[x] )
		{
			Controls[ButtonControlsOffset+x].SetVisibility(false);
			Controls[AmtControlsOffset+x].SetVisibility(false);
		}

	// on a client, the data object doesn't exist, so make a temporary one for calling the abilities' functions
	if (StatsInv.Role < ROLE_Authority)
	{
		TempDataObject = RPGPlayerDataObject(StatsInv.Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
		TempDataObject.InitFromDataStruct(StatsInv.Data);
	}
	else
	{
		TempDataObject = StatsInv.DataObject;
	}

	//Fill the ability listbox
	OldAbilityListIndex = Abilities.List.Index;
	OldAbilityListTop = Abilities.List.Top;
	Abilities.List.Clear();
	for (x = 0; x < StatsInv.AllAbilities.length; x++)
	{
		Index = -1;
		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
			if (StatsInv.AllAbilities[x] == StatsInv.Data.Abilities[y])
			{
				Index = y;
				y = StatsInv.Data.Abilities.length;
			}
		if (Index == -1)
			Level = 0;
		else
			Level = StatsInv.Data.AbilityLevels[Index];

		if (Level >= StatsInv.AllAbilities[x].default.MaxLevel)
			Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level@"["$MaxText$"])", StatsInv.AllAbilities[x], "-1");
		else
		{
			Cost = StatsInv.AllAbilities[x].static.Cost(TempDataObject, Level);

			if (Cost <= 0)
				Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CantBuyText$")", StatsInv.AllAbilities[x], string(Cost));
			else
				Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CostText@Cost$")", StatsInv.AllAbilities[x], string(Cost));
		}
	}
	//restore lists previous state
	Abilities.List.SetIndex(OldAbilityListIndex);
	Abilities.List.SetTopItem(OldAbilityListTop);
	UpdateAbilityButtons(Abilities);

	// free the temporary data object on clients
	if (StatsInv.Role < ROLE_Authority)
	{
		StatsInv.Level.ObjectPool.FreeObject(TempDataObject);
	}
}

function bool StatPlusClick(GUIComponent Sender)
{
	local int x, SenderIndex;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
		if (Controls[x] == Sender)
		{
			SenderIndex = x;
			break;
		}

	SenderIndex -= ButtonControlsOffset;
	DisablePlusButtons();
	StatsInv.ServerAddPointTo(int(AeGUINumericEdit(Controls[SenderIndex + AmtControlsOffset]).Value), EStatType(SenderIndex));

	return true;
}

function DisablePlusButtons()
{
	local int x;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
		Controls[x].MenuStateChange(MSAT_Disabled);
}

function EnablePlusButtons()
{
	local int x;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
		Controls[x].MenuStateChange(MSAT_Blurry);

	for (x = AmtControlsOffset; x < AmtControlsOffset + NumButtonControls; x++)
	{
		AeGUINumericEdit(Controls[x]).MaxValue = StatsInv.Data.PointsAvailable;
		AeGUINumericEdit(Controls[x]).CalcMaxLen();
		if (int(AeGUINumericEdit(Controls[x]).Value) > StatsInv.Data.PointsAvailable)
			AeGUINumericEdit(Controls[x]).SetValue(StatsInv.Data.PointsAvailable);
	}
}

function bool UpdateAbilityButtons(GUIComponent Sender)
{
	local int Cost;
	local class<RPGAbility> Ability;

	Cost = int(Abilities.List.GetExtra());
	if (Cost <= 0 || Cost > StatsInv.Data.PointsAvailable)
		Controls[20].MenuStateChange(MSAT_Disabled);
	else
		Controls[20].MenuStateChange(MSAT_Blurry);
		
	Ability = class<RPGAbility>(Abilities.List.GetObject());
	if (Ability != None)
		Controls[19].MenuStateChange(MSAT_Blurry);
	else
		Controls[19].MenuStateChange(MSAT_Disabled);

	return true;
}

function bool ShowAbilityDesc(GUIComponent Sender)
{
	local class<RPGAbility> Ability;
	
	Ability = class<RPGAbility>(Abilities.List.GetObject());
	Controller.OpenMenu("fpsRPG.RPGAbilityDescMenu");
	//RPGAbilityDescMenu(Controller.TopPage()).t_WindowTitle.Caption = Ability.default.AbilityName;
	//RPGAbilityDescMenu(Controller.TopPage()).MyScrollText.SetContent(Ability.default.Description);
	RPGAbilityDescMenu(Controller.TopPage()).MyScrollText.SetContent(Ability.default.Description);
	//MyScrollText.SetContent(Ability.default.Description);
	//GUIScrollTextBox(Controls[36]).SetContent(Ability.default.Description);
	
	return true;
}

function bool BuyAbility(GUIComponent Sender)
{
	DisablePlusButtons();
	Controls[19].MenuStateChange(MSAT_Disabled);
	StatsInv.ServerAddAbility(class<RPGAbility>(Abilities.List.GetObject()));

	return true;
}

function bool ResetClick(GUIComponent Sender)
{
	Controller.OpenMenu("fpsRPG.RPGResetConfirmPage");
	RPGResetConfirmPage(Controller.TopPage()).StatsMenu = self;
	return true;
}

function bool StoreClick(GUIComponent Sender)
{
	Controller.OpenMenu("fpsRPG.StoreMenuGUI");
	return true;
}

defaultproperties
{
     StatDisplayControlsOffset=2
     ButtonControlsOffset=10
     AmtControlsOffset=21
     NumButtonControls=7
     CurrentLevelText="Level:"
     MaxText="Max"
     CostText="Cost:"
     CantBuyText="Cant Buy"
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=RPGStatsMenu.MyOnClose
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'fpsRPGTex.Texture.Background'
         DropShadow=None
         ImageColor=(A=200)
         ImageStyle=ISTY_Stretched
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'fpsRPG.RPGStatsMenu.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.525000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'fpsRPG.RPGStatsMenu.CloseButton'

     Begin Object Class=AemoEditBox Name=WeaponSpeedSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Weapon Speed Bonus (%)"
         OnCreateComponent=WeaponSpeedSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.210000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(2)=AemoEditBox'fpsRPG.RPGStatsMenu.WeaponSpeedSelect'

     Begin Object Class=AemoEditBox Name=HealthBonusSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Health Bonus"
         OnCreateComponent=HealthBonusSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.310000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(3)=AemoEditBox'fpsRPG.RPGStatsMenu.HealthBonusSelect'

     Begin Object Class=AemoEditBox Name=ShieldMaxSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Max Shield Bonus"
         OnCreateComponent=ShieldMaxSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.410000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(4)=AemoEditBox'fpsRPG.RPGStatsMenu.ShieldMaxSelect'

     Begin Object Class=AemoEditBox Name=AdrenalineMaxSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Max Adrenaline"
         OnCreateComponent=AdrenalineMaxSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.510000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(5)=AemoEditBox'fpsRPG.RPGStatsMenu.AdrenalineMaxSelect'

     Begin Object Class=AemoEditBox Name=AttackSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Damage Bonus (0.1%)"
         OnCreateComponent=AttackSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.610000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(6)=AemoEditBox'fpsRPG.RPGStatsMenu.AttackSelect'

     Begin Object Class=AemoEditBox Name=DefenseSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Damage Reduction (0.1%)"
         OnCreateComponent=DefenseSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.710000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(7)=AemoEditBox'fpsRPG.RPGStatsMenu.DefenseSelect'

     Begin Object Class=AemoEditBox Name=MaxAmmoSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Max Ammo Bonus (%)"
         OnCreateComponent=MaxAmmoSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.810000
         WinLeft=0.070000
         WinWidth=0.600000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(8)=AemoEditBox'fpsRPG.RPGStatsMenu.MaxAmmoSelect'

     Begin Object Class=AemoEditBox Name=PointsAvailableSelect
         bReadOnly=True
         CaptionWidth=0.775000
         Caption="Stat Points Available"
         OnCreateComponent=PointsAvailableSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.140000
         WinLeft=0.250000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(9)=AemoEditBox'fpsRPG.RPGStatsMenu.PointsAvailableSelect'

     Begin Object Class=GUIButton Name=WeaponSpeedButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.210000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=WeaponSpeedButton.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'fpsRPG.RPGStatsMenu.WeaponSpeedButton'

     Begin Object Class=GUIButton Name=HealthBonusButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.310000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=HealthBonusButton.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'fpsRPG.RPGStatsMenu.HealthBonusButton'

     Begin Object Class=GUIButton Name=ShieldMaxButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.410000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=ShieldMaxButton.InternalOnKeyEvent
     End Object
     Controls(12)=GUIButton'fpsRPG.RPGStatsMenu.ShieldMaxButton'

     Begin Object Class=GUIButton Name=AdrenalineMaxButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.510000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AdrenalineMaxButton.InternalOnKeyEvent
     End Object
     Controls(13)=GUIButton'fpsRPG.RPGStatsMenu.AdrenalineMaxButton'

     Begin Object Class=GUIButton Name=AttackButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.610000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AttackButton.InternalOnKeyEvent
     End Object
     Controls(14)=GUIButton'fpsRPG.RPGStatsMenu.AttackButton'

     Begin Object Class=GUIButton Name=DefenseButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.710000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=DefenseButton.InternalOnKeyEvent
     End Object
     Controls(15)=GUIButton'fpsRPG.RPGStatsMenu.DefenseButton'

     Begin Object Class=GUIButton Name=AmmoMaxButton
         Caption="+"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.810000
         WinLeft=0.860000
         WinWidth=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AmmoMaxButton.InternalOnKeyEvent
     End Object
     Controls(16)=GUIButton'fpsRPG.RPGStatsMenu.AmmoMaxButton'

     Begin Object Class=GUIButton Name=LevelsButton
         Caption="Player Levels"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.650000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.LevelsClick
         OnKeyEvent=LevelsButton.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'fpsRPG.RPGStatsMenu.LevelsButton'

     Begin Object Class=GUIListBox Name=AbilityList
         bVisibleWhenEmpty=True
         OnCreateComponent=AbilityList.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="These are the abilities you can purchase with stat points."
         WinTop=0.210000
         WinLeft=0.125000
         WinWidth=0.750000
         WinHeight=0.570000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.UpdateAbilityButtons
     End Object
     Controls(18)=GUIListBox'fpsRPG.RPGStatsMenu.AbilityList'

     Begin Object Class=GUIButton Name=AbilityDescButton
         Caption="Info"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.800000
         WinLeft=0.200000
         WinWidth=0.200000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.ShowAbilityDesc
         OnKeyEvent=AbilityDescButton.InternalOnKeyEvent
     End Object
     Controls(19)=GUIButton'fpsRPG.RPGStatsMenu.AbilityDescButton'

     Begin Object Class=GUIButton Name=AbilityBuyButton
         Caption="Buy"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.800000
         WinLeft=0.600000
         WinWidth=0.200000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.BuyAbility
         OnKeyEvent=AbilityBuyButton.InternalOnKeyEvent
     End Object
     Controls(20)=GUIButton'fpsRPG.RPGStatsMenu.AbilityBuyButton'

     Begin Object Class=AeGUINumericEdit Name=WeaponSpeedAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.210000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=WeaponSpeedAmt.ValidateValue
     End Object
     Controls(21)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.WeaponSpeedAmt'

     Begin Object Class=AeGUINumericEdit Name=HealthBonusAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.310000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=HealthBonusAmt.ValidateValue
     End Object
     Controls(22)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.HealthBonusAmt'

     Begin Object Class=AeGUINumericEdit Name=ShieldMaxAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.410000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=ShieldMaxAmt.ValidateValue
     End Object
     Controls(23)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.ShieldMaxAmt'

     Begin Object Class=AeGUINumericEdit Name=AdrenalineMaxAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.510000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=AdrenalineMaxAmt.ValidateValue
     End Object
     Controls(24)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.AdrenalineMaxAmt'

     Begin Object Class=AeGUINumericEdit Name=AttackAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.610000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=AttackAmt.ValidateValue
     End Object
     Controls(25)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.AttackAmt'

     Begin Object Class=AeGUINumericEdit Name=DefenseAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.710000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=DefenseAmt.ValidateValue
     End Object
     Controls(26)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.DefenseAmt'

     Begin Object Class=AeGUINumericEdit Name=MaxAmmoAmt
         Value="5"
         MinValue=1
         MaxValue=5
         WinTop=0.810000
         WinLeft=0.700000
         WinWidth=0.130000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=MaxAmmoAmt.ValidateValue
     End Object
     Controls(27)=AeGUINumericEdit'fpsRPG.RPGStatsMenu.MaxAmmoAmt'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         FontScale=FNS_Small
         StyleName="AlterEgoButtonStyle"
         WinTop=0.030000
         WinLeft=0.800000
         WinWidth=0.065000
         WinHeight=0.026000
         bBoundToParent=True
         OnClick=RPGStatsMenu.ResetClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     Controls(28)=GUIButton'fpsRPG.RPGStatsMenu.ResetButton'

     Begin Object Class=GUILabel Name=LevelLabel
         Caption="Level:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.030000
         WinLeft=0.100000
         WinWidth=0.450000
         WinHeight=0.025000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(29)=GUILabel'fpsRPG.RPGStatsMenu.LevelLabel'

     Begin Object Class=GUILabel Name=EXPLabel
         Caption="Experience:"
         TextAlign=TXTA_Right
         TextColor=(B=255,G=255,R=255)
         WinTop=0.030000
         WinLeft=0.150000
         WinWidth=0.450000
         WinHeight=0.025000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(30)=GUILabel'fpsRPG.RPGStatsMenu.EXPLabel'

     Begin Object Class=GUIButton Name=StatsButton
         Caption="Stats"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.100000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatsClick
         OnKeyEvent=StatsButton.InternalOnKeyEvent
     End Object
     Controls(31)=GUIButton'fpsRPG.RPGStatsMenu.StatsButton'

     Begin Object Class=GUIButton Name=AbilitiesButton
         Caption="Abilities"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.375000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.AbilitiesClick
         OnKeyEvent=AbilitiesButton.InternalOnKeyEvent
     End Object
     Controls(32)=GUIButton'fpsRPG.RPGStatsMenu.AbilitiesButton'

     Begin Object Class=GUIButton Name=StoreButton
         Caption="Store"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.100000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StoreClick
         OnKeyEvent=StoreButton.InternalOnKeyEvent
     End Object
     Controls(33)=GUIButton'fpsRPG.RPGStatsMenu.StoreButton'

     WinTop=0.025000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.950000
}
