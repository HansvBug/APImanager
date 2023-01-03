unit Form_Configure;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons, Visual, SettingsManager;

type

  { TFrmConfigure }

  TFrmConfigure = class(TForm)
    ButtonCopyDatabase: TButton;
    ButtonClose: TButton;
    ButtonCompressSQLite: TButton;
    CheckBoxDisplayHelpText: TCheckBox;
    CheckBoxTrvHotTrack: TCheckBox;
    CheckBoxBackGroundColorActiveControle: TCheckBox;
    CheckBoxActivateLogging: TCheckBox;
    CheckBoxAppendLogFile: TCheckBox;
    EditCopyDbFile: TEdit;
    EditSQLiteLibraryLocation: TEdit;
    EditSslDllLocation: TEdit;
    EditSslDllLocation1: TEdit;
    GroupBoxAppDb: TGroupBox;
    GroupBoxFileLocations: TGroupBox;
    GroupBoxVisual: TGroupBox;
    GroupBoxLogFile: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelStatus: TLabel;
    LabelCopyDbFile: TLabel;
    LabelSslDllLocation: TLabel;
    LabelSslDllLocation1: TLabel;
    PageControl1: TPageControl;
    SpeedButtonSQLliteDllLocation: TSpeedButton;
    SpeedButtonSslDllLocation: TSpeedButton;
    SpeedButtonSslDllLocation1: TSpeedButton;
    TabSheetAppDatabase: TTabSheet;
    TabSheetDivers: TTabSheet;
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonCompressSQLiteClick(Sender: TObject);
    procedure ButtonCompressSQLiteMouseLeave(Sender: TObject);
    procedure ButtonCompressSQLiteMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonCopyDatabaseClick(Sender: TObject);
    procedure ButtonCopyDatabaseMouseLeave(Sender: TObject);
    procedure ButtonCopyDatabaseMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure CheckBoxActivateLoggingChange(Sender: TObject);
    procedure CheckBoxActivateLoggingMouseLeave(Sender: TObject);
    procedure CheckBoxActivateLoggingMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxAppendLogFileMouseLeave(Sender: TObject);
    procedure CheckBoxAppendLogFileMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxBackGroundColorActiveControleMouseLeave(Sender: TObject);
    procedure CheckBoxBackGroundColorActiveControleMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxDisplayHelpTextMouseLeave(Sender: TObject);
    procedure CheckBoxDisplayHelpTextMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxTrvHotTrackMouseLeave(Sender: TObject);
    procedure CheckBoxTrvHotTrackMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure EditCopyDbFileMouseLeave(Sender: TObject);
    procedure EditCopyDbFileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EditSQLiteLibraryLocationMouseLeave(Sender: TObject);
    procedure EditSQLiteLibraryLocationMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonSQLliteDllLocationClick(Sender: TObject);
    procedure SpeedButtonSQLliteDllLocationMouseLeave(Sender: TObject);
    procedure SpeedButtonSQLliteDllLocationMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButtonSslDllLocation1Click(Sender: TObject);
    procedure SpeedButtonSslDllLocationClick(Sender: TObject);
  private
    SetMan : TSettingsManager;
    Visual : TVisual;
    procedure ReadSettings;
    procedure RestoreFormState;
    procedure SaveSettings;
    procedure SetStatusLabelText(aText : String);
    function  V_SetHelpText(Sender: TObject; aText: string) : String;
  public

  end;

var
  FrmConfigure: TFrmConfigure;

implementation

uses Form_Main, AppDbMaintain;
{$R *.lfm}

{ TFrmConfigure }

procedure TFrmConfigure.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  SaveSettings;
  Visual.Free;
  SetMan.Free;
end;

procedure TFrmConfigure.CheckBoxActivateLoggingChange(Sender: TObject);
begin
  if CheckBoxActivateLogging.Checked then
    begin
      CheckBoxAppendLogFile.Enabled := True;
    end
  else
    begin
      CheckBoxAppendLogFile.Enabled := False;
      CheckBoxAppendLogFile.Checked := False;
    end;
end;

procedure TFrmConfigure.CheckBoxActivateLoggingMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.CheckBoxActivateLoggingMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Activeer de log functionaliteit.'));
end;

procedure TFrmConfigure.CheckBoxAppendLogFileMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.CheckBoxAppendLogFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Vul het bestaande log aan.'));
end;

procedure TFrmConfigure.CheckBoxBackGroundColorActiveControleMouseLeave(
  Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.CheckBoxBackGroundColorActiveControleMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Verander achtergrond kleur van het actieve invoerveld.'));
end;

procedure TFrmConfigure.CheckBoxDisplayHelpTextMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.CheckBoxDisplayHelpTextMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Toon hulpteksen als de muis over een component beweegt.'));
end;

procedure TFrmConfigure.CheckBoxTrvHotTrackMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.CheckBoxTrvHotTrackMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Markeer de active Node extra.'));
end;

procedure TFrmConfigure.EditCopyDbFileMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.EditCopyDbFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Er wordt een kopie van de applicatie database gemaakt na elke ... opstarten van de applicatie.'));
end;

procedure TFrmConfigure.EditSQLiteLibraryLocationMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.EditSQLiteLibraryLocationMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Locatie en naam van het SQlite dll bestand. (sqlite3.dll)'));
end;

procedure TFrmConfigure.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfigure.ButtonCompressSQLiteClick(Sender: TObject);
var
  DbMaintain : TAppDbMaintain;
begin
  Screen.Cursor := crHourGlass;
  DbMaintain := TAppDbMaintain.Create;
  SetStatusLabelText('Alle ID''s resetten...');
  DbMaintain.ResetAutoIncrementAll;

  SetStatusLabelText('Database compress...');
  DbMaintain.CompressAppDatabase;
  DbMaintain.Free;
    SetStatusLabelText('');
  Screen.Cursor := crDefault;
end;

procedure TFrmConfigure.ButtonCompressSQLiteMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.ButtonCompressSQLiteMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Comprimeer de database.'));
end;

procedure TFrmConfigure.ButtonCopyDatabaseClick(Sender: TObject);
var
  DbMaintain : TAppDbMaintain;
begin
  Screen.Cursor := crHourGlass;
  DbMaintain := TAppDbMaintain.Create;
  DbMaintain.CopyDbFile;
  DbMaintain.Free;
  Screen.Cursor := crDefault;
end;

procedure TFrmConfigure.ButtonCopyDatabaseMouseLeave(Sender: TObject);
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.ButtonCopyDatabaseMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Maak nu een kopie van de applicatie database.'));
end;

procedure TFrmConfigure.FormCreate(Sender: TObject);
begin
  SetMan := TSettingsManager.Create;
  Caption := 'Options';
  ReadSettings;
  Visual := TVisual.Create;
  PageControl1.ActivePage := TabSheetDivers;
end;

procedure TFrmConfigure.FormShow(Sender: TObject);
begin
  RestoreFormState;
end;

procedure TFrmConfigure.SpeedButtonSQLliteDllLocationClick(Sender: TObject);
var
  OpenFileDlg : TOpenDialog;
begin
  OpenFileDlg := TOpenDialog.Create(Self);
  //OpenFileDlg.Filter := 'Dynamic library|*.dll';
  OpenFileDlg.Filter := 'Dynamic library|sqlite3.dll';
  OpenFileDlg.Title := 'Location sqlite3.dll';
  if OpenFileDlg.Execute then
    begin
      EditSQLiteLibraryLocation.Text := OpenFileDlg.FileName;
    end;

  OpenFileDlg.Free;
end;

procedure TFrmConfigure.SpeedButtonSQLliteDllLocationMouseLeave(Sender: TObject
  );
begin
  SetStatusLabelText(V_SetHelpText(Sender, ''));
end;

procedure TFrmConfigure.SpeedButtonSQLliteDllLocationMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusLabelText(V_SetHelpText(Sender, 'Zoek de SQLite dll.'));
end;

procedure TFrmConfigure.SpeedButtonSslDllLocation1Click(Sender: TObject);
var
  OpenFileDlg : TOpenDialog;
begin
  OpenFileDlg := TOpenDialog.Create(Self);
  OpenFileDlg.Filter := 'Dynamic library|ssleay32.dll';
  OpenFileDlg.Title := 'Location ssleay32.dll';
  if OpenFileDlg.Execute then
    begin
      EditSslDllLocation1.Text := OpenFileDlg.FileName;
    end;

  OpenFileDlg.Free;
end;

procedure TFrmConfigure.SpeedButtonSslDllLocationClick(Sender: TObject);
var
  OpenFileDlg : TOpenDialog;
begin
  OpenFileDlg := TOpenDialog.Create(Self);
  OpenFileDlg.Filter := 'Dynamic library|libeay32.dll';
  OpenFileDlg.Title := 'Location libeay32.dll';
  if OpenFileDlg.Execute then
    begin
      EditSslDllLocation.Text := OpenFileDlg.FileName;
    end;

  OpenFileDlg.Free;
end;

procedure TFrmConfigure.ReadSettings;
begin
  if Setman.AppendLogFile then begin
    CheckBoxAppendLogFile.Checked := True;
  end
  else begin
    CheckBoxAppendLogFile.Checked := False;
  end;

  if SetMan.ActivateLogging then begin
    CheckBoxActivateLogging.Checked := True;
  end
  else begin
    CheckBoxActivateLogging.Checked := False;
    CheckBoxAppendLogFile.Checked := False;
    CheckBoxAppendLogFile.Enabled := False;
  end;

  EditSQLiteLibraryLocation.Text := SetMan.SQLiteDllLocation;
  EditSslDllLocation.Text := SetMan.SslDllLocation_file1;
  EditSslDllLocation1.Text := SetMan.SslDllLocation_file2;

  if SetMan.SetActiveBackGround then begin
    CheckBoxBackGroundColorActiveControle.Checked := True;
  end
  else begin
    CheckBoxBackGroundColorActiveControle.Checked := False;
  end;

  EditCopyDbFile.Text := IntToStr(SetMan.FileCopyCount);

  if SetMan.SetTreeViewHotTrack then begin
    CheckBoxTrvHotTrack.Checked := True;
  end
  else begin
    CheckBoxTrvHotTrack.Checked := False;
  end;

  if SetMan.DisplayHelpText then begin
    CheckBoxDisplayHelpText.Checked := True;
  end
  else begin
    CheckBoxDisplayHelpText.Checked := False;
  end;

  //..add settings
end;

procedure TFrmConfigure.RestoreFormState;
begin
  SetMan.RestoreFormState(self);
end;

procedure TFrmConfigure.SaveSettings;
begin
  SetMan.StoreFormState(self);

  if CheckBoxActivateLogging.Checked then
    begin
      Setman.ActivateLogging := True;
      FrmMain.Logging.ActivateLogging := True;
    end
  else
    begin
      Setman.ActivateLogging := False;
      FrmMain.Logging.ActivateLogging := False;
      FrmMain.Logging.AppendLogFile := False;
    end;

  if CheckBoxAppendLogFile.Checked then
    begin
      SetMan.AppendLogFile := True;
    end
  else
    begin
      SetMan.AppendLogFile := False;
    end;

  SetMan.SQLiteDllLocation:= EditSQLiteLibraryLocation.Text;
  SetMan.SslDllLocation_file1:= EditSslDllLocation.Text;
  SetMan.SslDllLocation_file2:= EditSslDllLocation1.Text;

  if  CheckBoxBackGroundColorActiveControle.Checked then begin
    SetMan.SetActiveBackGround := True;
  end
  else  begin
    SetMan.SetActiveBackGround := False;
  end;

  SetMan.FileCopyCount := StrToInt(EditCopyDbFile.Text);

  if CheckBoxTrvHotTrack.Checked then begin
    SetMan.SetTreeViewHotTrack := True;
  end
  else begin
    SetMan.SetTreeViewHotTrack := False;
  end;

  if CheckBoxDisplayHelpText.Checked then begin
    SetMan.DisplayHelpText := True;
  end
  else begin
    SetMan.DisplayHelpText := False;
  end;


  //..add settings


  SetMan.SaveSettings;
end;

procedure TFrmConfigure.SetStatusLabelText(aText: String);
begin
  if aText <> '' then begin
    LabelStatus.Caption := ' ' + aText;
  end
  else begin
    LabelStatus.Caption := '';
  end;

  Application.ProcessMessages;
end;

function TFrmConfigure.V_SetHelpText(Sender: TObject; aText: string): String;
begin
  if SetMan.DisplayHelpText then begin
    Result := Visual.Helptext(Sender, aText);
  end;
end;

end.

