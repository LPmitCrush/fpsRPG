class AeGUINumericEdit extends GUINumericEdit;

defaultproperties
{
     Begin Object Class=GUIEditBox Name=cMyEditBox
         bIntOnly=True
         StyleName="AlterEgoEditBoxStyle"
         bNeverScale=True
         OnActivate=cMyEditBox.InternalActivate
         OnDeActivate=cMyEditBox.InternalDeactivate
         OnKeyType=cMyEditBox.InternalOnKeyType
         OnKeyEvent=cMyEditBox.InternalOnKeyEvent
     End Object
     MyEditBox=GUIEditBox'fpsRPG.AeGUINumericEdit.cMyEditBox'

     Begin Object Class=GUISpinnerButton Name=cMySpinner
         StyleName="AlterEgoSpinnerStyle"
         bTabStop=False
         bNeverScale=True
         OnClick=cMySpinner.InternalOnClick
         OnKeyEvent=cMySpinner.InternalOnKeyEvent
     End Object
     MySpinner=GUISpinnerButton'fpsRPG.AeGUINumericEdit.cMySpinner'

     Begin Object Class=GUIToolTip Name=GUINumericEditToolTip
     End Object
     ToolTip=GUIToolTip'fpsRPG.AeGUINumericEdit.GUINumericEditToolTip'

}
