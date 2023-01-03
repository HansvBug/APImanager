unit AppDbFolder;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Windows, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, typinfo,
  AppDb, appdbFQ, Visual;

type

  { TFolder }

  TFolder = class(TAppDatabase)
    private
      FFPguid : String;
      FUnsavedFolder : Boolean;

      procedure SetFolderStatusInArray;
      procedure InsertFolder(ObjectGuid : String);
      procedure UpdateFolder(ObjectGuid : String);
      procedure DeleteFolder(ObjectGuid : String);
      procedure DeleteFolderFromSettingsTbl;

      // Read data into Treeview
      procedure ReadFolderList(var fd : AllApiObjectData);
      procedure ReadQueryList(var fd : AllApiObjectData);  // !!!
      procedure PopulateTreeView();

    protected
    public
      constructor Create; overload;
      destructor  Destroy; override;

      function PrepareNewFolder(FolderName : String): PtrApiObject;
      procedure MarkFolderForDeletion;
      procedure SaveFolders;

      property FolderParentGuid : string Read FFPguid Write FFPguid;
      property UnsavedFolders : Boolean read FUnsavedFolder Write FUnsavedFolder;

      // Read data into Treeview
      procedure GetFoldersAndQueries(aTrv : TTreeView);

    published
  end;

var
  FolderList : array of ApiObjectData;
  FoldersToSearch : array of ApiObjectData;
  ParentNodes : Array of TTreeNode;
  ChildNodes : Array of ApiObjectData;
  fd: AllApiObjectData;
  Trv : TTreeView;
  TrvVisual : TVisual;

implementation

uses Form_Main, DataModule, Db, Tablename, Encryption;

{ TFolder }


{%region constructor - destructor}
constructor TFolder.Create;
begin
  inherited;
  TrvVisual := TVisual.Create;
end;

destructor TFolder.Destroy;
begin
  if assigned(TrvVisual) then TrvVisual.Free;
  inherited Destroy;
end;
{%endregion constructor - destructor}


function TFolder.PrepareNewFolder(FolderName: String): PtrApiObject;
var
  NewFolder : PtrApiObject;
  Counter : Integer;
begin
  new(NewFolder);
  NewFolder^.Name := FolderName;
  NewFolder^.Guid := TGUID.NewGuid.ToString();
  NewFolder^.ObjectType := appdbFQ.Folder;
  NewFolder^.ParentFolder := FolderParentGuid;
  NewFolder^.Action := 'Insert';  // overbodig
  UnsavedFolders := true;

  // Add the new folder tot the FolderList
  Counter := Length(FolderList)+1;
  SetLength(FolderList, Counter);  // Create or expand the Folderlist (array).

  FolderList[Counter-1].Name := NewFolder^.Name;
  FolderList[Counter-1].Guid := NewFolder^.Guid;
  FolderList[Counter-1].ParentFolder := FolderParentGuid;
  FolderList[Counter-1].ObjectType := appdbFQ.Folder;
  FolderList[Counter-1].Action := 'Insert';
  FolderList[Counter-1].CreatedBy := SysUtils.GetEnvironmentVariable('USERNAME');
  FolderList[Counter-1].Date_Created := Now; //FormatDateTime('DD MM YYYY hh:mm:ss', Now); ;

  result := NewFolder;
end;

procedure TFolder.MarkFolderForDeletion;
begin
  SetFolderStatusInArray;
end;

procedure TFolder.SetFolderStatusInArray;
var
  i, j : Integer;
  Counter : Integer;
begin
  if Length(FolderList) > 0 then begin
    if Length(FoldersToSearch) > 0 then begin
      for i := 0 to length(FoldersToSearch) -1 do begin
        for j:= 0 to Length(FolderList) -1 do begin
          if (FoldersToSearch[i].Guid = FolderList[j].Guid) and (FolderList[j].Guid <> '') then begin
            FolderList[j].Name := FoldersToSearch[i].Name;  // Just for debugging
            FolderList[j].Action := 'Delete';
            UnsavedFolders := True;
            FrmMain.Logging.WriteToLogInfo('Set Folder status (mark for deletion) : ' + FolderList[j].Guid + ' - '+ FolderList[j].Name);
            { #todo : Test of Break; uit de eerste for loop springt }
          end;
        end;
      end;
    end;
  end;

  if Length(FoldersToSearch) > 0 then begin // Folderlist is empty but  FoldersToSearch is not empty (Delete after saved)

    Counter := Length(FolderList)+1;
    for i := 0 to length(FoldersToSearch) -1 do begin
      if FoldersToSearch[i].Guid <> '' then begin
        SetLength(FolderList, Counter);
        FolderList[Counter-1].Guid := FoldersToSearch[i].Guid;
        FolderList[Counter-1].Name := FoldersToSearch[i].Name; // just for debugging
        FolderList[Counter-1].Action := 'Delete';
        UnsavedFolders := True;
        FrmMain.Logging.WriteToLogInfo('Set Folder status (mark for deletion) : ' + FolderList[Counter-1].Guid + ' - '+ FolderList[Counter-1].Name);
        Counter += 1;
      end;
    end;

  end;
end;

procedure TFolder.SaveFolders;
var
  i : integer;
begin
  if Length(FolderList) > 0 then begin
    for i := 0 to Length(FolderList) -1 do begin
      if FolderList[i].Action = 'Insert' then begin
        FrmMain.Logging.WriteToLogInfo('Insert nieuwe Folder.');
        InsertFolder(FolderList[i].Guid);
      end
      else if FolderList[i].Action = 'Update' then begin
        FrmMain.Logging.WriteToLogInfo('Update folder.');
        UpdateFolder(FolderList[i].Guid);
      end
      else if FolderList[i].Action = 'Delete' then begin
        FrmMain.Logging.WriteToLogInfo('Delete Folder.');
        DeleteFolder(FolderList[i].Guid);
      end;
    end;
  end;
  DeleteFolderFromSettingsTbl;  // Delete folder from the SETTINGS_APP table.
end;

procedure TFolder.InsertFolder(ObjectGuid : String);
var
  SqlText : String;
  i : Integer;
  FName : String;
begin
  SqlText := 'insert into ' + Tablename.FOLDER_LIST + ' (GUID, NAME, OBJECTTYPE, PARENT_FOLDER, DATE_CREATED, CREATED_BY) ' +
             'select :GUID, :NAME, :OBJECTTYPE, :PARENT_FOLDER, :DATE_CREATED, :CREATED_BY ' +
             'where not exists (select GUID from ' + Tablename.FOLDER_LIST + ' where GUID = :GUID);';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(FolderList)-1 do begin
        if ObjectGuid = FolderList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := ObjectGuid;
          SQLQuery.Params.ParamByName('NAME').AsString := FolderList[i].Name;
          SQLQuery.Params.ParamByName('OBJECTTYPE').AsString := FolderList[i].ObjectType;
          SQLQuery.Params.ParamByName('PARENT_FOLDER').AsString := FolderList[i].ParentFolder;
          SQLQuery.Params.ParamByName('DATE_CREATED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', FolderList[i].Date_Created);
          SQLQuery.Params.ParamByName('CREATED_BY').AsString := FolderList[i].CreatedBy;
          FName := FolderList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Folder ' + FName + ' is toegevoegd aan tabel '+ Tablename.FOLDER_LIST + '.');
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het invoeren van een nieuwe folder in de tabel ' + TableName.FOLDER_LIST + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het opslaan van de ' + FName + ' is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TFolder.UpdateFolder(ObjectGuid : String);
var
  SqlText : String;
  i : Integer;
  FName : String;
begin
  SqlText := 'update ' + Tablename.FOLDER_LIST +  ' ' +
             'set NAME = :NAME, '+
             'PARENT_FOLDER = :PARENT_FOLDER, ' +
             'ALTERED_BY = :ALTERED_BY, ' +
             'DATE_ALTERED = :DATE_ALTERED ' +
             'where GUID = :GUID;';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(FolderList)-1 do begin
        if ObjectGuid = FolderList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := ObjectGuid;
          SQLQuery.Params.ParamByName('NAME').AsString := FolderList[i].Name;
          SQLQuery.Params.ParamByName('PARENT_FOLDER').AsString := FolderList[i].ParentFolder;
          SQLQuery.Params.ParamByName('ALTERED_BY').AsString := FolderList[i].ModifiedBy;
          SQLQuery.Params.ParamByName('DATE_ALTERED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', FolderList[i].Date_Modified);
          FName := FolderList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('De folder ' +  FName + ' is bijgewerkt (Tabel ' + TableName.FOLDER_LIST + '.');
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het bijwerken van de tabel ' + TableName.FOLDER_LIST + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het bijwerken van de tabel ' + TableName.FOLDER_LIST + ' is mislukt. Betreft Folder ' +FName+ '.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TFolder.DeleteFolder(ObjectGuid : String);
var
  SqlText : String;
  i : Integer;
  FName : String;
begin
  SqlText := 'delete from ' + TableName.FOLDER_LIST +
             ' where PARENT_FOLDER = :PARENT_FOLDER;';

  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(FolderList)-1 do begin
        if ObjectGuid = FolderList[i].Guid then begin
          SQLQuery.Params.ParamByName('PARENT_FOLDER').AsString := FolderList[i].Guid;
          FName := FolderList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      SqlText := 'delete from ' + TableName.FOLDER_LIST +
                 ' where GUID = :GUID;';

      SQLQuery.Close;
      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(FolderList)-1 do begin
        if ObjectGuid = FolderList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := FolderList[i].Guid;
          FName := FolderList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      FrmMain.Logging.WriteToLogInfo('Folder ' + FName + ' is verwijderd uit de tabel ' + TableName.FOLDER_LIST + '.');
      except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogError('Fout bij het verwijderen van een Folder.');
          FrmMain.Logging.WriteToLogError('Melding:');
          FrmMain.Logging.WriteToLogError(E.Message);

          messageDlg('Fout.', 'Fout bij het verwijderen van een Folder.', mtError, [mbOK],0);
        end;
      end;
  end;
end;

procedure TFolder.DeleteFolderFromSettingsTbl;
var
  SqlText : String;
begin
  SqlText := 'delete from ' + TableName.SETTINGS_APP +
             ' where GUID_NODE not in (select guid from ' + tableName.FOLDER_LIST + ');';

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
    except
      on E : Exception do begin
        FrmMain.Logging.WriteToLogError('Fout bij het verwijderen van een Folder uit ' + TableName.SETTINGS_APP);
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het verwijderen van een Folder uit de tabel '  + TableName.SETTINGS_APP, mtError, [mbOK],0);
      end;
    end;
  end;
end;


{Read Data into Treeview-------------------------------------------------------}

procedure TFolder.GetFoldersAndQueries(aTrv: TTreeView);
begin
  Screen.Cursor := crHourGlass;
  aTrv.BeginUpdate;
  ReadFolderList(fd);  // add Folder data to array
  ReadQueryList(fd);   // add Query data to array

  Trv := aTrv;
  Trv.Items.Clear;
  PopulateTreeView();  // Read the folders and Queries from the arrays into the TreeView.
  aTrv.EndUpdate;
  Screen.Cursor := crDefault;
end;

procedure TFolder.PopulateTreeView();
var
  i, p, Counter : Integer;
  ParentTn : TTreeNode;
  aod : PtrApiObject;
begin
  if (ParentNodes <> nil) and ( ChildNodes <> nil) then begin   // search for  ChildNodes in fd[i].ParentFolder
    for p := 0 to Length(ParentNodes) do begin
      for i:= 0 to Length(fd)-1 do begin
        if ChildNodes[p].Guid = fd[i].ParentFolder then begin
          Counter := Length(ParentNodes);

          New(aod);
          aod^.Guid := fd[i].Guid;
          aod^.ParentFolder := fd[i].ParentFolder;
          aod^.ObjectType := fd[i].ObjectType;
          aod^.Name := fd[i].Name;

          if fd[i].ObjectType = appdbFQ.Query then begin
            aod^.Url := fd[i].Url;
            aod^.Token := fd[i].Token;
            aod^.Description_short := fd[i].Description_short;
            aod^.Description_long := fd[i].Description_long;
            aod^.Authentication := fd[i].Authentication;
            aod^.AuthenticationUserName := fd[i].AuthenticationUserName;
            aod^.AuthenticationPassword := fd[i].AuthenticationPassword;
            aod^.Salt := fd[i].Salt;
            aod^.Paging_searchtext := fd[i].Paging_searchtext;
          end;

          ParentTn := Trv.Items.AddChildObject(ParentNodes[p], fd[i].Name, aod);

          if fd[i].ObjectType = appdbFQ.Folder then
            ParentTn.ImageIndex := 1;

          //Add checkbox to child notes
          {if fd[i].ObjectType = appdbFQ.Query then begin
            TrvVisual.CheckNode(ParentTn, false);
          end;}

          SetLength(ParentNodes, Counter+1);
          ParentNodes[Counter] := ParentTn;

          SetLength(ChildNodes, Counter+1);
          ChildNodes[Counter].Guid := fd[i].Guid;
        end;
      end;

      delete(ChildNodes, p, 1);   //Syntax is Delete(fromArray, Index, NumberOfItems); Index is zero based.
      delete(ParentNodes, p, 1);

      if (ParentNodes <> nil) and (ChildNodes <> nil) then begin
        PopulateTreeView();
      end;

      if (ParentNodes = nil) and (ChildNodes = nil) then begin
        Exit;
      end;
    end;
  end
  else begin
    Counter := Length(ParentNodes);
    for i:= 0 to Length(fd)-1 do begin
      if (fd[i].Guid <> '') and  (fd[i].ParentFolder = '') then begin  // rootnode

        New(aod);
        aod^.Guid := fd[i].Guid;
        aod^.ParentFolder := fd[i].ParentFolder;
        aod^.ObjectType := fd[i].ObjectType;
        aod^.Name := fd[i].Name;

        ParentTn := Trv.Items.AddObject(nil, fd[i].Name, aod);
        ParentTn.ImageIndex := 0; // Rootnode image

        SetLength(ParentNodes, Counter + 1);
        ParentNodes[Counter] := ParentTn;

        SetLength(ChildNodes, Counter + 1);
        ChildNodes[Counter].Guid := fd[Counter].Guid;
        break;
      end;
    end;
    if (ParentTn <> nil)  then begin
      PopulateTreeView();
    end;
  end;
end;

procedure TFolder.ReadFolderList(var fd: AllApiObjectData);
var
  SqlText : String;
  i : Integer;
begin
  SqlText := 'Select GUID, PARENT_FOLDER, OBJECTTYPE, NAME ' +
             'from ' + TableName.FOLDER_LIST;

  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.SQL.Text := SqlText;
      SQLQuery.Open;
      SQLQuery.First;

      i := 0;
      SetLength(fd, SQLQuery.RecordCount);
      SQLQuery.PacketRecords := -1;

      SQLQuery.First;
      while not SQLQuery.Eof do begin
        fd[i].Id :=  i;
        fd[i].Name := SQLQuery.FieldByName('NAME').AsString;
        fd[i].Guid := SQLQuery.FieldByName('GUID').AsString;
        fd[i].ParentFolder := SQLQuery.FieldByName('PARENT_FOLDER').AsString;
        fd[i].ObjectType := appdbFQ.Folder;
        SQLQuery.next;
        i +=1;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    except
      on E : Exception do begin
        FrmMain.Logging.WriteToLogError('Fout bij het lezen van de tabel ' + TableName.FOLDER_LIST + '.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de folders.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

procedure TFolder.ReadQueryList(var fd: AllApiObjectData);
var
  SqlText : String;
  i : Integer;
  Encrypt : TEncryptDecrypt;
  Salt : String;
begin
  SqlText := 'Select GUID, PARENT_FOLDER, OBJECTTYPE, NAME, URL, TOKEN, ' +
             'DESCRIPTION_SHORT, DESCRIPTION_LONG, AUTHENTICATION, ' +
             'AUTHENTICATION_USER, AUTHENTICATION_PWD, PAGING_SEARCHTEXT, '+
             'SALT '+
             'from ' + TableName.QUERY_LIST;

  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;

      SQLQuery.SQL.Text := SqlText;
      SQLQuery.Open;
      SQLQuery.First;

      i := Length(fd);

      if SQLQuery.RecordCount > 0 then begin
        SetLength(fd, SQLQuery.RecordCount+i);
        SQLQuery.PacketRecords := -1;

        SQLQuery.First;
        while not SQLQuery.Eof do begin
          fd[i].Id :=  i;
          fd[i].Name := SQLQuery.FieldByName('NAME').AsString;
          fd[i].Guid := SQLQuery.FieldByName('GUID').AsString;
          fd[i].ParentFolder := SQLQuery.FieldByName('PARENT_FOLDER').AsString;
          fd[i].ObjectType := appdbFQ.Query;
          fd[i].Url := SQLQuery.FieldByName('URL').AsString;
          fd[i].Description_short := SQLQuery.FieldByName('DESCRIPTION_SHORT').AsString;
          fd[i].Description_long := SQLQuery.FieldByName('DESCRIPTION_LONG').AsString;
          fd[i].Authentication := SQLQuery.FieldByName('AUTHENTICATION').AsBoolean;
          fd[i].Paging_searchtext := SQLQuery.FieldByName('PAGING_SEARCHTEXT').AsString;
          fd[i].Salt := SQLQuery.FieldByName('SALT').AsString;

          if fd[i].Salt <> '' then begin
            Salt := fd[i].Salt;
            Encrypt := TEncryptDecrypt.Create(USER_NAMETXT);

            if SQLQuery.FieldByName('TOKEN').AsString <> '' then begin
              fd[i].Token := Encrypt.Decrypt_String(SQLQuery.FieldByName('TOKEN').AsString, Salt);
            end
            else begin
              fd[i].Token := SQLQuery.FieldByName('TOKEN').AsString;
            end;

            if SQLQuery.FieldByName('AUTHENTICATION_USER').AsString <> '' then begin
              fd[i].AuthenticationUserName := Encrypt.Decrypt_String(SQLQuery.FieldByName('AUTHENTICATION_USER').AsString, Salt);
            end
            else begin
              fd[i].AuthenticationUserName := SQLQuery.FieldByName('AUTHENTICATION_USER').AsString;
            end;

            if SQLQuery.FieldByName('AUTHENTICATION_PWD').AsString <> '' then begin
              fd[i].AuthenticationPassword := Encrypt.Decrypt_String(SQLQuery.FieldByName('AUTHENTICATION_PWD').AsString, Salt);
            end
            else begin
              fd[i].AuthenticationPassword := SQLQuery.FieldByName('AUTHENTICATION_PWD').AsString;
            end;

            Encrypt.Free;
          end
          else begin
            fd[i].Token := SQLQuery.FieldByName('TOKEN').AsString;
            fd[i].AuthenticationUserName := SQLQuery.FieldByName('AUTHENTICATION_USER').AsString;
            fd[i].AuthenticationPassword := SQLQuery.FieldByName('AUTHENTICATION_PWD').AsString;
          end;

          SQLQuery.next;
          i += 1;
        end;
      end;

      SQLQuery.Close;
      SQLite3Connection.Close();
    except
      on E : Exception do begin
        FrmMain.Logging.WriteToLogError('Fout bij het lezen van de tabel ' + TableName.FOLDER_LIST + '.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);

        messageDlg('Fout.', 'Fout bij het lezen van de folders.', mtError, [mbOK],0);
      end;
    end;
  end;
end;

end.














