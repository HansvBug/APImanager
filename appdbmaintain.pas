unit AppDbMaintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Windows, fileutil, ComCtrls,
  AppDb;
//  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
type

  { TAppDbMaintain }

  TAppDbMaintain = class(TAppDatabase)
    private
      function IsFileInUse(FileName: TFileName): Boolean;
      procedure SaveTrvStateInsert(TrvName, NodeState : string; Node : TTreeNode);
      procedure SaveTrvStateUpdate(TrvName, NodeState : string; Node : TTreeNode);
    protected
    public
      constructor Create; overload;
      destructor  Destroy; override;

      procedure CompressAppDatabase;
      function CopyDbFile: Boolean;
      procedure SaveTreeViewState(Trv: TTreeView);
      procedure ReadTreeViewState(Trv: TTreeView);
      procedure Optimze;
      procedure ResetAutoIncrementAll;
      procedure ResetAutoIncrementTbl(aTblName : String);  // Not used

    published
  end;


implementation

uses Form_Main, DataModule, Settings, Tablename, Db, appdbFQ;

{ TFolder }

function TAppDbMaintain.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  result := False;
  if not FileExists(FileName) then exit;

  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  result := (HFileRes = INVALID_HANDLE_VALUE);

  if not result then CloseHandle(HFileRes);
end;

constructor TAppDbMaintain.Create;
begin
  inherited;
  //..
end;

destructor TAppDbMaintain.Destroy;
begin
  //..
  inherited Destroy;
end;

procedure TAppDbMaintain.CompressAppDatabase;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('VACUUM');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('De database is schoongemaakt en verkleind.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij het comprimeren van de applicatie database.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het comprimeren van de applicatie database.', mtError, [mbOK],0);
    end;
  end;
end;

function TAppDbMaintain.CopyDbFile: Boolean;
var
  Prefix : String;
  SrcFilename, DestFilename : String;
begin
  SrcFilename := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;

  if not IsFileInUse(SrcFilename) then begin
    Prefix := FormatDateTime('YYYYMMDD_', Now);
    DestFilename := ExtractFilePath(Application.ExeName) + Settings.DatabaseFolder + PathDelim + Settings.BackupFolder + PathDelim + Prefix + Settings.DatabaseName;

    if FileExists(SrcFilename) then begin
      if not FileExists(DestFilename) then begin
        CopyFile(SrcFilename, DestFilename);
        FrmMain.Logging.WriteToLogInfo('Kopie van de applicatie database is gemaakt.');
        FrmMain.Logging.WriteToLogInfo('Kopie is: ' + DestFilename);
        Result := True;
      end
      else begin
        if MessageDlg('Let op.', 'Het bestand bestaat al. Wilt u het overschrijven?'  + sLineBreak +
                                 sLineBreak +
                                 'Bestand: ' + DestFilename,
                                 mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then begin
           CopyFile(SrcFilename, DestFilename, [cffOverwriteFile]);
           FrmMain.Logging.WriteToLogInfo('Kopie van de applicatie database is gemaakt.');
           FrmMain.Logging.WriteToLogInfo('Kopie is: ' + DestFilename);
           Result := True;
           end;
      end;
    end
    else begin
      messageDlg('Fout.', 'Het database bestand is niet gevonden.', mtError, [mbOK],0);
      Result := False;
    end;
  end
  else begin
    messageDlg('Let op.', 'Het bestand is in gebruik (door iemand anders). ' +sLineBreak +
                        'Er wordt géén kopie gemaakt.' , mtWarning, [mbOK],0);
    Result := False;
  end;
end;

procedure TAppDbMaintain.SaveTreeViewState(Trv: TTreeView);
var
  Node : TTreeNode;
begin
  Node := Trv.Items.GetFirstNode;

  while Assigned(Node) do
  begin
    if Node.Expanded then begin
      SaveTrvStateInsert(Trv.Name, 'Expanded', Node);
      SaveTrvStateUpdate(Trv.Name, 'Expanded', Node);
    end
    else begin
      SaveTrvStateInsert(Trv.Name, 'Collapsed', Node);
      SaveTrvStateUpdate(Trv.Name, 'Collapsed', Node);
    end;

    Node := Node.GetNext;
  end;
end;

procedure TAppDbMaintain.ReadTreeViewState(Trv: TTreeView);
var
  SqlText : String;
  NodeGuid, NodeState : String;
  i : Integer;
  Node : TTreeNode;
  s : String;
begin
  SqlText := 'select GUID_NODE, ITEM_DATA, ITEM_INFO ';
  SqlText += 'from ' + SETTINGS_APP + ' ';
  SqlText += 'where ITEM_INFO = :ITEM_INFO;';

  s := '';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;
      SQLQuery.Params.ParamByName('ITEM_INFO').AsString := Trv.Name;
      s := Trv.Name;
      SQLite3Connection.Open;
      SQLQuery.Open;
      SQLQuery.First;

      while not SQLQuery.Eof do begin
        NodeGuid := SQLQuery.FieldByName('GUID_NODE').AsString;
        NodeState := SQLQuery.FieldByName('ITEM_DATA').AsString;

        if NodeState = 'Expanded'then begin
          s := Trv.Name + ' -  ' + NodeGuid;
          for i := 0 to trv.Items.Count -1 do begin
            Node := trv.Items[i];
            if PtrApiObject(Node.Data)^.Guid = NodeGuid then begin
              trv.Items[i].Expand(false);
              //if PtrApiObject(Node.Data)^.Guid = '{C7C1F61F-0E23-4D63-AA3F-E1F76A501752}' then
              //  s := '';
            end
          end;
        end;

        SQLQuery.next;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het inlezen van de Node States uit tabel ' + SETTINGS_APP + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het inlezen van de Node States is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TAppDbMaintain.Optimze;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma optimize;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('De database is geoptimaliseerd.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij het optimaliseren van de applicatie database.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het optimaliseren van de applicatie database.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementAll;
var
  SqlText : String;
begin
  SqlText := 'delete from sqlite_sequence';
  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      FrmMain.Logging.WriteToLogInfo('De ID''s van alle tabellen zijn gereset.');
    except
      on E : Exception do begin
        FrmMain.Logging.WriteToLogError('Fout bij resetten van alle id''s.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij resetten van alle id''s.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementTbl(aTblName: String);
var
  SqlText : String;
begin
  SqlText := 'delete from sqlite_sequence where name = :TABLE_NAME';
  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;
      SQLQuery.Params.ParamByName('TABLE_NAME').AsString := aTblName;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      FrmMain.Logging.WriteToLogInfo('De ID''s van de tabel ' + aTblName +  ' zijn gereset.');
    except
      on E : Exception do begin
        FrmMain.Logging.WriteToLogError('Fout bij resetten van de id''s.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij resetten van de id''s.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TAppDbMaintain.SaveTrvStateInsert(TrvName, NodeState: string; Node : TTreeNode);
var
  SqlText : String;
begin
  SqlText := 'insert into ' + SETTINGS_APP + ' (GUID, GUID_NODE, LOGGED_IN_USER, ITEM_DATA, ITEM_INFO) ' +
             'select :GUID, :GUID_NODE, :LOGGED_IN_USER, :ITEM_DATA, :ITEM_INFO ' +
             'where not exists (select GUID_NODE from ' + SETTINGS_APP + ' where GUID_NODE = :GUID_NODE '+
             'and ITEM_INFO = :ITEM_INFO);';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID').AsString := TGUID.NewGuid.ToString();
      SQLQuery.Params.ParamByName('GUID_NODE').AsString := PtrApiObject(Node.Data)^.Guid;
      SQLQuery.Params.ParamByName('LOGGED_IN_USER').AsString := SysUtils.GetEnvironmentVariable('USERNAME');
      SQLQuery.Params.ParamByName('ITEM_DATA').AsString :=  NodeState;
      SQLQuery.Params.ParamByName('ITEM_INFO').AsString := TrvName;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het invoeren van een Node State in de tabel ' + SETTINGS_APP + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het opslaan van de TreeView staat is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TAppDbMaintain.SaveTrvStateUpdate(TrvName, NodeState: string; Node: TTreeNode);
var
  SqlText : String;
begin
  SqlText := 'update ' + SETTINGS_APP +  ' ' +
             'set ITEM_DATA = :ITEM_DATA, ' +
             'ITEM_INFO = :ITEM_INFO, ' +
             'LOGGED_IN_USER = :LOGGED_IN_USER ' +
             'where GUID_NODE = :GUID_NODE and ITEM_INFO = :ITEM_INFO;';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      SQLQuery.Params.ParamByName('GUID_NODE').AsString := PtrApiObject(Node.Data)^.Guid;
      SQLQuery.Params.ParamByName('LOGGED_IN_USER').AsString := SysUtils.GetEnvironmentVariable('USERNAME');
      SQLQuery.Params.ParamByName('ITEM_DATA').AsString :=  NodeState;
      SQLQuery.Params.ParamByName('ITEM_INFO').AsString :=  TrvName;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het invoeren van een Node State in de tabel ' + SETTINGS_APP + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het opslaan van de TreeView staat is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

end.

