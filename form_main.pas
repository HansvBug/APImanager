unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus, fphttpclient, fpjson, jsonparser, ssockets, fpopenssl,
  sslsockets, opensslsockets, TypInfo, Logging, Settings, Settingsmanager, Visual;
{
  Download and extract the libeay32.dll and ssleay32.dll files from https://indy.fulgan.com/SSL/ into project folder.
  AMD add opensslsockets unit.
}

type

  { TFrmMain }

  TFrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    MainMenu1: TMainMenu;
    MemoFormatted: TMemo;
    MenuItemOptionsConfigure: TMenuItem;
    MenuItemOptions: TMenuItem;
    MenuItemMaintainApiStrings: TMenuItem;
    MenuItemMaintain: TMenuItem;
    MenuItemProgram: TMenuItem;
    MenuItemProgramQuit: TMenuItem;
    StatusBarMainFrm: TStatusBar;
    TreeView1: TTreeView;
    TreeView2: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItemMaintainApiStringsClick(Sender: TObject);
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemProgramQuitClick(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
    procedure TreeView2DblClick(Sender: TObject);
    procedure TreeView2Deletion(Sender: TObject; Node: TTreeNode);
  private
    FDisableProgramItems : String;
    FDebugMode :Boolean;

    procedure Initialize;
    procedure CheckAppEnvironment;
    procedure DisableFunctions;
    function ReadURLGet(url:string):string;
    procedure ReadSettings;
    procedure SaveSettings;
    procedure StartLogging;
    procedure RestoreFormState;
    procedure SetStatusbarText(aText : String);
    procedure LoadFoldersAndQueries;
    procedure CreateApplicationDataBase;
    function ProcessArguments :  String;
    procedure CopyAppDbFile;

    property DisableProgramItems : String Read FDisableProgramItems Write FDisableProgramItems;
    property DebugMode  : Boolean Read FDebugMode Write FDebugMode default False;

  public
    Logging : TLog_File;
    Visual  : TVisual;
  end;

var
  FrmMain : TFrmMain;
  SetMan  : TSettingsManager;

Resourcestring

  SCaption = 'JSON Viewer';
  SEmpty   = 'Empty document';
  SArray   = 'Array (%d elements)';
  SObject  = 'Object (%d members)';
  SNull    = 'null';

implementation

{$R *.lfm}

{ TFrmMain }
uses applicationenvironment, AppDbCreate, AppDbMaintain,
  form_maintain_api_data, Form_Configure, appdbFQ, AppDbFolder, ApiRequest;


procedure TFrmMain.SetStatusbarText(aText: String);
begin
  if aText <> '' then begin
    StatusBarMainFrm.Panels.Items[0].Text := ' ' + aText;
  end
  else begin
    StatusBarMainFrm.Panels.Items[0].Text := '';
  end;

  Application.ProcessMessages;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
var
  listitemsjson:string;
  jData : TJSONData;
   Node: TTreeNode;
   ApiReq : TApiRequest;
begin
  listitemsjson := ReadURLGet(Edit1.Text);
  jData  := GetJSON(listitemsjson);

  TreeView1.Items.Clear;
  Treeview1.Items.Add (nil,'Root Node');

  Node := Treeview1.Items[0];
  ApiReq := TApiRequest.Create;
  ApiReq.Trv := TreeView1;
  ApiReq.ShowJSONData(Node,jData);
  ApiReq.ExpandTreeNodes(TreeView1.Items, 2);  // Expand the first level of the treeview
  MemoFormatted.Text := ApiReq.FormatJsonData(jData);
  ApiReq.Free;

  jData.Free;
end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
end;

function TFrmMain.ReadURLGet(url: string): string;
var
  respons : String;
  b64decoded, username , password : String;
begin

  with TFPHTTPClient.Create(nil) do
  try
    //UserName := '';
    //Password := '';
    respons:= Get(url);
  finally
    Free;

  end;
  result := respons;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  CheckAppEnvironment;
  ReadSettings;
  StartLogging;
  Initialize;
end;

procedure TFrmMain.CheckAppEnvironment;
var
  CheckEnvironment : TApplicationEnvironment;
  BaseFolder : string;
begin
  BaseFolder :=  ExtractFilePath(Application.ExeName);

  if BaseFolder <> '' then begin//create the folders
    CheckEnvironment := TApplicationEnvironment.Create;
    CheckEnvironment.CreateFolder(BaseFolder, Settings.SettingsFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.DatabaseFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.LoggingFolder);
    CheckEnvironment.CreateFolder(BaseFolder, Settings.DatabaseFolder + PathDelim + Settings.BackupFolder);

    //create the settings file
    CheckEnvironment.CreateSettingsFile(BaseFolder + Settings.SettingsFolder + PathDelim);

    if CheckEnvironment.CheckDllFiles then
      DisableFunctions;

    CheckEnvironment.Free;
  end;
end;

procedure TFrmMain.ReadSettings;
begin
  if assigned(SetMan) then SetMan.Free;
  SetMan := TSettingsManager.Create();
end;

procedure TFrmMain.StartLogging;
begin
  Logging := TLog_File.Create();
  Logging.ActivateLogging := SetMan.ActivateLogging;
  Logging.AppendLogFile := Setman.AppendLogFile;
  Logging.StartLogging;
end;

procedure TFrmMain.Initialize;
begin
  FrmMain.Caption := Settings.ApplicationName;
  Visual := TVisual.Create;
  Visual.AlterSystemMenu;

  if ProcessArguments = 'Install' then begin // Are there any command line parameters?
    CreateApplicationDataBase;
  end;
  if ProcessArguments = 'Debug=On' then begin
    DebugMode := True;
  end;

  LoadFoldersAndQueries;
  SetStatusbarText('Welkom');
  CopyAppDbFile;
  DisableFunctions;
end;

procedure TFrmMain.LoadFoldersAndQueries;
var
  MaintainFolders : TFolder;
  ApiReq : TApiRequest;
  DbFile : String;
begin
  DbFile := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;

  if FileExists(DbFile) then begin
    SetStatusbarText('Ophalen gegegevens...');
    MaintainFolders := TFolder.Create;

    MaintainFolders.GetFoldersAndQueries(TreeView2);
    ApiReq := TApiRequest.Create;
    ApiReq.ExpandTreeNodes(TreeView2.Items, 2);  { #todo : Maak het antal uitgeklapte nodes optioneel }
    ApiReq.Free;
    MaintainFolders.Free;
    SetStatusbarText('');
  end
  else begin
    Logging.WriteToLogWarning('Het applicate database bestand is niet gevonden.');
    Logging.WriteToLogWarning('Locatie: ' + DbFile);
    DisableProgramItems := 'Volledig uit';
  end;
end;

procedure TFrmMain.CopyAppDbFile;
var
  DbMaintain : TAppDbMaintain;
begin
  if SetMan.FileCopyCount < SetMan.FileCopyCurrent then
    SetMan.FileCopyCurrent := SetMan.FileCopyCount;

  if (SetMan.FileCopyCount > 0 ) then begin
    if (SetMan.FileCopyCount = SetMan.FileCopyCurrent) then begin
      DbMaintain :=  TAppDbMaintain.Create;
      if DbMaintain.CopyDbFile then begin
        SetMan.FileCopyCurrent := 0;
      end
      else
        Setman.FileCopyCount := Setman.FileCopyCount;
      DbMaintain.Free;
    end
    else
      Setman.FileCopyCurrent := Setman.FileCopyCurrent +1;
  end;
end;

procedure TFrmMain.CreateApplicationDataBase;
var
  Appdatabase : TCreateAppdatabase;
begin
  Appdatabase  := TCreateAppdatabase.Create();
    try
      if not Appdatabase.CreateDatabase() then
        begin
          messageDlg('Fout.', 'Het aanmaken van de database (tabellen) is mislukt.', mtInformation, [mbOK],0);
          Logging.WriteToLogError('Het aanmaken van de database (tabellen) is mislukt.');
          DisableProgramItems := 'Volledig uit';
        end;
    finally
      Appdatabase.free;
    end;
end;

function TFrmMain.ProcessArguments: String;
var
  I: Integer;
begin
  for i := 1 to ParamCount do begin
    case ParamStr(i) of
     'DebugMode=On' :
       begin
         Logging.WriteToLogInfo('Starten in de DebugMode.');  // Start in DebugMode.
         DebugMode := True;
         Result := '';
       end;
     'Install' :
       begin
         Logging.WriteToLogInfo('Starten met de Install optie.');  // Start with Install option. = create or update the SQLite appdatabse.
         Result := 'Install';
       end;
    end;
  end;
end;

procedure TFrmMain.RestoreFormState;
begin
  SetMan.RestoreFormState(self);
end;

procedure TFrmMain.SaveSettings;
begin
  SetMan.SaveSettings;
  SetMan.StoreFormState(self);
end;

procedure TFrmMain.DisableFunctions;
begin
  if DisableProgramItems = 'Volledig uit' then begin
    Button1.Enabled := false;
    MenuItemMaintain.Enabled := false;
    SetStatusbarText('Welkom, raadpleeg het log bestand.');
  end;
end;


procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Visual.Free;
  Logging.StopLogging;
  Logging.Free;
  SetMan.Free;
end;


procedure TFrmMain.FormShow(Sender: TObject);
begin
  RestoreFormState();
end;

procedure TFrmMain.MenuItemMaintainApiStringsClick(Sender: TObject);
var
  FrmMaintain : TFrm_Maintain_Api_Data;
begin
  FrmMaintain := TFrm_Maintain_Api_Data.Create(Self);
  try
    FrmMaintain.ShowModal;
  finally
    FrmMaintain.Free;
    LoadFoldersAndQueries;
  end;
end;

procedure TFrmMain.MenuItemOptionsConfigureClick(Sender: TObject);
var
  ConfigureFrm : TFrmConfigure;
  ActivateLogging : Boolean;
begin
  ActivateLogging := SetMan.ActivateLogging;
  SetMan.SaveSettings;
  ConfigureFrm := TFrmConfigure.Create(Self);
  try
    ConfigureFrm.ShowModal;
  finally
    ConfigureFrm.Free;
    ReadSettings();
    if (SetMan.ActivateLogging) and not ActivateLogging then
      begin
        Logging.Free;
        StartLogging();
      end
  end;
end;

procedure TFrmMain.MenuItemProgramQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.TreeView1SelectionChanged(Sender: TObject);
begin
     if (Sender is TTreeView) and assigned(TTreeView(Sender).Selected) then //<---- check that a node is selected
     begin
       Edit2.Text := (TTreeView(Sender).Selected.Text);
     end;
end;

procedure TFrmMain.TreeView2DblClick(Sender: TObject);
var
  listitemsjson:string;
  jData : TJSONData;
   Node: TTreeNode;
   ApiReq : TApiRequest;
begin
  listitemsjson := ReadURLGet(Edit1.Text);
  jData  := GetJSON(listitemsjson);

  TreeView1.Items.Clear;
  Treeview1.Items.Add (nil,'Root Node');

  Node := TreeView1.Items[0];
  ApiReq := TApiRequest.Create;
  ApiReq.Trv := TreeView1;
  ApiReq.ShowJSONData(Node,jData);
  ApiReq.ExpandTreeNodes(TreeView1.Items, 2);  // Expand the first level of the treeview
  MemoFormatted.Text := ApiReq.FormatJsonData(jData);
  ApiReq.Free;

  jData.Free;
end;

procedure TFrmMain.TreeView2Deletion(Sender: TObject; Node: TTreeNode);
var
   p: PtrApiObject;
begin
  if (Node.Data <> nil) then begin
     p := Node.Data;
     Dispose(p);
  end;
end;



end.

