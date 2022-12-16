unit Visual;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Windows, Dialogs, StdCtrls;

type

  { TVisual }

  TVisual = class(TObject)
    private
    public
      constructor Create; overload;
      destructor Destroy; override;

      procedure ActiveTextBackGroundColor(Sender: TObject; Enable: Boolean);
      function CheckEntryLength(Sender: TObject; aLength: Integer) : Boolean;
      procedure AlterSystemMenu;
  end;

implementation

uses Form_Main, Settings;

{ TVisual }

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





end.

