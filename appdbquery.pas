unit AppDbQuery;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, AppDb, appdbFQ;

type

  { TQuery }

  TQuery = class(TAppDatabase)
    private
      FFPguid : String;
      FUnsavedQuery : Boolean;

      procedure SetQueryStatusInArray;
      procedure InsertQuery(ObjectGuid : String);
      procedure UpdateQuery(ObjectGuid : String);
      procedure DeleteQuery(ObjectGuid : String);

    protected
    public
      constructor Create; overload;
      destructor  Destroy; override;

      function PrepareNewQuery(QueryName : String): PtrApiObject;
      procedure MarkQueryForDeletion;
      procedure SaveQueries;

      property QueryParentGuid : string Read FFPguid Write FFPguid;
      property UnsavedQueries : Boolean read FUnsavedQuery Write FUnsavedQuery;
    published
  end;

var
  QueryList : array of ApiObjectData;
  QueriesToSearch : array of ApiObjectData;

implementation

uses Form_Main, DataModule, Dialogs, Db, Tablename;

{ TQuery }

procedure TQuery.SetQueryStatusInArray;
var
  i, j : Integer;
  Counter : Integer;
begin
  if Length(QueryList) > 0 then begin
    if Length(QueriesToSearch) > 0 then begin
      for i := 0 to length(QueriesToSearch) -1 do begin
        for j:= 0 to Length(QueryList) -1 do begin
          if QueriesToSearch[i].Guid = QueryList[j].Guid then begin
            QueryList[j].Name := QueryList[i].Name; // just for debugging
            QueryList[j].Action := 'Delete';
            UnsavedQueries := True;
            FrmMain.Logging.WriteToLogInfo('Set Query status (mark for deletion) : ' + QueryList[j].Guid + ' - '+ QueryList[j].Name);
          end;
        end;
      end;
    end;
  end;

  if Length(QueriesToSearch) > 0 then begin // QueryList is empty but  QueriesToSearch is not empty (Delete after saved)
    Counter := Length(QueryList)+1;
    for i := 0 to length(QueriesToSearch) -1 do begin
      SetLength(QueryList, Counter);
      QueryList[Counter-1].Guid := QueriesToSearch[i].Guid;
      QueryList[Counter-1].Name := QueriesToSearch[i].Name;   // just for debugging
      QueryList[Counter-1].Action := 'Delete';
      UnsavedQueries := True;
      FrmMain.Logging.WriteToLogInfo('Set Query status (mark for deletion) : ' + QueryList[Counter-1].Guid + ' - '+ QueryList[Counter-1].Name);
      Counter += 1;
    end;
  end;
end;

procedure TQuery.InsertQuery(ObjectGuid: String);
var
  SqlText : String;
  i : Integer;
  QName : String;
begin
  SqlText := 'insert into ' + Tablename.QUERY_LIST + ' (GUID, NAME, OBJECTTYPE, PARENT_FOLDER, ' +
             'URL, DESCRIPTION_SHORT, DESCRIPTION_LONG, AUTHENTICATION, TOKEN, ' +
             'AUTHENTICATION_USER, AUTHENTICATION_PWD, DATE_CREATED, CREATED_BY) ' +
             'select :GUID, :NAME, :OBJECTTYPE, :PARENT_FOLDER, ' +
             ':URL, :DESCRIPTION_SHORT, :DESCRIPTION_LONG, :AUTHENTICATION, :TOKEN, ' +
             ':AUTHENTICATION_USER, :AUTHENTICATION_PWD, :DATE_CREATED, :CREATED_BY ' +
             'where not exists (select GUID from ' + Tablename.FOLDER_LIST + ' where GUID = :GUID);';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(QueryList)-1 do begin
        if ObjectGuid = QueryList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := ObjectGuid;
          SQLQuery.Params.ParamByName('NAME').AsString := QueryList[i].Name;
          SQLQuery.Params.ParamByName('OBJECTTYPE').AsString := QueryList[i].ObjectType;
          SQLQuery.Params.ParamByName('PARENT_FOLDER').AsString := QueryList[i].ParentFolder;
          SQLQuery.Params.ParamByName('URL').AsString := QueryList[i].Url;
          SQLQuery.Params.ParamByName('DESCRIPTION_SHORT').AsString := QueryList[i].Description_short;
          SQLQuery.Params.ParamByName('DESCRIPTION_LONG').AsString := QueryList[i].Description_long;
          SQLQuery.Params.ParamByName('AUTHENTICATION').AsBoolean := QueryList[i].Authentication;
          SQLQuery.Params.ParamByName('TOKEN').AsString := QueryList[i].Token;
          SQLQuery.Params.ParamByName('AUTHENTICATION_USER').AsString := QueryList[i].AuthenticationUserName;
          SQLQuery.Params.ParamByName('AUTHENTICATION_PWD').AsString := QueryList[i].AuthenticationPassword;
          SQLQuery.Params.ParamByName('DATE_CREATED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', QueryList[i].Date_Created);
          SQLQuery.Params.ParamByName('CREATED_BY').AsString := QueryList[i].CreatedBy;
          QName := QueryList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Query ' + QName + ' is toegevoegd aan tabel ' + Tablename.QUERY_LIST + '.');
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het invoeren van een nieuwe query in de tabel ' + TableName.QUERY_LIST + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het opslaan van de ' + QName + ' is mislukt.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TQuery.UpdateQuery(ObjectGuid: String);
var
  SqlText : String;
  i : Integer;
  QName : String;
begin
  SqlText := 'update ' + Tablename.QUERY_LIST +  ' ' +
             'set NAME = :NAME, ' +
             'PARENT_FOLDER = :PARENT_FOLDER, ' +
             'URL = :URL, ' +
             'DESCRIPTION_SHORT = :DESCRIPTION_SHORT, ' +
             'DESCRIPTION_LONG = :DESCRIPTION_LONG, ' +
             'AUTHENTICATION = :AUTHENTICATION, ' +
             'AUTHENTICATION_USER = :AUTHENTICATION_USER, ' +
             'AUTHENTICATION_PWD = :AUTHENTICATION_PWD, ' +
             'TOKEN = :TOKEN, '+
             'ALTERED_BY = :ALTERED_BY, ' +
             'DATE_ALTERED = :DATE_ALTERED ' +
             'where GUID = :GUID;';
  try
    With DataModule1 do begin
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(QueryList)-1 do begin
        if ObjectGuid = QueryList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := ObjectGuid;
          SQLQuery.Params.ParamByName('NAME').AsString := QueryList[i].Name;
          SQLQuery.Params.ParamByName('PARENT_FOLDER').AsString := QueryList[i].ParentFolder;
          SQLQuery.Params.ParamByName('URL').AsString := QueryList[i].Url;
          SQLQuery.Params.ParamByName('DESCRIPTION_SHORT').AsString := QueryList[i].Description_short;
          SQLQuery.Params.ParamByName('DESCRIPTION_LONG').AsString := QueryList[i].Description_long;
          SQLQuery.Params.ParamByName('AUTHENTICATION').AsBoolean := QueryList[i].Authentication;
          SQLQuery.Params.ParamByName('AUTHENTICATION_USER').AsString := QueryList[i].AuthenticationUserName;
          SQLQuery.Params.ParamByName('AUTHENTICATION_PWD').AsString := QueryList[i].AuthenticationPassword;
          SQLQuery.Params.ParamByName('TOKEN').AsString := QueryList[i].Token;
          SQLQuery.Params.ParamByName('ALTERED_BY').AsString := QueryList[i].ModifiedBy;
          SQLQuery.Params.ParamByName('DATE_ALTERED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', QueryList[i].Date_Modified);
          QName := QueryList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('De query ' +  QName + ' is bijgewerkt (Tabel ' + TableName.QUERY_LIST + '.');
    end;
  except
    on E: EDatabaseError do
      begin
        FrmMain.Logging.WriteToLogInfo('Het bijwerken van de tabel ' + TableName.QUERY_LIST + ' is mislukt.');
        FrmMain.Logging.WriteToLogError('Melding:');
        FrmMain.Logging.WriteToLogError(E.Message);
        messageDlg('Fout.', 'Het bijwerken van de tabel ' + TableName.QUERY_LIST + ' is mislukt. Betreft Query ' +QName+ '.', mtError, [mbOK],0);
      end;
  end;
end;

procedure TQuery.DeleteQuery(ObjectGuid: String);
var
  SqlText : String;
  i : Integer;
  QName : String;
begin
  SqlText := 'delete from ' + TableName.QUERY_LIST +
             ' where GUID = :GUID;';

  With DataModule1 do begin
    try
      SQLQuery.Close;
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;

      SQLQuery.SQL.Text := SqlText;

      for i := 0 to Length(QueryList)-1 do begin
        if ObjectGuid = QueryList[i].Guid then begin
          SQLQuery.Params.ParamByName('GUID').AsString := QueryList[i].Guid;
          QName := QueryList[i].Name;
          Break;
        end;
      end;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();

      FrmMain.Logging.WriteToLogInfo('Query ' + QName + ' is verwijderd uit de tabel ' + TableName.QUERY_LIST + '.');
      except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogError('Fout bij het verwijderen van een Query.');
          FrmMain.Logging.WriteToLogError('Melding:');
          FrmMain.Logging.WriteToLogError(E.Message);

          messageDlg('Fout.', 'Fout bij het verwijderen van een Query.', mtError, [mbOK],0);
        end;
      end;
  end;
end;

{%region constructor - destructor}
constructor TQuery.Create;
begin
  inherited;
  //..
end;

destructor TQuery.Destroy;
begin
  //..
  inherited Destroy;
end;
{%endregion constructor - destructor}

function TQuery.PrepareNewQuery(QueryName: String): PtrApiObject;
var
  NewQuery : PtrApiObject;
  Counter : Integer;
begin
  Counter := Length(QueryList)+1;
  SetLength(QueryList, Counter);  // Create or expand the QueryList (array).

  new(NewQuery);
  NewQuery^.Name := QueryName;
  NewQuery^.Guid := TGUID.NewGuid.ToString();
  NewQuery^.ObjectType := appdbFQ.Query;
  NewQuery^.ParentFolder := QueryParentGuid;
  NewQuery^.Action := 'Insert';  // overbodig
  UnsavedQueries := true;

  // Add the new Query tot the QueryList
  QueryList[Counter-1].Name := NewQuery^.Name;
  QueryList[Counter-1].Guid := NewQuery^.Guid;
  QueryList[Counter-1].ParentFolder := QueryParentGuid;
  QueryList[Counter-1].ObjectType := appdbFQ.Query;
  QueryList[Counter-1].Action := 'Insert';
  QueryList[Counter-1].Url := NewQuery^.Url;
  QueryList[Counter-1].Authentication := NewQuery^.Authentication;
  QueryList[Counter-1].AuthenticationUserName := NewQuery^.AuthenticationUserName;
  QueryList[Counter-1].AuthenticationPassword := NewQuery^.AuthenticationPassword;
  QueryList[Counter-1].Token := NewQuery^.Token;
  QueryList[Counter-1].CreatedBy := SysUtils.GetEnvironmentVariable('USERNAME');
  QueryList[Counter-1].Date_Created := Now;

  result := NewQuery;
end;

procedure TQuery.MarkQueryForDeletion;
begin
  SetQueryStatusInArray;
end;

procedure TQuery.SaveQueries;
var
  i : integer;
begin
  if Length(QueryList) > 0 then begin
    for i := 0 to Length(QueryList) -1 do begin
      if QueryList[i].Action = 'Insert' then begin
        FrmMain.Logging.WriteToLogInfo('Insert nieuwe Query.');
        InsertQuery(QueryList[i].Guid);
      end
      else if QueryList[i].Action = 'Update' then begin
        FrmMain.Logging.WriteToLogInfo('Update Query.');
        UpdateQuery(QueryList[i].Guid);
      end
      else if QueryList[i].Action = 'Delete' then begin
        FrmMain.Logging.WriteToLogInfo('Delete Query.');
        DeleteQuery(QueryList[i].Guid);
      end;
    end;
  end;
end;

end.

