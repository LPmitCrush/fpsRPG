class AemoEditBox extends GUIMenuOption;

var(Option)                     bool       bMaskText;
var(Option)                     bool       bReadOnly;
var(Option) editconst noexport AeGUIEditBox MyEditBox;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	//MyEditBox = GUIEditBox(MyComponent);
	MyEditBox = AeGUIEditBox(MyComponent);

	ReadOnly(bReadOnly||bValueReadOnly);
	MaskText(bMaskText);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if ( bNoChange )
		bIgnoreChange = True;

	SetText(NewValue);
	bIgnoreChange = False;
}

function string GetComponentValue()
{
	return GetText();
}

function string GetText()
{
	return MyEditBox.GetText();
}

function SetText(string NewText)
{
	MyEditBox.SetText(NewText);
}

function ReadOnly(bool b)
{
	SetReadOnly(b);
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyEditBox.bReadOnly = b;
}

function IntOnly(bool b)
{
	MyEditBox.bIntOnly=b;
}

function FloatOnly(bool b)
{
	MyEditBox.bFloatOnly = b;
}

function MaskText(bool b)
{
	MyEditBox.bMaskText = b;
}

defaultproperties
{
    ComponentClassName="fpsRPG.AeGUIEditBox"
}
