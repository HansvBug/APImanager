unit form_maintain_api_data;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Menus, SynEdit, typinfo, fpjson, jsonparser,
  Settingsmanager, appdbFQ, AppDbFolder, AppDbQuery, Visual, RichMemo;

type

  { TFrm_Maintain_Api_Data }

  TFrm_Maintain_Api_Data = class(TForm)
    Button1: TButton;
    ButtonCancelCurent: TButton;
    ButtonNext: TButton;
    ButtonUndo: TButton;
    ButtonSave: TButton;
    ButtonClose: TButton;
    ButtonTestRequest: TButton;
    CheckBoxAuthentication: TCheckBox;
    ComboBoxRequestType: TComboBox;
    EditPagingSearchText: TEdit;
    EditToken: TEdit;
    EditApiName: TEdit;
    EditAuthenticationPassword: TEdit;
    EditAuthenticationUserName: TEdit;
    EditDescriptionShort: TEdit;
    EditGuid: TEdit;
    EditObjectType: TEdit;
    EditParentGuid: TEdit;
    EditTrvSearch: TEdit;
    EditUrl: TEdit;
    GroupBoxNewApiData: TGroupBox;
    GroupBoxNewApiTreeView: TGroupBox;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelRequestType: TLabel;
    LabelRequestBody: TLabel;
    LabelPagingSearchText: TLabel;
    LabelSearchResult: TLabel;
    LabelToken: TLabel;
    Label6: TLabel;
    LabelApiName: TLabel;
    LabelDescriptionLong: TLabel;
    LabelDescriptionShort: TLabel;
    LabelUrl: TLabel;
    MemoRequestBody: TMemo;
    MemoApiTestRequest: TMemo;
    MemoDescriptionLong: TMemo;
    MenuItemRestorePrevious: TMenuItem;
    MenuItemRest: TMenuItem;
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
    SplitterMainTainApiDataFrm1: TSplitter;
    StatusBarApiData: TStatusBar;
    TabSheetApiData: TTabSheet;
    TabSheetApiResult: TTabSheet;
    TreeViewTestRequest: TTreeView;
    TreeViewApi: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure ButtonCancelCurentClick(Sender: TObject);
    procedure ButtonCancelCurentMouseLeave(Sender: TObject);
    procedure ButtonCancelCurentMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonNextClick(Sender: TObject);
    procedure ButtonUndoClick(Sender: TObject);
    procedure ButtonUndoMouseLeave(Sender: TObject);
    procedure ButtonUndoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonCloseMouseLeave(Sender: TObject);
    procedure ButtonCloseMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonTestRequestClick(Sender: TObject);
    procedure ButtonTestRequestMouseLeave(Sender: TObject);
    procedure ButtonTestRequestMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure CheckBoxAuthenticationChange(Sender: TObject);
    procedure CheckBoxAuthenticationExit(Sender: TObject);
    procedure CheckBoxAuthenticationMouseLeave(Sender: TObject);
    procedure CheckBoxAuthenticationMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxRequestTypeChange(Sender: TObject);
    procedure ComboBoxRequestTypeEnter(Sender: TObject);
    procedure ComboBoxRequestTypeExit(Sender: TObject);
    procedure ComboBoxRequestTypeMouseLeave(Sender: TObject);
    procedure ComboBoxRequestTypeMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure EditApiNameChange(Sender: TObject);
    procedure EditApiNameEnter(Sender: TObject);
    procedure EditApiNameExit(Sender: TObject);
    procedure EditApiNameMouseLeave(Sender: TObject);
    procedure EditApiNameMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EditAuthenticationPasswordChange(Sender: TObject);
    procedure EditAuthenticationPasswordEnter(Sender: TObject);
    procedure EditAuthenticationPasswordExit(Sender: TObject);
    procedure EditAuthenticationPasswordMouseLeave(Sender: TObject);
    procedure EditAuthenticationPasswordMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure EditAuthenticationUserNameChange(Sender: TObject);
    procedure EditAuthenticationUserNameEnter(Sender: TObject);
    procedure EditAuthenticationUserNameExit(Sender: TObject);
    procedure EditAuthenticationUserNameMouseLeave(Sender: TObject);
    procedure EditAuthenticationUserNameMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure EditDescriptionShortChange(Sender: TObject);
    procedure EditDescriptionShortEnter(Sender: TObject);
    procedure EditDescriptionShortExit(Sender: TObject);
    procedure EditDescriptionShortMouseLeave(Sender: TObject);
    procedure EditDescriptionShortMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure EditPagingSearchTextChange(Sender: TObject);
    procedure EditPagingSearchTextEnter(Sender: TObject);
    procedure EditPagingSearchTextExit(Sender: TObject);
    procedure EditPagingSearchTextMouseLeave(Sender: TObject);
    procedure EditPagingSearchTextMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure EditTokenChange(Sender: TObject);
    procedure EditTokenEnter(Sender: TObject);
    procedure EditTokenExit(Sender: TObject);
    procedure EditTokenMouseLeave(Sender: TObject);
    procedure EditTokenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EditTrvSearchChange(Sender: TObject);
    procedure EditUrlChange(Sender: TObject);
    procedure EditUrlEnter(Sender: TObject);
    procedure EditUrlExit(Sender: TObject);
    procedure EditUrlMouseLeave(Sender: TObject);
    procedure EditUrlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoDescriptionLongChange(Sender: TObject);
    procedure MemoDescriptionLongEnter(Sender: TObject);
    procedure MemoDescriptionLongExit(Sender: TObject);
    procedure MemoDescriptionLongMouseLeave(Sender: TObject);
    procedure MemoDescriptionLongMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MemoRequestBodyChange(Sender: TObject);
    procedure MemoRequestBodyEnter(Sender: TObject);
    procedure MemoRequestBodyExit(Sender: TObject);
    procedure MemoRequestBodyMouseLeave(Sender: TObject);
    procedure MemoRequestBodyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MenuItemRestClick(Sender: TObject);
    procedure MenuItemAddQueryClick(Sender: TObject);
    procedure MenuItemCollapsAllClick(Sender: TObject);


    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemAddFolderClick(Sender: TObject);
    procedure MenuItemExpandAllClick(Sender: TObject);
    procedure MenuItemRestorePreviousClick(Sender: TObject);
    procedure TreeViewApiChange(Sender: TObject; Node: TTreeNode);

    procedure TreeViewApiClick(Sender: TObject);
    procedure TreeViewApiDblClick(Sender: TObject);
    procedure TreeViewApiDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeViewApiDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewApiDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewApiEditingEnd(Sender: TObject; Node: TTreeNode;
      Cancel: Boolean);

  private
    Visual : TVisual;
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
    function  V_SetHelpText(Sender: TObject; aText: string) : String;
    procedure CheckEntryLength(Sender: TObject; aLength : Integer);
    procedure SaveTrvState(Trv : TTReeView);
    procedure ReadTrvState(Trv: TTReeView);


  public
    MaintainFolders : TFolder;
    CurrentObjectDataFolder : ApiObjectData;
    MaintainQueries : TQuery;
    CurrentObjectDataQuery : ApiObjectData;
  end;

var
  Frm_Maintain_Api_Data: TFrm_Maintain_Api_Data;
  FoldersToSearchCounter : Integer;
  QueriesToSearchCounter : Integer;
  SelectedNode: TTreeNode;

implementation
uses Form_Main, Settings, ApiRequest, AppDbMaintain, Treeview_utils;

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

procedure TFrm_Maintain_Api_Data.ButtonCloseMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.ButtonCloseMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Sluit het API beheer. Eventuele wijzigingen moeten eerst zijn opgeslagen.'));
end;

procedure TFrm_Maintain_Api_Data.ButtonUndoClick(Sender: TObject);
begin
  if MessageDlg('Let op.', 'Alle wijzigingen die na het opslaan zijn uitgevoerd, worden verwijderd.' + sLineBreak +
                           'Wilt u doorgaan met vernieuwen?',
                mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then begin

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
    TreeViewApi.BeginUpdate;
    SaveTrvState(TreeViewApi);
    MaintainFolders.GetFoldersAndQueries(TreeViewApi);
    ReadTrvState(TreeViewApi);
    TreeViewApi.EndUpdate;
  end;
end;

procedure TFrm_Maintain_Api_Data.ButtonUndoMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.ButtonUndoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Let op, alle wijzigingen na de laatste keer opslaan, worden ongedaan gemaakt. Ook toegevoegde items worden weggehaald.'));
end;

procedure TFrm_Maintain_Api_Data.Button1Click(Sender: TObject);
{ #todo : Functie van maken. In het hoofdscherm is bijna identieke code aanwezig. }
var
  dlg : TSaveDialog;
begin
  if MemoApiTestRequest.Lines.Count <= 0 then exit;

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
     MemoApiTestRequest.Lines.SaveToFile(dlg.FileName);
   end;
  finally
    Screen.Cursor := crDefault;
    dlg.Free;
  end;
end;

procedure TFrm_Maintain_Api_Data.ButtonCancelCurentClick(Sender: TObject);
begin
  EditApiName.Text := 'Nieuw Api Request';
  EditUrl.Text := '';
  EditToken.Text := '';
  CheckBoxAuthentication.Checked := false;
  EditAuthenticationUserName.Text := '';
  EditAuthenticationPassword.Text := '';
  EditPagingSearchText.Text := '';
  EditDescriptionShort.Text := '';
  MemoDescriptionLong.Text := '';
end;

procedure TFrm_Maintain_Api_Data.ButtonCancelCurentMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.ButtonCancelCurentMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Maak de invoervelden leeg.'));
end;

procedure TFrm_Maintain_Api_Data.ButtonNextClick(Sender: TObject);
begin
  SearchNextTrv(TreeViewApi);
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
    SetTrvActionToNil(appdbFQ.Query);
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
  ApiReq : TApiRequest;
  Node: TTreeNode;
begin
  Screen.Cursor := crHourGlass;
  Node := TreeViewApi.Selected;

  if (EditUrl.Text <> '') and (ComboBoxRequestType.Text <> '') then begin
    ApiReq := TApiRequest.Create();
    try
      { #todo : Check if text <> '' }
      ApiReq.ApiRequestData[0].ObjectType := PtrApiObject(Node.Data)^.ObjectType;
      ApiReq.ApiRequestData[0].Url :=  EditUrl.Text;
      ApiReq.ApiRequestData[0].Token :=EditToken.Text;
      ApiReq.ApiRequestData[0].AuthenticationUserName := EditAuthenticationUserName.Text;
      ApiReq.ApiRequestData[0].AuthenticationPassword := EditAuthenticationPassword.Text;
      ApiReq.ApiRequestData[0].Authentication := CheckBoxAuthentication.Checked;
      ApiReq.ApiRequestData[0].Paging_searchtext := EditPagingSearchText.Text;
      ApiReq.ApiRequestData[0].Request_body := MemoRequestBody.Text;
      ApiReq.ApiRequestData[0].HTTP_Methode := ComboBoxRequestType.Text;

      ApiReq.GetJsondata(TreeViewTestRequest, StatusBarApiData, MemoApiTestRequest);
    finally
      ApiReq.Free;
    end;

    PageControl1.ActivePage := TabSheetApiResult;
  end
  else begin
    messageDlg('Fout.', 'De URL of de HTTP Methode ontbreekt.', mtInformation, [mbOK],0);
    if EditUrl.Text = '' then begin
      ActiveControl := EditUrl;
    end;
    if ComboBoxRequestType.Text = '' then begin
      ActiveControl := ComboBoxRequestType;
    end;
  end;

  Screen.Cursor := crDefault;
end;

procedure TFrm_Maintain_Api_Data.ButtonTestRequestMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.ButtonTestRequestMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Als de benodigde gegevens zijn ingevoerd kunt u de API testen.'));
end;

procedure TFrm_Maintain_Api_Data.CheckBoxAuthenticationChange(Sender: TObject);
begin
  if CheckBoxAuthentication.Checked then begin
    EditAuthenticationUserName.Enabled := True;
    EditAuthenticationPassword.Enabled := True;
  end
  else begin
    EditAuthenticationUserName.Enabled := False;
    EditAuthenticationPassword.Enabled := False;
    EditAuthenticationUserName.Text := '';
    EditAuthenticationPassword.Text := '';
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

procedure TFrm_Maintain_Api_Data.CheckBoxAuthenticationMouseLeave(
  Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.CheckBoxAuthenticationMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vink aan indien de API gebruik maakt van authentication gegevens.'));
end;

procedure TFrm_Maintain_Api_Data.ComboBoxRequestTypeChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 10);
end;

procedure TFrm_Maintain_Api_Data.ComboBoxRequestTypeEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.ComboBoxRequestTypeExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.HTTP_Methode := ComboBoxRequestType.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.ComboBoxRequestTypeMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.ComboBoxRequestTypeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul de benodigde HTTP methode in. (Verplicht).'));
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

function TFrm_Maintain_Api_Data.V_SetHelpText(Sender: TObject; aText: string) : String;
begin
  if SetMan.DisplayHelpText then begin
    Result := Visual.Helptext(Sender, aText);
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

procedure TFrm_Maintain_Api_Data.SaveTrvState(Trv: TTReeView);
var
  db : TAppDbMaintain;
begin
  db := TAppDbMaintain.Create;
  db.SaveTreeViewState(Trv);
  db.Free;
end;

procedure TFrm_Maintain_Api_Data.ReadTrvState(Trv: TTReeView);
var
  db : TAppDbMaintain;
begin
  db := TAppDbMaintain.Create;
  db.ReadTreeViewState(Trv);
  db.Free;
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

procedure TFrm_Maintain_Api_Data.EditApiNameMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditApiNameMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul een korte beschrijvende naam in.'));
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

procedure TFrm_Maintain_Api_Data.EditAuthenticationPasswordMouseLeave(
  Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationPasswordMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul het wachtwoord in.'));
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

procedure TFrm_Maintain_Api_Data.EditAuthenticationUserNameMouseLeave(
  Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditAuthenticationUserNameMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul de gebruikersnaam in die voor de authenticatie nodig is.'));
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

procedure TFrm_Maintain_Api_Data.EditDescriptionShortMouseLeave(Sender: TObject
  );
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditDescriptionShortMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Hier kan korte omschrijving van de API worden gezet.'));
end;

procedure TFrm_Maintain_Api_Data.EditPagingSearchTextChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 100);
end;

procedure TFrm_Maintain_Api_Data.EditPagingSearchTextEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditPagingSearchTextExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Paging_searchtext := EditPagingSearchText.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditPagingSearchTextMouseLeave(Sender: TObject
  );
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditPagingSearchTextMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Welk woordt geeft het aantal pagina''s in de json aan? Zet dat woord hier neer. Of eventueel het pad. Bijvoorbeeld: [info][pages]'));
end;

procedure TFrm_Maintain_Api_Data.EditTokenChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 100);
end;

procedure TFrm_Maintain_Api_Data.EditTokenEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.EditTokenExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Token := EditToken.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.EditTokenMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditTokenMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul de benodigde token in.'));
end;

procedure TFrm_Maintain_Api_Data.EditTrvSearchChange(Sender: TObject);
begin
  TreeViewApi.MultiSelect := True;  { #todo : Multiselect meot anders. Wordt bij zoeken aangezet en in treeview click weer uitgezet. }
  LabelSearchResult.Caption := IntToStr(GetNodeByText(TreeViewApi, EditTrvSearch.Text)) + ' st.';
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

procedure TFrm_Maintain_Api_Data.EditUrlMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.EditUrlMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Vul de URL van API in. Als een token nodig is vervang deze door : [Token] en zet de echte token in het Token veld.'));
end;

procedure TFrm_Maintain_Api_Data.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveSettings();
  SaveTrvState(TreeViewApi);
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
  Node : TTreeNode;
begin
  SetStatusbarText('Ophalen gegegevens...');
  ReadSettings;
  Initialize;
  MaintainFolders := TFolder.Create;
  MaintainQueries := TQuery.Create;
  Visual := TVisual.Create;

  MaintainFolders.GetFoldersAndQueries(TreeViewApi);
  ReadTrvState(TreeViewApi);

  if TreeViewApi.Items.Count = 0 then begin
    AddRootNode;
    EditApiName.Enabled := False;
  end;

  //Select always the rootnode when the form is created.
  Node := TreeViewApi.Items.GetFirstNode;
  TreeViewApi.Select(Node);

  PageControl1.ActivePage := TabSheetApiData;
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

procedure TFrm_Maintain_Api_Data.MemoDescriptionLongMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.MemoDescriptionLongMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Hier kan een uitvorige beschrijving van de API worden gemaakt.'));
end;

procedure TFrm_Maintain_Api_Data.MemoRequestBodyChange(Sender: TObject);
begin
  CheckEntryLength(Sender, 500);
end;

procedure TFrm_Maintain_Api_Data.MemoRequestBodyEnter(Sender: TObject);
begin
  V_SetActiveBackGround(Sender, True);
end;

procedure TFrm_Maintain_Api_Data.MemoRequestBodyExit(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TreeViewApi.Items.Count > 0 then begin
    Node := TreeViewApi.Selected;
    PtrApiObject(Node.Data)^.Request_body := MemoRequestBody.Text;
    CheckChanges;
  end;

  V_SetActiveBackGround(Sender, False);
end;

procedure TFrm_Maintain_Api_Data.MemoRequestBodyMouseLeave(Sender: TObject);
begin
  SetStatusbarText(V_SetHelpText(Sender, ''));
end;

procedure TFrm_Maintain_Api_Data.MemoRequestBodyMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetStatusbarText(V_SetHelpText(Sender, 'Als de requst een body verwacht kunt u die hier invoeren.'));
end;

procedure TFrm_Maintain_Api_Data.MenuItemRestClick(Sender: TObject);
var
  ApiReq : TApiRequest;
begin
  TreeViewApi.BeginUpdate;
  SaveTrvState(TreeViewApi);
  TreeViewApi.FullCollapse;
  ApiReq := TApiRequest.Create();
  ApiReq.ExpandTreeNodes(TreeViewApi.Items, 2);
  ApiReq.Free;
  TreeViewApi.EndUpdate;
end;

procedure TFrm_Maintain_Api_Data.Initialize;
begin
  Caption := 'API''s  beheren';
  FoldersToSearchCounter := 0;  // used for saving treenode data
  QueriesToSearchCounter := 0;  // used for saving treenode data
  ButtonTestRequest.Enabled := false;
  ButtonCancelCurent.Enabled := false;
  ButtonUndo.Enabled := false;
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
      Node := TreeviewApi.Items.AddChildObject(Node, 'Nieuwe map', NewFolder);  // Add the new folder to the selected folder in the TreeView.
      Node.ImageIndex := 1;
      Node.Expand(False);
      Node.Parent.Expand(False);
      //Node.EditText; { #todo : optie maken of een folder naam direct in de edit mode moet staan. }
      MaintainFolders.UnsavedFolders := true;
      ButtonCancelCurent.Enabled := true;
      ButtonUndo.Enabled := true;
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.MenuItemExpandAllClick(Sender: TObject);
begin
  SaveTrvState(TreeViewApi);
  TreeViewApi.FullExpand;
end;

procedure TFrm_Maintain_Api_Data.MenuItemRestorePreviousClick(Sender: TObject);
begin
  TreeViewApi.BeginUpdate;
  TreeViewApi.FullCollapse;
  ReadTrvState(TreeViewApi);
  TreeViewApi.EndUpdate;
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


    if FType = appdbFQ.Folder then begin                                      // It's a Folder. (Queries can only added to a Folder. Not to an other query).
      MaintainQueries.QueryParentGuid := PtrApiObject(Node.Data)^.Guid;
      NewQuery := MaintainQueries.PrepareNewQuery('Nieuw Api Request');       // Create a new query (api request)
      TreeviewApi.Items.AddChildObject(Node, 'Nieuw Api Request', NewQuery);  // Add the new query to the selected folder in the TreeView.
      Node.Expand(False);                                                     // Expand the new node direct.
      //Node.EditText; { #todo : optie maken of een folder naam direct in de edit mode moet staan. }
      MaintainQueries.UnsavedQueries := true;
      ButtonCancelCurent.Enabled := true;
      ButtonUndo.Enabled := true;
    end;
  end;
end;

procedure TFrm_Maintain_Api_Data.MenuItemCollapsAllClick(Sender: TObject);
begin
  SaveTrvState(TreeViewApi);
  TreeViewApi.FullCollapse;
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
        end;  // MessageDlg
      end     // Node.GetFirstChild
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
      Node.SelectedIndex:=Node.ImageIndex;  // // Keep image visible
      if Assigned(Node) then begin
        if Node.AbsoluteIndex >= 0 then begin // add pop-up menu.
          if Node.AbsoluteIndex = 0 then begin
            MenuItemDelete.Enabled := false;  // Disalbe delete when Rootnode is selected.
          end;
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
                     EditToken.Enabled := false;
                     CheckBoxAuthentication.Enabled := false;
                     EditAuthenticationUserName.Enabled := false;
                     EditAuthenticationPassword.Enabled := false;
                     EditDescriptionShort.Enabled := false;
                     MemoDescriptionLong.Enabled := false;
                     ButtonTestRequest.Enabled := false;
                     EditPagingSearchText.Enabled := false;
                     MemoRequestBody.Enabled := false;
                     ComboBoxRequestType.Enabled := false;

                     CheckBoxAuthentication.Checked := false;
                     EditApiName.Text := PtrApiObject(Node.Data)^.Name;
                     EditToken.Text := '';;
                     EditAuthenticationUserName.Text := '';
                     EditAuthenticationPassword.Text := '';
                     EditDescriptionShort.Text := '';
                     MemoDescriptionLong.Text := '';
                     EditPagingSearchText.Text := '';
                     MemoRequestBody.Text := '';
                     ComboBoxRequestType.Text := '';

                    end;
          appdbFQ.Query:  begin
                      EnableDisableEntryComponents(appdbFQ.Query);
                      EditUrl.Enabled := true;
                      EditToken.Enabled := true;
                      CheckBoxAuthentication.Enabled := true;
                      EditAuthenticationUserName.Enabled := true;
                      EditAuthenticationPassword.Enabled := true;
                      EditDescriptionShort.Enabled := true;
                      MemoDescriptionLong.Enabled := true;
                      ButtonTestRequest.Enabled := true;
                      EditPagingSearchText.Enabled := true;
                      MemoRequestBody.Enabled := true;
                      ComboBoxRequestType.Enabled := true;

                      EditApiName.Text := PtrApiObject(Node.Data)^.Name;
                      EditUrl.Text := PtrApiObject(Node.Data)^.Url;
                      EditToken.Text := PtrApiObject(Node.Data)^.Token;

                      CheckBoxAuthentication.Checked := PtrApiObject(Node.Data)^.Authentication;

                      if CheckBoxAuthentication.Checked then begin
                        EditAuthenticationUserName.Enabled := true;
                        EditAuthenticationPassword.Enabled := true;
                      end
                      else begin
                        EditAuthenticationUserName.Enabled := false;
                        EditAuthenticationPassword.Enabled := false;
                      end;

                      EditAuthenticationUserName.Text := PtrApiObject(Node.Data)^.AuthenticationUserName;
                      EditAuthenticationPassword.Text := PtrApiObject(Node.Data)^.AuthenticationPassword;
                      EditDescriptionShort.Text := PtrApiObject(Node.Data)^.Description_short;
                      MemoDescriptionLong.Text :=  PtrApiObject(Node.Data)^.Description_long;
                      EditPagingSearchText.Text := PtrApiObject(Node.Data)^.Paging_searchtext;
                      MemoRequestBody.Text := PtrApiObject(Node.Data)^.Request_body;

                      if ComboBoxRequestType.Text = '' then begin
                        ComboBoxRequestType.ItemIndex := 1;  // Default ComboBoxRequestType.Text = 'Get'
                      end
                      else begin
                        ComboBoxRequestType.Text := PtrApiObject(Node.Data)^.HTTP_Methode;
                      end;
                    end;
          else begin
            EditApiName.Text := Settings.ApplicationName;
          end;
        end;
      end;
      EditApiName.selstart := EditApiName.Gettextlen; // set the cursor at the end of the string.
    end
    else if (Node <> nil) and (Node.Level = 0)  then begin
      ObjectType := PtrApiObject(Node.Data)^.ObjectType;
      if ObjectType = appdbFQ.Folder then begin
        EditApiName.Enabled := false;
        EditApiName.Text := PtrApiObject(Node.Data)^.Name;  // Root Node
        ButtonTestRequest.Enabled := false;

        EditUrl.Enabled := false;
        EditToken.Enabled := false;
        CheckBoxAuthentication.Enabled := false;
        EditAuthenticationUserName.Enabled := false;
        EditAuthenticationPassword.Enabled := false;
        EditDescriptionShort.Enabled := false;
        MemoDescriptionLong.Enabled := false;
        EditPagingSearchText.Enabled := false;
        MemoRequestBody.Enabled := false;
        ComboBoxRequestType.Enabled := false;
        ButtonTestRequest.Enabled := false;
      end;
    end;
  except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogDebug('');
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
  aDescription_short, aDescription_long, aToken, aPagingSearchText, aSalt: String;
  aRequest_body, aHttpMethod : String;
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
    aToken := PtrApiObject(Node.Data)^.Token;
    aSalt := PtrApiObject(Node.Data)^.Salt;
    aPagingSearchText := PtrApiObject(Node.Data)^.Paging_searchtext;
    aHttpMethod := PtrApiObject(Node.Data)^.HTTP_Methode;
    aRequest_body := PtrApiObject(Node.Data)^.Request_body;

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
         (aDescription_long <> CurrentObjectDataQuery.Description_long) or
         (aToken <> CurrentObjectDataQuery.Token) or
         (aPagingSearchtext <> CurrentObjectDataQuery.Paging_searchtext) or
         (aRequest_body <> CurrentObjectDataQuery.Request_body) or
         (aHttpMethod <> CurrentObjectDataQuery.HTTP_Methode) then
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
              QueryList[i].Token := aToken;
              QueryList[i].Paging_searchtext := aPagingSearchtext;
              QueryList[i].Salt := aSalt;
              QueryList[i].Request_body := aRequest_body;
              QueryList[i].HTTP_Methode := aHttpMethod;
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
            QueryList[Counter-1].Token := aToken;
            QueryList[Counter-1].Salt := aSalt;
            QueryList[Counter-1].Paging_searchtext := aPagingSearchtext;
            QueryList[Counter-1].Request_body := aRequest_body;
            QueryList[Counter-1].HTTP_Methode := aHttpMethod;
            MaintainQueries.UnsavedQueries := True;
          end;
        end;
    end;
  end;  // node <> nil

  if (MaintainFolders.UnsavedFolders) or (MaintainQueries.UnsavedQueries) then begin
    ButtonCancelCurent.Enabled := true;
    ButtonUndo.Enabled := true;
  end
  else begin
    ButtonCancelCurent.Enabled := false;
    ButtonUndo.Enabled := false;
  end;
end;


procedure TFrm_Maintain_Api_Data.TreeViewApiClick(Sender: TObject);
var
  Node: TTreeNode;
  ObjectType : String;
  tmp : String;
begin
  SelectedNode := TreeViewApi.Selected; // Used with dragdrop
  try
      // Selected tree node
    Node := TreeViewApi.Selected;

    if Node <> nil then begin
      ObjectType := PtrApiObject(Node.Data)^.ObjectType;
    end;

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
          SetCurrentObjectDataFolder;  // hold the current Node data object.
        end
        else if ObjectType = appdbFQ.Query then begin
          SetCurrentObjectDataQuery;   // hold the current Node data object.
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

      TreeViewApi.MultiSelect := False;  { #todo : Multiselect meot anders. Wordt bij zoeken aangezet en in treeview click weer uitgezet. }
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
    CurrentObjectDataQuery.Token := PtrApiObject(Node.Data)^.Token;
    CurrentObjectDataQuery.Salt := PtrApiObject(Node.Data)^.Salt;
    CurrentObjectDataQuery.Request_body := PtrApiObject(Node.Data)^.Request_body;
    CurrentObjectDataQuery.HTTP_Methode := PtrApiObject(Node.Data)^.HTTP_Methode;
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

  if SetMan.SetTreeViewHotTrack then begin
    TreeViewApi.HotTrack := True;
    TreeViewTestRequest.HotTrack := True;
  end
  else begin
    TreeViewApi.HotTrack := False;
    TreeViewTestRequest.HotTrack := False;
  end;

  SetMan.Free;
end;

procedure TFrm_Maintain_Api_Data.RestoreFormState;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.RestoreFormState(self);
  Setman.RestoreSplitterPos(SplitterMainTainApiDataFrm1);
  SetMan.Free;
end;

procedure TFrm_Maintain_Api_Data.SaveSettings;
var
  SetMan : TSettingsManager;
begin
  SetMan := TSettingsManager.Create();
  SetMan.StoreFormState(self);
  SetMan.StoreSplitterPos(SplitterMainTainApiDataFrm1);
  SetMan.Free;
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  Node: TTreeNode;
  SelNodeIsFolder, SelNodeIsQuery : Boolean;
  DestNodeIsFolder, DestNodeIsQuery : Boolean;
  CanDrop : Boolean;
begin
  TreeViewApi := TTreeView(Sender);    { Sender is TreeView where the data is being dropped  }
  Node := TreeViewApi.GetNodeAt(x,y);  { x,y are drop coordinates (relative to the Sender)   }
                                       {   since Sender is TreeView we can evaluate          }
                                       {   a tree at the X,Y coordinates                     }

  CanDrop := false;

  // Selected treenode
  if PtrApiObject(SelectedNode.Data)^.ObjectType = appdbFQ.Folder then begin
    SelNodeIsFolder := True;
    SelNodeIsQuery := False;
  end
  else begin
    SelNodeIsFolder := False;
    SelNodeIsQuery := True;
  end;

  // drop
  if PtrApiObject(Node.Data)^.ObjectType = appdbFQ.Folder then begin
    DestNodeIsFolder := True;
    DestNodeIsQuery := False;
  end
  else begin
    DestNodeIsFolder := False;
    DestNodeIsQuery := True;
  end;

  // Queries can not load on queries.
  // Folders can not load on queries.

  if (SelNodeIsQuery) and (DestNodeIsFolder) then begin  // query on folder
    CanDrop := True;
  end
  else if (SelNodeIsFolder) and (DestNodeIsFolder) then begin  // folder on folder
    CanDrop := True;
  end
  else if (SelNodeIsQuery) and (DestNodeIsQuery) then begin
    messageDlg('Let op.', 'U kunt géén Query op een Query droppen.' + sLineBreak +  sLineBreak +
                           'Een Query kan op een Folder worden gedropped.'
                         , mtInformation, [mbOK],0);
    CanDrop := false;
  end
  else if (SelNodeIsFolder) and (DestNodeIsQuery) then begin
  messageDlg('Let op.', 'U kunt géén Folder op een Query droppen.' + sLineBreak +  sLineBreak +
                         'Een Folder kan op een andere Folder worden gedropped.'
                       , mtInformation, [mbOK],0);
    CanDrop := false;
  end;

  if CanDrop then begin
    if Source = Sender then                       { drop is happening within a TreeView   }
      begin
        if Assigned(TreeViewApi.Selected) and     {  check if any node has been selected  }
          (Node <> TreeViewApi.Selected) then     {   and we're dropping to another node  }
            begin
              if Node <> nil then begin
                TreeViewApi.Selected.MoveTo(Node, naAddChild); { complete drop, by moving selected node }
                PtrApiObject(SelectedNode.Data)^.ParentFolder := PtrApiObject(Node.Data)^.Guid; // Alter the parentfolder of the dragged treenode.
              end
              else begin
                TreeViewApi.Selected.MoveTo(Node, naAdd);     { complete drop, by moving selected node in root }
                PtrApiObject(SelectedNode.Data)^.ParentFolder := PtrApiObject(Node.Data)^.Guid;  // Alter the parentfolder of the dragged treenode.
              end;
            end;
      end;
  end;
end;

procedure TFrm_Maintain_Api_Data.TreeViewApiDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := true;
end;

end.

