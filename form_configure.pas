unit Form_Configure;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons;

type

  { TFrmConfigure }

  TFrmConfigure = class(TForm)
    ButtonCopyDatabase: TButton;
    ButtonClose: TButton;
    ButtonCompressSQLite: TButton;
    CheckBox1: TCheckBox;
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
    procedure ButtonCopyDatabaseClick(Sender: TObject);
    procedure CheckBoxActivateLoggingChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonSQLliteDllLocationClick(Sender: TObject);
    procedure SpeedButtonSslDllLocation1Click(Sender: TObject);
    procedure SpeedButtonSslDllLocationClick(Sender: TObject);
  private
    procedure ReadSettings;
    procedure RestoreFormState;
    procedure SaveSettings;

  public

  end;

var
  FrmConfigure: TFrmConfigure;

implementation

uses Form_Main, Settingsmanager, AppDbMaintain;
{$R *.lfm}

{ TFrmConfigure }

procedure TFrmConfigure.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  SaveSettings;
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
  DbMaintain.CompressAppDatabase;
  DbMaintain.Free;
  Screen.Cursor := crDefault;
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

procedure TFrmConfigure.FormCreate(Sender: TObject);
begin
  Caption := 'Options';
  ReadSettings;
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
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();

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

  //..add settings
  SetMan.Free;
end;

procedure TFrmConfigure.RestoreFormState;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.RestoreFormState(self);

  SetMan.Free;
end;

procedure TFrmConfigure.SaveSettings;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
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

  //..add settings

  SetMan.SaveSettings;
  SetMan.Free;
end;

end.

