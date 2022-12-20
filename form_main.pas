unit Form_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Menus, ExtCtrls, fpjson, jsonparser,
  opensslsockets, TypInfo, Logging, Settings, Settingsmanager, Visual;
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
    ImageListCheckBox: TImageList;
    MainMenu1: TMainMenu;
    MemoFormatted: TMemo;
    MemoLongDescription: TMemo;
    MenuItem1: TMenuItem;
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
    procedure MenuItemOptionsConfigureClick(Sender: TObject);
    procedure MenuItemProgramQuitClick(Sender: TObject);
    procedure MenuItemRestorePreviousClick(Sender: TObject);
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
  end
  else begin
    TreeViewApiRequest.HotTrack := False;
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

  //Select always the rootnode when the form is created.
  if TreeViewApiRequest.Items.Count > 0 then begin
    Node := TreeViewApiRequest.Items.GetFirstNode;
    TreeViewApiRequest.Select(Node);
  end;

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
  FrmMaintain := TFrm_Maintain_Api_Data.Create(Self);
  try
    SaveTrvState(TreeViewApiRequest);
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

procedure TFrmMain.MenuItemRestorePreviousClick(Sender: TObject);
begin
  TreeViewApiRequest.BeginUpdate;
  TreeViewApiRequest.FullCollapse;
  ReadTrvState(TreeViewApiRequest);
  TreeViewApiRequest.EndUpdate;
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
  listitemsjson:string;
  jData : TJSONData;
  Node: TTreeNode;
  ApiReq : TApiRequest;
begin
  Screen.Cursor := crHourGlass;
  Node := TreeViewApiRequest.Selected;
  if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Query then begin
    if PtrApiObject(Node.Data)^.Url <> '' then begin
      SetStatusbarText(' API "'+ PtrApiObject(Node.Data)^.Name + '" wordt uitgevoerd...');

      try
        ApiReq := TApiRequest.Create;
        listitemsjson := ApiReq.ReadURLGet(PtrApiObject(Node.Data)^.Url, PtrApiObject(Node.Data)^.Token,
             PtrApiObject(Node.Data)^.AuthenticationUserName, PtrApiObject(Node.Data)^.AuthenticationPassword, PtrApiObject(Node.Data)^.Authentication);

        jData  := GetJSON(listitemsjson);

        TreeView1.Items.Clear;
        Treeview1.Items.Add (nil,'Root Node');

        Node := TreeView1.Items[0];

        ApiReq.Trv := TreeView1;
        ApiReq.ShowJSONData(Node,jData);
        ApiReq.ExpandTreeNodes(TreeView1.Items, 2);  // Expand the first level of the treeview
        MemoFormatted.Text := ApiReq.FormatJsonData(jData);
      finally
        ApiReq.Free;
        jData.Free;
        SetStatusbarText('');
        Screen.Cursor := crDefault;
      end;
    end
    else begin
      messageDlg('Fout.', 'De URL is niet gevuld. Ga naar beheer en controleer de gegevens.', mtInformation, [mbOK],0);
    end;
  end;
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

