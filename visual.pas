unit Visual;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Windows, Dialogs, StdCtrls, ComCtrls,
  Types, Buttons, Extctrls;

type

  { TVisual }

  TVisual = class(TObject)
    private
      function NodeChecked(ANode:TTreeNode): Boolean;


    public
      constructor Create; overload;
      destructor  Destroy; override;

      procedure ActiveTextBackGroundColor(Sender: TObject; Enable: Boolean);
      function  CheckEntryLength(Sender: TObject; aLength: Integer) : Boolean;
      procedure AlterSystemMenu;
      procedure CheckNode(Node: TTreeNode; Checked:boolean);
      procedure ToggleTreeViewCheckBoxes(Node: TTreeNode);
      function Helptext(Sender: TObject; aText : string) : String;


  end;

implementation

uses Form_Main, Settings;

const
  ImgIndexChecked = 0;
  ImgIndexUnchecked = 1;

{ TVisual }

{%region Checkboxes treeview}
// Simulate checkbox in treeview with an image.
procedure TVisual.CheckNode(Node: TTreeNode; Checked: boolean);
begin
  if Assigned(Node) then
    if Checked then
      Node.StateIndex := ImgIndexChecked
    else
      Node.StateIndex := ImgIndexUnchecked;
end;

procedure TVisual.ToggleTreeViewCheckBoxes(Node: TTreeNode);
begin
  if Assigned(Node) then begin
    if Node.StateIndex = ImgIndexUnchecked then
      Node.StateIndex := ImgIndexChecked
    else
    if Node.StateIndex = ImgIndexChecked then
      Node.StateIndex := ImgIndexUnchecked
  end;
end;

function TVisual.NodeChecked(ANode: TTreeNode): Boolean;
begin
  result := (ANode.StateIndex = ImgIndexChecked);
end;
{%endregion Checkboxes treeview}

{%region constructor - destructor}
constructor TVisual.Create;
begin
  inherited;
  //
end;

destructor TVisual.Destroy;
begin
  //
  inherited Destroy;
end;
{%endregion constructor - destructor}

procedure TVisual.ActiveTextBackGroundColor(Sender: TObject; Enable: Boolean);
var
  _Edit     : TEdit;
  _ComboBox : TComboBox;
begin
  if sender is TEdit then
    begin
      _Edit := TEdit(sender);
      if Enable then begin
        _Edit.Color := clGradientInactiveCaption
      end
      else begin
        _Edit.Color := clDefault;
      end;
    end
  else if sender is TComboBox then
    begin
      _ComboBox := TComboBox(sender);
      if Enable then begin
        _ComboBox.Color := clGradientInactiveCaption;
      end
      else begin
        _ComboBox.Color := clDefault;
      end;
    end;
end;

function TVisual.CheckEntryLength(Sender: TObject; aLength: Integer) : Boolean;
var
  _Edit     : TEdit;
  _Memo     : TMemo;
begin
  if aLength > 0 then begin
    if sender is TEdit then begin
      _Edit := TEdit(sender);
      if Length(_Edit.Text) > aLength then begin
        _Edit.Font.Color := clRed;
        Result := false;
      end
      else begin
        _Edit.Font.Color := clDefault;
        Result := true;
      end;
    end
    else if sender is TMemo then begin
      _Memo := TMemo(sender);
      if Length(_Memo.Text) > aLength then begin
        _Memo.Font.Color := clRed;
        Result := false;
      end
      else begin
        _Memo.Font.Color := clDefault;
        Result := true;
      end;
    end;
  end;
end;

procedure TVisual.AlterSystemMenu;
// Expand system menu with 1 line
const
   sMyMenuCaption1 = Settings.ApplicationName + '  V' + Settings.Version + '.' + '   (HvB)';
   SC_MyMenuItem1 = WM_USER + 1;
var
  SysMenu : HMenu;
begin
  SysMenu := GetSystemMenu(FrmMain.Handle, FALSE) ;                 {Get system menu}
  AppendMenu(SysMenu, MF_SEPARATOR, 0, '') ;                        {Add a seperator bar to main form}

  // AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, '') ;               //empty line
  AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, sMyMenuCaption1) ;  {add our menu}
end;

function TVisual.Helptext(Sender: TObject; aText: string) : String;
var
  MyPoint     : TPoint;
  _Button     : TButton;
  _TBitBtn    : TBitBtn;
  _Checkbox   : TCheckbox;
  _Edit       : TEdit;
  _Label      : TLabel;
  _ComboBox   : TComboBox;
  _RadioGroup : TRadioGroup;
begin
  if sender is TRadioGroup then begin
    _RadioGroup := TRadioGroup(sender);
    MyPoint := _RadioGroup.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_RadioGroup.ClientRect, MyPoint)) then begin  // Mouse is inside the control, do something here.
      Result := aText;
    end;
  end;

  if sender is TButton then begin
    _Button := TButton(sender);
    MyPoint := _Button.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_Button.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;

  if sender is TBitBtn then begin
    _TBitBtn := TBitBtn(sender);
    MyPoint := _TBitBtn.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_TBitBtn.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;

  if sender is TCheckbox then begin
    _Checkbox := TCheckbox(sender);
    MyPoint := _Checkbox.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_Checkbox.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;

  if sender is TEdit then begin
    _Edit := TEdit(sender);
    MyPoint := _Edit.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_Edit.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;

  if sender is TLabel then begin
    _Label := TLabel(sender);
    MyPoint := _Label.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_Label.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;

  if sender is TCombobox then begin
    _Combobox := TCombobox(sender);
    MyPoint := _Combobox.ScreenToClient(Mouse.CursorPos);
    if (PtInRect(_Combobox.ClientRect, MyPoint)) then begin
      Result := aText;
    end;
  end;
end;






end.

