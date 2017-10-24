class StoreMenuGUI extends GUIPage
	DependsOn(RPGStatsInv);

var moEditBox PointsAvailableBox;
var GUIListBox WeaponListBox;
var GUIListBox ArtifactListBox;
var GUIListBox ModifierListBox;
var localized String CostText;

var RPGStatsInv StatsInv;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	MyController.RegisterStyle(class'STY_AlterEgoButtonStyle', true);
	MyController.RegisterStyle(class'STY_AlterEgoEditBoxStyle', true);
	MyController.RegisterStyle(class'STY_AlterEgoSpinnerStyle', true);

	Super.InitComponent(MyController, MyOwner);

	WeaponListBox = GUIListBox(Controls[2]);
	ArtifactListBox = GUIListBox(Controls[7]);
	ModifierListBox = GUIListBox(Controls[10]);
	
        StatsInv = GetStatsInv();
	
        SetTimer(0.5,true);

	UpdateWeaponList();
	UpdateArtifactList();
	UpdateModifierList();

	Controls[1].Show();
	Controls[2].Hide();
	Controls[3].Show();
	Controls[4].Hide();
	Controls[5].Show();
	Controls[6].Show();
	Controls[7].Hide();
	Controls[8].Show();
	Controls[9].Show();
	Controls[10].Hide();
	Controls[11].Show();
}

function RPGStatsInv GetStatsInv()
{
     StatsInv = RPGStatsInv(PlayerOwner().Pawn.FindInventoryType(Class'RPGStatsInv'));
     
      if(StatsInv != None)
        return StatsInv;
        
        return None;
}

function timer()
{
     GUILabel(Controls[6]).Caption = GUILabel(default.Controls[6]).Caption @ StatsInv.Money;
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

function UpdateWeaponList()
{
     local int OldWeaponListIndex, OldWeaponListTop;
     local int cost,x;

	OldWeaponListIndex = WeaponListBox.List.Index;
	OldWeaponListTop = WeaponListBox.List.Top;
	WeaponListBox.List.Clear();
	GUILabel(Controls[6]).Caption = GUILabel(default.Controls[6]).Caption @ StatsInv.Money;

        for ( x = 0; x < StatsInv.WeaponsList.Length; x++)
        {
           cost = StatsInv.WeaponCost[x];

           WeaponListBox.List.Add(StatsInv.WeaponsList[x].Default.ItemName@"("$CostText@Cost$")",StatsInv.WeaponsList[x],String(Cost));
        }

	//restore list's previous state
	WeaponListBox.List.SetIndex(OldWeaponListIndex);
	WeaponListBox.List.SetTopItem(OldWeaponListTop);
	//UpdateAbilityButtons(Abilities);

}

function UpdateArtifactList()
{
    local int OldArtifactListIndex, OldArtifactListTop;
    local int cost,x;

    OldArtifactListIndex = ArtifactListBox.List.Index;
    OldArtifactListTop = ArtifactListBox.List.Top;
    ArtifactListBox.List.Clear();
    GUILabel(Controls[6]).Caption = GUILabel(default.Controls[6]).Caption @ StatsInv.Money;

        for ( x = 0; x < StatsInv.ArtifactsList.Length; x++)
        {
            cost = StatsInv.ArtifactCost[x];

            ArtifactListBox.List.Add(StatsInv.ArtifactsList[x].Default.ItemName@"("$CostText@Cost$")",StatsInv.ArtifactsList[x],String(Cost));
        }

    ArtifactListBox.List.SetIndex(OldArtifactListIndex);
    ArtifactListBox.List.SetTopItem(OldArtifactListTop);
}

function UpdateModifierList()
{
    local int OldModifierListIndex, OldModifierListTop;
    local int cost,x;

    OldModifierListIndex = ModifierListBox.List.Index;
    OldModifierListTop = ModifierListBox.List.Top;
    ModifierListBox.List.Clear();
    GUILabel(Controls[6]).Caption = GUILabel(default.Controls[6]).Caption @ StatsInv.Money;

        for ( x = 0; x < StatsInv.ModifiersList.Length; x++)
        {
            cost = StatsInv.ModifierCost[x];

            ModifierListBox.List.Add(StatsInv.ModifiersList[x].Default.ItemName@"("$CostText@Cost$")",StatsInv.ModifiersList[x],String(Cost));
        }

    ModifierListBox.List.SetIndex(OldModifierListIndex);
    ModifierListBox.List.SetTopItem(OldModifierListTop);
}

function bool BuyWeapon(GUIComponent Sender)
{
    GetStatsInv().ServerGiveWeapon(String(Class<Weapon>(WeaponListBox.List.GetObject())),Int(WeaponListBox.List.GetExtra()));
		return true;
}

function bool BuyArtifact(GUIComponent Sender)
{
	GetStatsInv().ServerGiveArtifact(PlayerOwner().Pawn,String(Class<RPGArtifact>(ArtifactListBox.List.GetObject())),Int(ArtifactListBox.List.GetExtra()));
		return true;
}

function bool BuyModifier(GUIComponent Sender)
{
	GetStatsInv().ServerGiveModifier(PlayerOwner().Pawn,String(Class<RPGArtifact>(ModifierListBox.List.GetObject())),Int(ModifierListBox.List.GetExtra()));
		return true;
}

function MyOnClose(optional bool bCanceled)
{
	Super.OnClose(bCanceled);
}

function bool WeaponClick(GUIComponent Sender)
{
	Controls[1].Show();
	Controls[2].Show();
	Controls[3].Show();
	Controls[4].Show();
	Controls[5].Show();
	Controls[6].Show();
	Controls[7].Hide();
	Controls[8].Hide();
	Controls[9].Show();
	Controls[10].Hide();
	Controls[11].Hide();
	UpdateWeaponList();
	return true;
}

function bool ArtifactClick(GUIComponent Sender)
{
	Controls[1].Show();
	Controls[2].Hide();
	Controls[3].Show();
	Controls[4].Hide();
	Controls[5].Show();
	Controls[6].Show();
	Controls[7].Show();
	Controls[8].Show();
	Controls[9].Show();
	Controls[10].Hide();
	Controls[11].Hide();
	UpdateArtifactList();
	return true;
}

function bool ModifierClick(GUIComponent Sender)
{
	Controls[1].Show();
	Controls[2].Hide();
	Controls[3].Show();
	Controls[4].Hide();
	Controls[5].Show();
	Controls[6].Show();
	Controls[7].Hide();
	Controls[8].Hide();
	Controls[9].Show();
	Controls[10].Show();
	Controls[11].Show();
    UpdateModifierList();
	return true;
}

defaultproperties
{
     CostText="Cost: "
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=StoreMenuGUI.MyOnClose
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'fpsRPGTex.Texture.Background'
         DropShadow=None
         ImageColor=(A=185)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'fpsRPG.StoreMenuGUI.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.525000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'fpsRPG.StoreMenuGUI.CloseButton'

     Begin Object Class=GUIListBox Name=WeaponsListBox
         bVisibleWhenEmpty=False
         OnCreateComponent=WeaponsListBox.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="Available weapons you can purchase with credits."
         WinTop=0.210000
         WinLeft=0.125000
         WinWidth=0.750000
         WinHeight=0.570000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=GUIListBox'fpsRPG.StoreMenuGUI.WeaponsListBox'

     Begin Object Class=GUIButton Name=WeaponButton
         Caption="Weapons"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.375000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.WeaponClick
         OnKeyEvent=WeaponButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'fpsRPG.StoreMenuGUI.WeaponButton'

     Begin Object Class=GUIButton Name=AbilityBuyButton
         Caption="Buy"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.100000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.BuyWeapon
         OnKeyEvent=AbilityBuyButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'fpsRPG.StoreMenuGUI.AbilityBuyButton'

     Begin Object Class=GUIButton Name=ArtifactButton
         Caption="Artifacts"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.100000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.ArtifactClick
         OnKeyEvent=ArtifactButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'fpsRPG.StoreMenuGUI.ArtifactButton'

     Begin Object Class=GUILabel Name=MoneyLabel
         Caption="Credits:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.140000
         WinWidth=0.327411
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(6)=GUILabel'fpsRPG.StoreMenuGUI.MoneyLabel'

     Begin Object Class=GUIListBox Name=ArtifactsListBox
         bVisibleWhenEmpty=False
         OnCreateComponent=ArtifactsListBox.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="Available artifacts you can purchase with credits."
         WinTop=0.210000
         WinLeft=0.125000
         WinWidth=0.750000
         WinHeight=0.570000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(7)=GUIListBox'fpsRPG.StoreMenuGUI.ArtifactsListBox'

     Begin Object Class=GUIButton Name=AbilityBuyAButton
         Caption="Buy"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.100000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.BuyArtifact
         OnKeyEvent=AbilityBuyAButton.InternalOnKeyEvent
     End Object
     Controls(8)=GUIButton'fpsRPG.StoreMenuGUI.AbilityBuyAButton'

     Begin Object Class=GUIButton Name=ModifierButton
         Caption="Modifiers"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.080000
         WinLeft=0.650000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.ModifierClick
         OnKeyEvent=ModifierButton.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'fpsRPG.StoreMenuGUI.ModifierButton'

     Begin Object Class=GUIListBox Name=ModifiersListBox
         bVisibleWhenEmpty=False
         OnCreateComponent=ModifiersListBox.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="Available Modifiers you can purchase with credits."
         WinTop=0.210000
         WinLeft=0.125000
         WinWidth=0.750000
         WinHeight=0.570000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(10)=GUIListBox'fpsRPG.StoreMenuGUI.ModifiersListBox'

     Begin Object Class=GUIButton Name=AbilityBuyMButton
         Caption="Buy"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.875000
         WinLeft=0.100000
         WinWidth=0.375000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=StoreMenuGUI.BuyModifier
         OnKeyEvent=AbilityBuyMButton.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'fpsRPG.StoreMenuGUI.AbilityBuyMButton'

     WinTop=0.025000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.950000
}
