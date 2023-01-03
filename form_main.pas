unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, LCLTranslator,
  Menus, ExtCtrls, fpjson, jsonparser,
  opensslsockets, TypInfo, Logging, Settings, Settingsmanager, Visual, form_about;
{
  Download and extract the libeay32.dll and ssleay32.dll files from https://indy.fulgan.com/SSL/ into project folder.
  AMD add opensslsockets unit.
}

type

  { TFrmMain }

  TFrmMain = class(TForm)
    Button2: TButton;
    ButtonSaveMemoToJson: TButton;
    EditShortDescription: TEdit;
    ImageList1: TImageList;
    ImageListCheckBox: TImageList;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MemoFormatted: TMemo;
    MemoLongDescription: TMemo;
    MenuItem1: TMenuItem;
    MenuItemOptionsAbout: TMenuItem;
    MenuItemOptionsLanguageEN: TMenuItem;
    MenuItemOptionsLanguageNL: TMenuItem;
    MenuItemOptionsLanguage: TMenuItem;
    Separator1: TMenuItem;
    MenuItemProgramOpenJsonFile: TMenuItem;
    MenuItemRestorePrevious: TMenuItem;
    MenuItemExpandAll: TMenuItem;
    MenuItemCollapsAll: TMenuItem;
    MenuItemOptionsConfigure: TMenuItem;
    MenuItemOptions: TMenuItem;
    MenuItemMaintainApiStrings: TMenuItem;
    MenuItemMaintain: TMenuItem;
    MenuItemProgram: TMenuItem;
    MenuItemProgramQuit: TMenuItem;
    PanelApirequestsTrvSub2: TPanel;
    PanelApirequestsTrvSub1: TPanel;
    PanelApiResult: TPanel;
    PanelApirequestsTrvMain: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PanelApiResultMemo: TPanel;
    PanelApiResultTrv: TPanel;
    PopupMenuApiRequestTrv: TPopupMenu;
    SplitterMainFrm3: TSplitter;
    SplitterMainFrm2: TSplitter;
    SplitterMainFrm1: TSplitter;
    StatusBarMainFrm: TStatusBar;
    TreeView1: TTreeView;
    TreeViewApiRequest: TTreeView;
    procedure ButtonSaveMemoToJsonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItemExpandAllClick(Sender: TObject);
    procedure MenuItemCollapsAllClick(Sender: TObject);
    procedure MenuItemMaintainApiStringsClick(Sender: TObject);
    procedure MenuItemOptionsAboutClick(Sender: TObject);
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemOptionsLanguageENClick(Sender: TObject);
    procedure MenuItemOptionsLanguageNLClick(Sender: TObject);
    procedure MenuItemProgramOpenJsonFileClick(Sender: TObject);
    procedure MenuItemProgramQuitClick(Sender: TObject);
    procedure MenuItemRestorePreviousClick(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
    procedure TreeViewApiRequestChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewApiRequestClick(Sender: TObject);
    procedure TreeViewApiRequestDblClick(Sender: TObject);
    procedure TreeViewApiRequestDeletion(Sender: TObject; Node: TTreeNode);
  private
    FDisableProgramItems : String;
    FDebugMode :Boolean;

    procedure Initialize;
    procedure CheckAppEnvironment;
    procedure DisableFunctions;
    procedure ReadSettings;
    procedure SaveSettings;
    procedure SaveTrvState(Trv : TTReeView);
    procedure ReadTrvState(Trv: TTReeView);
    procedure StartLogging;
    procedure RestoreFormState;
    procedure SetStatusbarText(aText : String);
    procedure LoadFoldersAndQueries;
    procedure CreateApplicationDataBase;
    function ProcessArguments :  String;
    procedure CopyAppDbFile;
    function V_SetHelpText(Sender: TObject; aText: string) : String;

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
uses applicationenvironment, AppDbCreate, AppDbMaintain, Encryption,
  form_maintain_api_data, Form_Configure, appdbFQ, AppDbFolder, ApiRequest, LCLIntf;


{------------------------------------------------------------------------------}

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

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveTrvState(TreeViewApiRequest);
  SaveSettings;
end;

procedure TFrmMain.ButtonSaveMemoToJsonClick(Sender: TObject);
var
  dlg : TSaveDialog;
begin
  if MemoFormatted.Lines.Count <= 0 then exit;

  Screen.Cursor := crHourGlass;
  dlg := TSaveDialog.Create(nil);
  try
   dlg.Title := 'Opslaan als json bestand.';
   dlg.InitialDir := GetCurrentDir;
   dlg.Filter := 'Json file|*.json|Text file|*.txt';
   dlg.DefaultExt := 'json';
   dlg.FilterIndex := 0;

   if dlg.Execute then begin
     Screen.Cursor := crDefault;
     MemoFormatted.Lines.SaveToFile(dlg.FileName);
   end;
  finally
    Screen.Cursor := crDefault;
    dlg.Free;
  end;
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

  if SetMan.SetTreeViewHotTrack then begin
    TreeViewApiRequest.HotTrack := True;
    TreeView1.HotTrack := True;
  end
  else begin
    TreeViewApiRequest.HotTrack := False;
    TreeView1.HotTrack := False;
  end;
end;

procedure TFrmMain.StartLogging;
begin
  Logging := TLog_File.Create();
  Logging.ActivateLogging := SetMan.ActivateLogging;
  Logging.AppendLogFile := Setman.AppendLogFile;
  Logging.StartLogging;
end;

procedure TFrmMain.Initialize;
var
  Node : TTreeNode;
  dbMaintain : TAppDbMaintain;
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

  if SetMan.DefaultLanguage = 'nl' then begin
    MenuItemOptionsLanguageEN.Checked := False;
    MenuItemOptionsLanguageNL.Checked := True;
    SetDefaultLang('nl');
  end
  else begin
    MenuItemOptionsLanguageEN.Checked := True;
    MenuItemOptionsLanguageNL.Checked := False;
    SetDefaultLang('en');
  end;

  LoadFoldersAndQueries;

  //Select always the rootnode when the form is created.
  if TreeViewApiRequest.Items.Count > 0 then begin
    Node := TreeViewApiRequest.Items.GetFirstNode;
    TreeViewApiRequest.Select(Node);
  end;

  // Optimize the app. database.
  dbMaintain := TAppDbMaintain.Create;
  dbMaintain.ResetAutoIncrementAll;
  dbMaintain.Optimze;
  dbMaintain.Free;
  Screen.Cursor := crDefault;

  SetStatusbarText('Welkom');
  CopyAppDbFile;
  DisableFunctions;
end;

procedure TFrmMain.LoadFoldersAndQueries;
var
  MaintainFolders : TFolder;
  DbFile : String;
begin
  DbFile := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;

  if FileExists(DbFile) then begin
    SetStatusbarText('Ophalen gegegevens...');
    MaintainFolders := TFolder.Create;
    MaintainFolders.GetFoldersAndQueries(TreeViewApiRequest);
    MaintainFolders.Free;
    ReadTrvState(TreeViewApiRequest);
    SetStatusbarText('');
  end
  else begin
    Logging.WriteToLogWarning('Het applicatie database bestand is niet gevonden.');
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

function TFrmMain.V_SetHelpText(Sender: TObject; aText: string) : String;
begin
  if SetMan.DisplayHelpText then begin
    Result := Visual.Helptext(Sender, aText);
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
         Result := 'DebugMode=On';
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
  Setman.RestoreSplitterPos(SplitterMainFrm1);
  Setman.RestoreSplitterPos(SplitterMainFrm2);
  Setman.RestoreSplitterPos(SplitterMainFrm3);
end;

procedure TFrmMain.SaveSettings;
begin
  SetMan.SaveSettings;
  SetMan.StoreFormState(self);
  SetMan.StoreSplitterPos(SplitterMainFrm1);
  SetMan.StoreSplitterPos(SplitterMainFrm2);
  SetMan.StoreSplitterPos(SplitterMainFrm3);
end;

procedure TFrmMain.SaveTrvState(Trv: TTReeView);
var
  db : TAppDbMaintain;
begin
  db := TAppDbMaintain.Create;
  db.SaveTreeViewState(Trv);
  db.Free;
end;

procedure TFrmMain.ReadTrvState(Trv: TTReeView);
var
  db : TAppDbMaintain;
begin
  db := TAppDbMaintain.Create;
  db.ReadTreeViewState(Trv);
  db.Free;
end;

procedure TFrmMain.DisableFunctions;
begin
  if DisableProgramItems = 'Volledig uit' then begin
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

procedure TFrmMain.MenuItem1Click(Sender: TObject);
var
  ApiReq : TApiRequest;
begin
  TreeViewApiRequest.BeginUpdate;
  SaveTrvState(TreeViewApiRequest);
  TreeViewApiRequest.FullCollapse;
  ApiReq := TApiRequest.Create();
  ApiReq.ExpandTreeNodes(TreeViewApiRequest.Items, 2);
  ApiReq.Free;
  TreeViewApiRequest.EndUpdate;
end;

procedure TFrmMain.MenuItemExpandAllClick(Sender: TObject);
begin
  SaveTrvState(TreeViewApiRequest);
  TreeViewApiRequest.FullExpand;
end;

procedure TFrmMain.MenuItemCollapsAllClick(Sender: TObject);
begin
  SaveTrvState(TreeViewApiRequest);
  TreeViewApiRequest.FullCollapse;
end;

procedure TFrmMain.MenuItemMaintainApiStringsClick(Sender: TObject);
var
  FrmMaintain : TFrm_Maintain_Api_Data;
begin
  Screen.Cursor := crHourGlass;
  SetStatusbarText('Ophalen gegevens...');
  FrmMaintain := TFrm_Maintain_Api_Data.Create(Self);
  try
    SaveTrvState(TreeViewApiRequest);
    SetStatusbarText('');
      Screen.Cursor := crDefault;
    FrmMaintain.ShowModal;
  finally
    FrmMaintain.Free;
    LoadFoldersAndQueries;
  end;
end;

procedure TFrmMain.MenuItemOptionsAboutClick(Sender: TObject);
var
  About : TFrm_About;
begin
  About := TFrm_About.Create(self);
  try
    About.ShowModal;
  finally
    About.Free;
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

procedure TFrmMain.MenuItemOptionsLanguageENClick(Sender: TObject);
begin
  MenuItemOptionsLanguageEN.Checked := True;
  MenuItemOptionsLanguageNL.Checked := False;
  SetDefaultLang('en');
  SetMan.DefaultLanguage := 'en';
  GetLocaleFormatSettings($409, DefaultFormatSettings);
end;

procedure TFrmMain.MenuItemOptionsLanguageNLClick(Sender: TObject);
begin
  MenuItemOptionsLanguageEN.Checked := False;
  MenuItemOptionsLanguageNL.Checked := True;
  SetDefaultLang('nl');
  SetMan.DefaultLanguage := 'nl';
  GetLocaleFormatSettings($413, DefaultFormatSettings);
end;

procedure TFrmMain.MenuItemProgramOpenJsonFileClick(Sender: TObject);
var
  OpenFileDlg : TOpenDialog;
  Memo : TMemo;
  ApiReq : TApiRequest;
begin
  Screen.Cursor := crHourGlass;
  TreeViewApiRequest.Selected := nil;
  Memo := TMemo.Create(Self);
  OpenFileDlg := TOpenDialog.Create(Self);
  //OpenFileDlg.InitialDir := ...
  OpenFileDlg.Filter := 'Json file|*.json||Text file|*.txt';
  OpenFileDlg.Title := 'Open een JSON bestand';
  if OpenFileDlg.Execute then
    begin
      Memo.Lines.LoadFromFile(OpenFileDlg.FileName);
    end;
  OpenFileDlg.Free;

  ApiReq := TApiRequest.Create();
  ApiReq.GetJsonTExtFile(Treeview1, StatusBarMainFrm, Memo, MemoFormatted);
  ApiReq.Free;
  Memo.Free;

  TreeView1.Selected := TreeView1.Items.GetFirstNode;
  MemoFormatted.SetFocus;
  MemoFormatted.SelStart := 0;
  Screen.Cursor := crDefault;
end;

procedure TFrmMain.MenuItemProgramQuitClick(Sender: TObject);
begin
  Screen.Cursor := crHOurglass;
  SetStatusbarText('Aflsuiten...');
  Close;
end;

procedure TFrmMain.MenuItemRestorePreviousClick(Sender: TObject);
begin
  TreeViewApiRequest.BeginUpdate;
  TreeViewApiRequest.FullCollapse;
  ReadTrvState(TreeViewApiRequest);
  TreeViewApiRequest.EndUpdate;
end;

procedure TFrmMain.TreeView1Click(Sender: TObject);
var
  Node : TTreeNode;
  JsonData : TJSONData;
  aString : String;
begin
{  Node :=  TreeView1.Selected;
  JsonData := TJsonData(Node.Data);

   aString := '';

  case JsonData.JSONType of
    jtArray, jtObject:
      begin
        If (JsonData.JSONType=jtArray) then
          aString := SArray
      end;
  end;
   Memo1.Text := aString;
 }
end;

procedure TFrmMain.TreeView1SelectionChanged(Sender: TObject);
begin
  if (Sender is TTreeView) and assigned(TTreeView(Sender).Selected) then //<---- check that a node is selected
  begin
   //
  end;
end;

procedure TFrmMain.TreeViewApiRequestChange(Sender: TObject; Node: TTreeNode);
begin
  if Node <> nil then begin
    Node.SelectedIndex:=Node.ImageIndex;  // Keep image visible
    if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Query then begin
      EditShortDescription.Text := PtrApiObject(Node.Data)^.Description_short;
      MemoLongDescription.Text := PtrApiObject(Node.Data)^.Description_long;
    end
    else begin
      EditShortDescription.Text := '';
      MemoLongDescription.Text := '';
    end;
  end;
end;

procedure TFrmMain.TreeViewApiRequestClick(Sender: TObject);
var
  Node : TTreeNode;
  P: TPoint;
  ht: THitTests;
begin
  // "Checkboxes"
  GetCursorPos(P);
  P := TreeViewApiRequest.ScreenToClient(P);
  ht := TreeViewApiRequest.GetHitTestInfoAt(P.X, P.Y);
  if (htOnStateIcon in ht) then begin
    Node := TreeViewApiRequest.GetNodeAt(P.X, P.Y);
    Visual.ToggleTreeViewCheckBoxes(Node);
  end;
end;

procedure TFrmMain.TreeViewApiRequestDblClick(Sender: TObject);
var
  Node: TTreeNode;
  ApiReq : TApiRequest;
begin
  Screen.Cursor := crHourGlass;
  Node := TreeViewApiRequest.Selected;

  try
    ApiReq := TApiRequest.Create();
    { #todo : Check if text <> '' }
    ApiReq.ApiRequestData[0].ObjectType := PtrApiObject(Node.Data)^.ObjectType;
    ApiReq.ApiRequestData[0].Url :=  PtrApiObject(Node.Data)^.Url;
    ApiReq.ApiRequestData[0].Token := PtrApiObject(Node.Data)^.token;
    ApiReq.ApiRequestData[0].AuthenticationUserName := PtrApiObject(Node.Data)^.AuthenticationUserName;
    ApiReq.ApiRequestData[0].AuthenticationPassword := PtrApiObject(Node.Data)^.AuthenticationPassword;
    ApiReq.ApiRequestData[0].Authentication := PtrApiObject(Node.Data)^.Authentication;
    ApiReq.ApiRequestData[0].Paging_searchtext := PtrApiObject(Node.Data)^.Paging_searchtext;

    ApiReq.GetJsondata(Treeview1, StatusBarMainFrm, MemoFormatted);
  finally
    ApiReq.Free;
  end;

  SetStatusbarText(' Uitgevoerd: ' + Node.Text);
  Screen.Cursor := crDefault;
end;

procedure TFrmMain.TreeViewApiRequestDeletion(Sender: TObject; Node: TTreeNode);
var
   p: PtrApiObject;
begin
  if (Node.Data <> nil) then begin
     p := Node.Data;
     Dispose(p);
  end;
end;



end.

