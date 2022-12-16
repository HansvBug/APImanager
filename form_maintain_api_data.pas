unit form_maintain_api_data;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Menus, SynEdit, typinfo, fpjson, jsonparser,
  Settingsmanager, appdbFQ, AppDbFolder, AppDbQuery, Visual;

type

  { TFrm_Maintain_Api_Data }

  TFrm_Maintain_Api_Data = class(TForm)
    ButtonCancel: TButton;
    ButtonSave: TButton;
    ButtonClose: TButton;
    ButtonTestRequest: TButton;
    CheckBoxAuthentication: TCheckBox;
    EditApiName: TEdit;
    EditAuthenticationPassword: TEdit;
    EditAuthenticationUserName: TEdit;
    EditDescriptionShort: TEdit;
    EditGuid: TEdit;
    EditObjectType: TEdit;
    EditParentGuid: TEdit;
    EditUrl: TEdit;
    GroupBoxNewApiData: TGroupBox;
    GroupBoxNewApiTreeView: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    LabelApiName: TLabel;
    LabelDescriptionLong: TLabel;
    LabelDescriptionShort: TLabel;
    LabelUrl: TLabel;
    MemoApiTestRequest: TMemo;
    MemoDescriptionLong: TMemo;
    MenuItem1: TMenuItem;
    MenuItemExpandAll: TMenuItem;
    MenuItemCollapsAll: TMenuItem;
    PageControl1: TPageControl;
    PanelApiData: TPanel;
    PanelApiDataTreeView: TPanel;
    Separator2: TMenuItem;
    MenuItemDelete: TMenuItem;
    Separator1: TMenuItem;
    MenuItemAddQuery: TMenuItem;
    MenuItemAddFolder: TMenuItem;
    Panel2: TPanel;
    PopupMenuTrvApi: TPopupMenu;
    Splitter1: TSplitter;
    StatusBarApiData: TStatusBar;
    TabSheetApiData: TTabSheet;
    TabSheetApiResult: TTabSheet;
    TreeViewTestRequest: TTreeView;
    TreeViewApi: TTreeView;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonTestRequestClick(Sender: TObject);
    procedure CheckBoxAuthenticationExit(Sender: TObject);
    procedure EditApiNameChange(Sender: TObject);
    procedure EditApiNameEnter(Sender: TObject);
    procedure EditApiNameExit(Sender: TObject);
    procedure EditAuthenticationPasswordChange(Sender: TObject);
    procedure EditAuthenticationPasswordEnter(Sender: TObject);
    procedure EditAuthenticationPasswordExit(Sender: TObject);
    procedure EditAuthenticationUserNameChange(Sender: TObject);
    procedure EditAuthenticationUserNameEnter(Sender: TObject);
    procedure EditAuthenticationUserNameExit(Sender: TObject);
    procedure EditDescriptionShortChange(Sender: TObject);
    procedure EditDescriptionShortEnter(Sender: TObject);
    procedure EditDescriptionShortExit(Sender: TObject);
    procedure EditUrlChange(Sender: TObject);
    procedure EditUrlEnter(Sender: TObject);
    procedure EditUrlExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoDescriptionLongChange(Sender: TObject);
    procedure MemoDescriptionLongEnter(Sender: TObject);
    procedure MemoDescriptionLongExit(Sender: TObject);
    procedure MenuItemAddQueryClick(Sender: TObject);


    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemAddFolderClick(Sender: TObject);
    procedure TreeViewApiChange(Sender: TObject; Node: TTreeNode);

    procedure TreeViewApiClick(Sender: TObject);
    procedure TreeViewApiDblClick(Sender: TObject);
    procedure TreeViewApiDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeViewApiEditingEnd(Sender: TObject; Node: TTreeNode;
      Cancel: Boolean);

  private
    procedure SetStatusbarText(aText : String);
    procedure ReadSettings;
    procedure RestoreFormState;
    procedure SaveSettings;
    procedure Initialize;
    procedure AddRootNode;
    procedure ClearEntryData;
    procedure EnableDisableEntryComponents(ItemType : String);
    procedure SetCurrentObjectDataFolder;
    procedure SetCurrentObjectDataQuery;

    procedure CheckChanges;
    procedure SelectChildren(ANode: TTreeNode);
    procedure SetTrvActionToNil(ObjectType : String);

    procedure V_SetActiveBackGround(Sender: TObject; Enable : Boolean);
    procedure CheckEntryLength(Sender: TObject; aLength : Integer);



  public
    MaintainFolders : TFolder;
    CurrentObjectDataFolder : ApiObjectData;
    MaintainQueries : TQuery;
    CurrentObjectDataQuery : ApiObjectData;
    Visual : TVisual;
  end;

var
  Frm_Maintain_Api_Data: TFrm_Maintain_Api_Data;
  FoldersToSearchCounter : Integer;
  QueriesToSearchCounter : Integer;

implementation
uses Form_Main, Settings, ApiRequest;

{$R *.lfm}

{ TFrm_Maintain_Api_Data }

procedure TFrm_Maintain_Api_Data.SetStatusbarText(aText: String);
begin
  if aText <> '' then begin
    StatusBarApiData.Panels.Items[0].Text := ' ' + aText;
  end
  else begin
    StatusBarApiData.Panels.Items[0].Text := '';
  end;

  Application.ProcessMessages;
end;


procedure TFrm_Maintain_Api_Data.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Maintain_Api_Data.ButtonCancelClick(Sender: TObject);
begin
  FoldersToSearchCounter := 0;  // Used for saving treenode data
  QueriesToSearchCounter := 0;  // Used for saving treenode data

  // Reset
  // Folders
  SetTrvActionToNil(appdbFQ.Folder);
  SetLength(FolderList, 0);     // Empty. Don't change
  SetLength(FoldersToSearch, 0);
  MaintainFolders.UnsavedFolders := False;


  // Queries
  SetTrvActionToNil(appdbFQ.Query);
  SetLength(QueryList, 0);     // Empty. Don't change
  SetLength(QueriesToSearch, 0);
  MaintainQueries.UnsavedQueries := False;

  // Load
  MaintainFolders.GetFoldersAndQueries(TreeViewApi);
end;

procedure TFrm_Maintain_Api_Data.ButtonSaveClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  FrmMain.Logging.WriteToLogInfo('Start opslaan wijzigingen');
  if MaintainFolders.UnsavedFolders then begin
    MaintainFolders.SaveFolders;
    SetTrvActionToNil(appdbFQ.Folder);
    SetLength(FolderList, 0);     // Empty. Don't change
    SetLength(FoldersToSearch, 0);
    MaintainFolders.UnsavedFolders := False;
  end;

  if MaintainQueries.UnsavedQueries then begin
    MaintainQueries.SaveQueries;
    SetTrvActionToNil(appdbFQ.Query);  // SetTrvActionToNil(GetEnumName(TypeInfo(ApiObjectType),1)); // Set action to '' for all Queries
    SetLength(QueryList, 0);     // Empty. Don't change
    SetLength(QueriesToSearch, 0);
    MaintainQueries.UnsavedQueries := False;
  end;

  TreeViewApiClick(Sender);  // Reselect the last selected node. So FoldersToSearch is filled again.

  FrmMain.Logging.WriteToLogInfo('Gereed opslaan wijzigingen');
  ButtonSave.Enabled := False;
  Screen.Cursor := crDefault;
end;

procedure TFrm_Maintain_Api_Data.ButtonTestRequestClick(Sender: TObject);
var
  JsonText : string;
  jData : TJSONData;
  ApiReq : TApiRequest;
  Node: TTreeNode;
begin
  Node := TreeViewApi.Selected;

  if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Query then begin
    Screen.Cursor := crHourGlass;
    SetStatusbarText(' Testen API request "' + EditApiName.Text + '"...'  );

    ApiReq := TApiRequest.Create();

    JsonText := ApiReq.ReadURLGet(EditUrl.Text);
    jData  := GetJSON(JsonText);

    TreeViewTestRequest.Items.Clear;
    TreeViewTestRequest.Items.Add (nil,'Root Node');
    Node := TreeViewTestRequest.Items[0];

    ApiReq.Trv :=  TreeViewTestRequest;
    ApiReq.ShowJSONData(Node,jData);
    ApiReq.ExpandTreeNodes(TreeViewTestRequest.Items, 2);  // Expand the first level of the treeview

    ApiReq.Free;
    MemoApiTestRequest.Text := ApiReq.FormatJsonData(jData);

    jData.Free;
    SetStatusbarText('');
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrm_Maintain_Api_Data.CheckBoxAuthenticationExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Authentication := CheckBoxAuthentication.Checked;
    CheckChanges;
  end;
end;

procedure TFrm_Maintain_Api_Data.SetTrvActionToNil(ObjectType : String);
var
  Node: TTreeNode;
begin
  Node := TreeviewApi.Items.GetFirstNode;

  if Node <> nil then begin
    for Node in TreeviewApi.Items do
      if PtrApiObject(Node.Data)^.ObjectType = ObjectType then begin
        PtrApiObject(Node.Data)^.Action := '';
      end;
  end;
end;

procedure TFrm_Maintain_Api_Data.V_SetActiveBackGround(Sender: TObject;
  Enable: Boolean);
begin
  if SetMan.SetActiveBackGround then
    if Enable then begin
      Visual.ActiveTextBackGroundColor(Sender, True);
    end
    else begin
      Visual.ActiveTextBackGroundColor(Sender, false);
    end;
end;

procedure TFrm_Maintain_Api_Data.CheckEntryLength(Sender: TObject;
  aLength: Integer);
begin
  if Visual.CheckEntryLength(Sender, aLength) then begin
    ButtonSave.Enabled := True;
  end
  else begin
    ButtonSave.Enabled := False;
  end;
end;


procedure TFrm_Maintain_Api_Data.EditApiNameChange(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    Node.Text := EditApiName.Text;

    if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Folder then begin
      CheckEntryLength(Sender, 50);
    end
    else if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Query then begin
      CheckEntryLength(Sender, 100);
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.EditApiNameEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditApiNameExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Name := Node.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationPasswordChange(
  Sender: TObject);
begin
  CheckEntryLength(Sender, 100);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationPasswordEnter(Sender: TObject
  );
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationPasswordExit(Sender: TObject
  );
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.AuthenticationPassword := EditAuthenticationPassword.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationUserNameChange(
  Sender: TObject);
begin
  CheckEntryLength(Sender, 100);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationUserNameEnter(Sender: TObject
  );
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationUserNameExit(Sender: TObject
  );
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.AuthenticationUserName := EditAuthenticationUserName.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditDescriptionShortChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 255);
end;

procedure TFrm_Maintain_Api_Data.EditDescriptionShortEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditDescriptionShortExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Description_short := EditDescriptionShort.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditUrlChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 255);
end;

procedure TFrm_Maintain_Api_Data.EditUrlEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditUrlExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Url := EditUrl.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveSettings();
  TreeViewApi.Items.Clear;
  MaintainFolders.Free;
  MaintainQueries.Free;
  Visual.Free
end;

procedure TFrm_Maintain_Api_Data.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (MaintainFolders.UnsavedFolders) or (MaintainQueries.UnsavedQueries) then begin
    if MessageDlg('Let op.', 'De wijzigingen zijn nog niet opgeslagen.' + sLineBreak +
                             'Wilt u doorgaan zonder op te slaan?',
        mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then begin
          CanClose := true;
        end
    else
      CanClose := false;
  end;
end;

procedure TFrm_Maintain_Api_Data.FormCreate(Sender: TObject);
var
  ApiReq : TApiRequest;
begin
  SetStatusbarText('Ophalen gegegevens...');
  ReadSettings;
  Initialize;
  MaintainFolders := TFolder.Create;
  MaintainQueries := TQuery.Create;
  Visual := TVisual.Create;

  MaintainFolders.GetFoldersAndQueries(TreeViewApi);
  ApiReq := TApiRequest.Create;
  ApiReq.ExpandTreeNodes(TreeViewApi.Items, 2);  { #todo : Maak het antal uitgeklapte nodes optioneel }
  ApiReq.Free;

  if TreeViewApi.Items.Count = 0 then begin
    AddRootNode;
    EditApiName.Enabled := False;
  end;
  SetStatusbarText('');
end;

procedure TFrm_Maintain_Api_Data.FormShow(Sender: TObject);
begin
  RestoreFormState;
end;

procedure TFrm_Maintain_Api_Data.MemoDescriptionLongChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 10000);
end;

procedure TFrm_Maintain_Api_Data.MemoDescriptionLongEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.MemoDescriptionLongExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Description_long := MemoDescriptionLong.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.Initialize;
begin
  Caption := 'API''s  beheren';
  TreeViewApi.AutoExpand := true;
  FoldersToSearchCounter := 0;  // used for saving treenode data
  QueriesToSearchCounter := 0;  // used for saving treenode data
  ButtonTestRequest.Enabled := false;
end;

procedure TFrm_Maintain_Api_Data.AddRootNode;
var
  NewFolder : PtrApiObject;
  FolderName : String;
  Node : TTreeNode;
begin
  FolderName := Settings.ApplicationName;
  NewFolder := MaintainFolders.PrepareNewFolder(FolderName);    // prepare the folder
  TreeviewApi.Items.AddChildObject(nil, FolderName, NewFolder); // Create the folder (= rootnode)
  Node := TreeviewApi.Items.GetFirstNode;
  Node.Selected := True;
end;

procedure TFrm_Maintain_Api_Data.MenuItemAddFolderClick(Sender: TObject);
var
  Node : TTreeNode;
  NewFolder : PtrApiObject;
  FType : String;
begin
  Node := TreeViewApi.Selected;
  if Node <> nil then begin
    // Get the selected treenode type. (Folder or Query)
    FType := PtrApiObject(Node.Data)^.ObjectType;

    if FType = appdbFQ.Folder then begin // It's a Folder.
      MaintainFolders.FolderParentGuid := PtrApiObject(Node.Data)^.Guid;
      NewFolder := MaintainFolders.PrepareNewFolder('Nieuwe map');      // Create a new folder
      TreeviewApi.Items.AddChildObject(Node, 'Nieuwe map', NewFolder);  // Add the new folder to the selected folder in the TreeView.
      //Node.EditText; { #todo : optie maken of een folder naam direct in de edit mode moet staan. }
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.MenuItemAddQueryClick(Sender: TObject);
var
  Node : TTreeNode;
  NewQuery : PtrApiObject;
  FType : String;
begin
  Node := TreeViewApi.Selected;
  if Node <> nil then begin
    // Get the selected treenode type. (Folder or Query)
    FType := PtrApiObject(Node.Data)^.ObjectType;


    if FType = appdbFQ.Folder then begin                                            // It's a Folder. (Queries can only added to a Folder. Not to an other query).
      MaintainQueries.QueryParentGuid := PtrApiObject(Node.Data)^.Guid;
      NewQuery := MaintainQueries.PrepareNewQuery('Nieuw Api Request');      // Create a new query (api request)
      TreeviewApi.Items.AddChildObject(Node, 'Nieuw Api Request', NewQuery);  // Add the new query to the selected folder in the TreeView.
      //Node.EditText; { #todo : optie maken of een folder naam direct in de edit mode moet staan. }
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.MenuItemDeleteClick(Sender: TObject);
var
  Node : TTreeNode;
  aObjectType, aFolder, aQuery : String;
begin
  Node := TreeViewApi.Selected;
  FrmMain.Logging.WriteToLogInfo('Verwijderen word gestart.');

  if Node <> nil then begin
    aFolder := appdbFQ.Folder;
    aQuery := appdbFQ.Query;
    aObjectType := PtrApiObject(Node.Data)^.ObjectType;

    if aObjectType = aFolder then begin  // It's a Folder.
      if Node.GetFirstChild <> nil then begin
        if MessageDlg('Let op.', 'De onderliggende query''s en folders worden verwijderd.' + sLineBreak +
                               'Wilt u doorgaan?', mtInformation, [mbYes, mbNo], 0, mbNo) = mrYes then begin
          MaintainFolders.MarkFolderForDeletion;  // Mark the folders in Folder list for Deletion.
          MaintainQueries.MarkQueryForDeletion;   // Mark the Queries in Query list for Deletion.
          TreeViewApi.BeginUpdate;
          Node.Delete;
          TreeViewApi.EndUpdate;
        end  // MessageDlg
        else begin
          {TreeViewApi.BeginUpdate;
          MaintainFolders.MarkFolderForDeletion;  // Mark the folders in Folder list for Deletion.
          MaintainQueries.MarkQueryForDeletion;   // Mark the Queries in Query list for Deletion.
          Node.Delete;
          TreeViewApi.EndUpdate;}
        end;
      end   // Node.GetFirstChild
      else begin
        TreeViewApi.BeginUpdate;
        MaintainFolders.MarkFolderForDeletion;  // Mark the folders in Folder list for Deletion.
        Node.Delete;
        TreeViewApi.EndUpdate;
      end;
    end     // aObjectType = aFolder
    else if aObjectType = aQuery then begin  // It's a Query.
      if Node.GetFirstChild = nil then begin  // Query can't have a child
        TreeViewApi.BeginUpdate;
        MaintainQueries.MarkQueryForDeletion;  // Mark the Queries in Query list for Deletion.
        Node.Delete;
        TreeViewApi.EndUpdate;
      end;  // Node.GetFirstChild
    end;
  end;
  FrmMain.Logging.WriteToLogInfo('Verwijderen is gereed.');
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiChange(Sender: TObject;
  Node: TTreeNode);
var
  ObjectType : String;
begin
  try

    // Pop-up menu
    if Node <> nil then begin
      if Assigned(Node) then begin
        if Node.AbsoluteIndex >= 0 then begin
          TreeViewApi.PopupMenu := PopupMenuTrvApi;
        end
      end
      else begin
        TreeViewApi.PopupMenu := nil;
      end;
    end;

    if (Node <> nil) and (Node.Level > 0)  then begin
      ObjectType := PtrApiObject(Node.Data)^.ObjectType;

      // Initialize pop-up menu
      if ObjectType <> '' then begin
        if ObjectType = appdbFQ.Folder then begin  // GetEnumName(TypeInfo(ApiObjectType),0)
          // Folder
          MenuItemAddFolder.Enabled := true;
          MenuItemAddQuery.Enabled := true;
        end
        else begin
          // Query
          MenuItemAddFolder.Enabled := false;
          MenuItemAddQuery.Enabled := false;
        end;

        // show data
        ClearEntryData;
        { #todo : Moet een aparte functie worden zodat rootnode ook mee gaat }
        EditGuid.Text:= PtrApiObject(Node.Data)^.Guid;
        EditParentGuid.Text:= PtrApiObject(Node.Data)^.ParentFolder;
        EditObjectType.Text := ObjectType;
        case ObjectType of
          appdbFQ.Folder: begin
                     EnableDisableEntryComponents(appdbFQ.Folder);
                     EditUrl.Enabled := false;
                     CheckBoxAuthentication.Enabled := false;
                     EditAuthenticationUserName.Enabled := false;
                     EditAuthenticationPassword.Enabled := false;
                     EditDescriptionShort.Enabled := false;
                     MemoDescriptionLong.Enabled := false;
                     ButtonTestRequest.Enabled := false;

                     CheckBoxAuthentication.Checked := false;
                     EditApiName.Text := PtrApiObject(Node.Data)^.Name;
                     EditAuthenticationUserName.Text := '';
                     EditAuthenticationPassword.Text := '';
                     EditDescriptionShort.Text := '';
                     MemoDescriptionLong.Text := '';

                    end;
          appdbFQ.Query:  begin
                      EnableDisableEntryComponents(appdbFQ.Query);
                      EditUrl.Enabled := true;
                      CheckBoxAuthentication.Enabled := true;
                      EditAuthenticationUserName.Enabled := true;
                      EditAuthenticationPassword.Enabled := true;
                      EditDescriptionShort.Enabled := true;
                      MemoDescriptionLong.Enabled := true;
                      ButtonTestRequest.Enabled := true;

                      EditApiName.Text := PtrApiObject(Node.Data)^.Name;
                      EditUrl.Text := PtrApiObject(Node.Data)^.Url;
                      CheckBoxAuthentication.Checked := PtrApiObject(Node.Data)^.Authentication;
                      EditAuthenticationUserName.Text := PtrApiObject(Node.Data)^.AuthenticationUserName;
                      EditAuthenticationPassword.Text := PtrApiObject(Node.Data)^.AuthenticationPassword;
                      EditDescriptionShort.Text := PtrApiObject(Node.Data)^.Description_short;
                      MemoDescriptionLong.Text :=  PtrApiObject(Node.Data)^.Description_long;
                    end;
          else begin
            EditApiName.Text := Settings.ApplicationName;
          end;
        end;
      end;
    end
    else if (Node <> nil) and (Node.Level = 0)  then begin
      ObjectType := PtrApiObject(Node.Data)^.ObjectType;
      if ObjectType = appdbFQ.Folder then begin
        EditApiName.Enabled := false;
        EditApiName.Text := PtrApiObject(Node.Data)^.Name;  // Root Node
        ButtonTestRequest.Enabled := false;
      end;
    end;

  except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogDebug('');
          FrmMain.Logging.WriteToLogDebug('NAKIJKEN <<<----------------');
          FrmMain.Logging.WriteToLogError('Melding:');
          FrmMain.Logging.WriteToLogError(E.Message);
        end
  end;



end;

procedure TFrm_Maintain_Api_Data.ClearEntryData;
begin
  EditApiName.Text := '';
  EditUrl.Text := '';
  CheckBoxAuthentication.Checked := false;
  EditAuthenticationUserName.Text := '';
  EditAuthenticationPassword.Text := '';
end;

procedure TFrm_Maintain_Api_Data.EnableDisableEntryComponents(ItemType: String);
var
  Node: TTreeNode;
begin
  Node := TreeViewApi.Selected;
  if Node <> nil then begin
    case ItemType of
      appdbFQ.Folder: begin
                  if Node.AbsoluteIndex = 0 then begin
                    EditApiName.Enabled := False;
                  end
                  else begin
                    EditApiName.Enabled := True;
                  end;
                   //...
                end;
      appdbFQ.Query:  begin
                  if Node.AbsoluteIndex = 0 then begin
                    EditApiName.Enabled := False;
                  end
                  else begin
                    EditApiName.Enabled := True;
                  end;
                  //..
                end;
      'All_Off':begin
                  EditApiName.Enabled := False
                end;
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.CheckChanges;
var
  aName , aFolderGuid, aObjectType, aParentFolder, aAction : String;
  aQueryGuid, aUrl, aAuthenticationUserName, aAuthenticationPassword : String;
  aDescription_short, aDescription_long : String;
  aAuthentication : Boolean;
  i, Counter : Integer;
var
  Node: TTreeNode;
  ObjectFound : Boolean;
begin
  Node := TreeViewApi.Selected;

  if Node <> nil then begin
    aName := PtrApiObject(Node.Data)^.Name;
    aFolderGuid :=  PtrApiObject(Node.Data)^.Guid;
    aQueryGuid :=  PtrApiObject(Node.Data)^.Guid;
    aObjectType := PtrApiObject(Node.Data)^.ObjectType;
    aParentFolder := PtrApiObject(Node.Data)^.ParentFolder;
    aAction := PtrApiObject(Node.Data)^.Action;
    aUrl := PtrApiObject(Node.Data)^.Url;
    aDescription_short := PtrApiObject(Node.Data)^.Description_short;
    aDescription_long := PtrApiObject(Node.Data)^.Description_long;
    aAuthentication := PtrApiObject(Node.Data)^.Authentication;
    aAuthenticationUserName := PtrApiObject(Node.Data)^.AuthenticationUserName;
    aAuthenticationPassword := PtrApiObject(Node.Data)^.AuthenticationPassword;

    // Folders
    if aObjectType = appdbFQ.Folder then begin // GetEnumName(TypeInfo(ApiObjectType),0)
      if (aName <> CurrentObjectDataFolder.Name) or
         (aFolderGuid <> CurrentObjectDataFolder.Guid) or
         (aObjectType <> CurrentObjectDataFolder.ObjectType) or
         (aParentFolder <> CurrentObjectDataFolder.ParentFolder) or
         (aAction <> CurrentObjectDataFolder.Action) then
        begin
          ObjectFound := False;
          // check if folder exists in FolderList
          for i := 0 to Length(FolderList) -1 do begin
            if FolderList[i].Guid = CurrentObjectDataFolder.Guid then begin
              FolderList[i].Name := aName;
              FolderList[i].ObjectType := aObjectType;
              FolderList[i].ParentFolder := aParentFolder;
              FolderList[i].Date_Modified := Now;
              FolderList[i].ModifiedBy := SysUtils.GetEnvironmentVariable('USERNAME');
              ObjectFound := True;
              MaintainFolders.UnsavedFolders := True;

              if  aAction = 'Insert' then begin // new folder always insert. Even when the names is changed (updated)
                FolderList[i].Action := 'Insert';
              end
              else begin
                FolderList[i].Action := 'Update';
              end;
            end;
          end; // end loop

          if not ObjectFound then begin
            Counter := Length(FolderList) + 1;
            SetLength(FolderList, Counter);

            FolderList[Counter-1].Guid := aFolderGuid;
            FolderList[Counter-1].Name := aName;
            FolderList[Counter-1].ObjectType := aObjectType;
            FolderList[Counter-1].ParentFolder := aParentFolder;
            FolderList[Counter-1].Action := 'Update';
            FolderList[Counter-1].Date_Modified := Now;
            FolderList[Counter-1].ModifiedBy := SysUtils.GetEnvironmentVariable('USERNAME');
            MaintainFolders.UnsavedFolders := True;
          end;
        end;
    end // end Folders
    else if aObjectType = appdbFQ.Query then begin  // Query
      if (aName <> CurrentObjectDataQuery.Name) or
         (aQueryGuid <> CurrentObjectDataQuery.Guid) or
         (aObjectType <> CurrentObjectDataQuery.ObjectType) or
         (aParentFolder <> CurrentObjectDataQuery.ParentFolder) or
         (aAction <> CurrentObjectDataQuery.Action) or
         (aUrl <> CurrentObjectDataQuery.Url) or
         (aAuthentication <> CurrentObjectDataQuery.Authentication) or
         (aAuthenticationUserName <> CurrentObjectDataQuery.AuthenticationUserName) or
         (aAuthenticationPassword <> CurrentObjectDataQuery.AuthenticationPassword) or
         (aDescription_short <> CurrentObjectDataQuery.Description_short) or
         (aDescription_long <> CurrentObjectDataQuery.Description_long) then
        begin
          ObjectFound := False;
          // check if query exists in QueryList
          for i := 0 to Length(QueryList) -1 do begin
            if QueryList[i].Guid = CurrentObjectDataQuery.Guid then begin
              QueryList[i].Name := aName;
              QueryList[i].ObjectType := aObjectType;
              QueryList[i].ParentFolder := aParentFolder;
              QueryList[i].Url := aUrl;
              QueryList[i].Authentication := aAuthentication;
              QueryList[i].AuthenticationUserName := aAuthenticationUserName;
              QueryList[i].AuthenticationPassword := aAuthenticationPassword;
              QueryList[i].Description_short := aDescription_short;
              QueryList[i].Description_long := aDescription_long;
              QueryList[i].Date_Modified := Now;
              QueryList[i].ModifiedBy := SysUtils.GetEnvironmentVariable('USERNAME');
              ObjectFound := True;
              MaintainQueries.UnsavedQueries := True;

              if  aAction = 'Insert' then begin // new query always insert. Even when the names is changed (updated)
                QueryList[i].Action := 'Insert';
              end
              else begin
                QueryList[i].Action := 'Update';
              end;
            end;
          end; // end loop

          if not ObjectFound then begin
            Counter := Length(QueryList) + 1;
            SetLength(QueryList, Counter);

            QueryList[Counter-1].Guid := aQueryGuid;
            QueryList[Counter-1].Name := aName;
            QueryList[Counter-1].ObjectType := aObjectType;
            QueryList[Counter-1].ParentFolder := aParentFolder;
            QueryList[Counter-1].Action := 'Update';
            QueryList[Counter-1].Url := aUrl;
            QueryList[Counter-1].Authentication := aAuthentication;
            QueryList[Counter-1].AuthenticationUserName := aAuthenticationUserName;
            QueryList[Counter-1].AuthenticationPassword := aAuthenticationPassword;
            QueryList[Counter-1].Description_short := aDescription_short;
            QueryList[Counter-1].Description_long := aDescription_long;
            QueryList[Counter-1].Date_Modified := Now;
            QueryList[Counter-1].ModifiedBy := SysUtils.GetEnvironmentVariable('USERNAME');
            MaintainQueries.UnsavedQueries := True;
          end;
        end;
    end;
  end;  // node <> nil
end;


procedure TFrm_Maintain_Api_Data.TreeViewApiClick(Sender: TObject);
var
  Node: TTreeNode;
  ObjectType : String;
begin
  try
      // Selected tree node
  Node := TreeViewApi.Selected;
  if Node <> nil then
    ObjectType := PtrApiObject(Node.Data)^.ObjectType;

  // PopMenu enable/disble delete function
  if (Node <> nil) and (Node.Parent = nil) then begin
    MenuItemDelete.Enabled := false;
    TreeViewApi.ReadOnly := True;
  end
  else begin
    MenuItemDelete.Enabled := true;
    TreeViewApi.ReadOnly := False;
  end;

  // Park the current object data. Used to signal a mutation.
  if Node <> nil then begin
    if ObjectType <> '' then begin
      if ObjectType = appdbFQ.Folder then begin
        SetCurrentObjectDataFolder;
      end
      else if ObjectType = appdbFQ.Query then begin
        SetCurrentObjectDataQuery;
      end;
    end;

    // Get all guids. Needed for deleting a tree Node
    TreeViewApi.BeginUpdate;

    FoldersToSearchCounter := 1;
    if Length(FoldersToSearch) > 0 then begin
      SetLength(FoldersToSearch, FoldersToSearchCounter);
    end;
    SetLength(FoldersToSearch, FoldersToSearchCounter);

    QueriesToSearchCounter := 1;
    if Length(QueriesToSearch) > 0 then begin
      SetLength(QueriesToSearch, QueriesToSearchCounter);
    end;
    SetLength(QueriesToSearch, QueriesToSearchCounter);

    SelectChildren(TreeViewApi.Selected);
    TreeViewApi.Selected := Node;
    TreeViewApi.EndUpdate;
  end;

  except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogDebug('');
          FrmMain.Logging.WriteToLogDebug('NAKIJKEN <<<----------------');
          FrmMain.Logging.WriteToLogError('Melding:');
          FrmMain.Logging.WriteToLogError(E.Message);
        end
  end;



end;

procedure TFrm_Maintain_Api_Data.SetCurrentObjectDataFolder;
var
  Node: TTreeNode;
begin
  Node := TreeViewApi.Selected;
  if Node <> nil then begin
    CurrentObjectDataFolder.Name := PtrApiObject(Node.Data)^.Name;
    CurrentObjectDataFolder.Guid := PtrApiObject(Node.Data)^.Guid;
    CurrentObjectDataFolder.ObjectType := PtrApiObject(Node.Data)^.ObjectType;
    CurrentObjectDataFolder.ParentFolder := PtrApiObject(Node.Data)^.ParentFolder;
    CurrentObjectDataFolder.Action := PtrApiObject(Node.Data)^.Action;
  end;
end;

procedure TFrm_Maintain_Api_Data.SetCurrentObjectDataQuery;
var
  Node: TTreeNode;
begin
  Node := TreeViewApi.Selected;
  if Node <> nil then begin
    CurrentObjectDataQuery.Name := PtrApiObject(Node.Data)^.Name;
    CurrentObjectDataQuery.Guid := PtrApiObject(Node.Data)^.Guid;
    CurrentObjectDataQuery.ObjectType := PtrApiObject(Node.Data)^.ObjectType;
    CurrentObjectDataQuery.ParentFolder := PtrApiObject(Node.Data)^.ParentFolder;
    CurrentObjectDataQuery.Action := PtrApiObject(Node.Data)^.Action;

    CurrentObjectDataQuery.Url := PtrApiObject(Node.Data)^.Url;
    CurrentObjectDataQuery.Authentication := PtrApiObject(Node.Data)^.Authentication;
    CurrentObjectDataQuery.AuthenticationUserName := PtrApiObject(Node.Data)^.AuthenticationUserName;
    CurrentObjectDataQuery.AuthenticationPassword := PtrApiObject(Node.Data)^.AuthenticationPassword;
    CurrentObjectDataQuery.Description_short := PtrApiObject(Node.Data)^.Description_short;
    CurrentObjectDataQuery.Description_long := PtrApiObject(Node.Data)^.Description_long;
  end;
end;

procedure TFrm_Maintain_Api_Data.SelectChildren(ANode: TTreeNode);
begin
  if ANode = nil then
    exit;

  SetLength(FoldersToSearch, FoldersToSearchCounter);  // Folders
  SetLength(QueriesToSearch, QueriesToSearchCounter);  // Queries
  ANode.Selected := true;

  // Folders
  if PtrApiObject(ANode.Data)^.ObjectType = appdbFQ.Folder then begin
    FoldersToSearch[FoldersToSearchCounter-1].Guid := PtrApiObject(ANode.Data)^.Guid;
    FoldersToSearch[FoldersToSearchCounter-1].Action := PtrApiObject(ANode.Data)^.Action;
    FoldersToSearch[FoldersToSearchCounter-1].Name := PtrApiObject(ANode.Data)^.Name;  // only used for debugging
    FoldersToSearchCounter += 1;
  end
  else if PtrApiObject(ANode.Data)^.ObjectType = appdbFQ.Query then begin
    // Queries
    QueriesToSearch[QueriesToSearchCounter-1].Guid := PtrApiObject(ANode.Data)^.Guid;
    QueriesToSearch[QueriesToSearchCounter-1].Action := PtrApiObject(ANode.Data)^.Action;
    QueriesToSearch[QueriesToSearchCounter-1].Name := PtrApiObject(ANode.Data)^.Name;  // only used for debugging
    QueriesToSearchCounter += 1;
  end;

  ANode := ANode.GetFirstChild;

  while ANode <> nil do begin
    SelectChildren(ANode);
    ANode := ANode.GetNextSibling;
  end;
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  // Avoid modifying the root node
  Node := TreeViewApi.Selected;
  if Node.AbsoluteIndex = 0 then begin
    TreeViewApi.ReadOnly := True;
  end
  else begin
    TreeViewApi.ReadOnly := False;
  end;
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiDeletion(Sender: TObject;
  Node: TTreeNode);
var
   p: PtrApiObject;
begin
  if (Node.Data <> nil) then begin
     p := Node.Data;
     Dispose(p);
  end;
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiEditingEnd(Sender: TObject;
  Node: TTreeNode; Cancel: Boolean);
var
  aNode : TTreeNode;
begin
  aNode := TreeViewApi.Selected;
  if aNode <> nil then begin
    EditApiName.Text:= aNode.Text;
    PtrApiObject(aNode.Data)^.Name := aNode.Text;
    CheckChanges;
  end;
end;

procedure TFrm_Maintain_Api_Data.ReadSettings;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.Free;
end;

procedure TFrm_Maintain_Api_Data.RestoreFormState;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.RestoreFormState(self);
  SetMan.Free;
end;

procedure TFrm_Maintain_Api_Data.SaveSettings;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.StoreFormState(self);
  SetMan.Free;
end;



end.

