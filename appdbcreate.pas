unit AppDbCreate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  AppDb;

type

  { TCreateAppdatabase }

  TCreateAppdatabase = class(TAppDatabase)
  private
    function GetError: Boolean;
    procedure SetError(AValue: Boolean);
  private
    FError : Boolean;
    function CheckDatabaseFile : boolean;
    procedure SqliteAutoVacuum;
    procedure SqliteJournalMode;
    procedure SqliteSynchronous;
    procedure SqliteTemStore;
    procedure SqliteUserVersion;

    procedure CreTable(TableName, SqlText, Version : String);
    procedure InsertMeta(Version : String);
  protected
  public
    constructor Create; overload;
    destructor  Destroy; override;
    function CreateDatabase : boolean;
    procedure CreateAllTables;
  published
  end;

implementation

uses Form_Main, DataModule, Dialogs, Db, TableName, Settings;
{ TCreateAppdatabase }

const
  creTblSetmeta =     'CREATE TABLE IF NOT EXISTS ' + TableName.SETTINGS_META + ' (' +
                      'KEY      VARCHAR(50), ' +
                      'VALUE    VARCHAR(255));';

  creTblFolderList =  'create table if not exists ' + TableName.FOLDER_LIST + ' (' +
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'OBJECTTYPE      INTEGER                                               , ' +
                      'NAME            VARCHAR(50)                                           , ' +
                      'PARENT_FOLDER   VARCHAR(50)                                           , ' +
                      'DATE_CREATED    DATE                                                  , ' +
                      'DATE_ALTERED    DATE                                                  , ' +
                      'CREATED_BY      VARCHAR(100)                                          , ' +
                      'ALTERED_BY      VARCHAR(100));';

    creTblQueryList = 'create table if not exists ' + TableName.QUERY_LIST + ' (' +
                      'ID                   INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID                 VARCHAR(50)  UNIQUE                                   , ' +
                      'OBJECTTYPE           VARCHAR(10)                                           , ' +
                      'NAME                 VARCHAR(100)                                          , ' +
                      'PARENT_FOLDER        VARCHAR(50)                                           , ' +
                      'URL                  VARCHAR(255)                                          , ' +
                      'DESCRIPTION_SHORT    VARCHAR(255)                                          , ' +
                      'DESCRIPTION_LONG     VARCHAR(10000)                                        , ' +
                      'AUTHENTICATION       BOOL                                                  , ' +
                      'AUTHENTICATION_USER  VARCHAR(255)                                          , ' +  // 100 + encrytion = 200
                      'AUTHENTICATION_PWD   VARCHAR(255)                                          , ' +  // 100 + encrytion = 200
                      'TOKEN                VARCHAR(255)                                          , ' +  // 100 + encrytion = 200
                      'AUTHENTICATION_CHECK VARCHAR(255)                                          , ' +  // 100 + encrytion = 200
                      'PAGING_SEARCHTEXT    VARCHAR(100)                                          , ' +
                      'SALT                 VARCHAR(100)                                          , ' +
                      'DATE_CREATED         DATE                                                  , ' +
                      'DATE_ALTERED         DATE                                                  , ' +
                      'CREATED_BY           VARCHAR(100)                                          , ' +
                      'ALTERED_BY           VARCHAR(100));';

    CreTblAppSetApp = 'create table if not exists ' + TableName.SETTINGS_APP + ' (' +
                      'ID                  INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID                VARCHAR(50)  UNIQUE                                   , ' +
                      'GUID_NODE           VARCHAR2(50)                                          , ' +
                      'LOGGED_IN_USER      VARCHAR2(50)                                          , ' +
                      'ITEM_DATA           VARCHAR2(100)                                         , ' +
                      'ITEM_INFO           VARCHAR2(50));';


{%region properties}
function TCreateAppdatabase.GetError: Boolean;
begin
  Result := FError;
end;

procedure TCreateAppdatabase.SetError(AValue: Boolean);
begin
  FError := AValue;
end;
{%endregion properties}

{%region constructor - destructor}
constructor TCreateAppdatabase.Create;
begin
  inherited;
  //..
end;

destructor TCreateAppdatabase.Destroy;
begin
  //..
  inherited Destroy;
end;
{%endregion constructor - destructor}

function TCreateAppdatabase.CheckDatabaseFile: boolean;
begin
  if dbFile = '' then begin
    result := false;
  end
  else begin
    if not FileExists(dbFile) then begin
      FrmMain.Logging.WriteToLogInfo('Aanmaken nieuw leeg database bestand op de locatie: '+ dbFile );

      try
        DataModule1.SQLite3Connection.Close();
        DataModule1.SQLite3Connection.DatabaseName := dbFile;
        DataModule1.SQLite3Connection.Open; //creates the file
        DataModule1.SQLite3Connection.Close(True);
        FrmMain.Logging.WriteToLogInfo('Leeg database bestand is aangemaakt.');
        result := true;
      except
        on E : Exception do begin
          FrmMain.Logging.WriteToLogError('Fout bij het aanmaken van een leeg database bestand.');
          FrmMain.Logging.WriteToLogError('Melding:');
          FrmMain.Logging.WriteToLogError(E.Message);
          FError := true;
          result := false;
        end;
      end;
    end
    else begin
      frmMain.Logging.WriteToLogInfo('Het database bestand bestaat al. ('+ dbFile +').');
      FError := false;
      result := false;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteAutoVacuum;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('PRAGMA auto_vacuum = INCREMENTAL;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Database instelling: auto_vacuum = incremental.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteJournalMode;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma journal_mode = WAL;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Database instelling: journal_mode = WAL.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteSynchronous;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma synchronous = normal;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Database instelling: synchronous = normal.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteTemStore;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma temp_store = memory;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Database instelling: temp_store = memory.');
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteUserVersion;
begin
  try
    With DataModule1 do begin
      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName := dbFile;
      SQLite3Connection.Open;
      SQLTransaction.Active := False;

      SQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
      SQLite3Connection.ExecuteDirect('pragma USER_VERSION = 1;');
      SQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Database instelling: USER_VERSION = ' + Settings.DatabaseVersion);
    end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij maken van eenm database instelling.');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het maken van een database instelling.', mtError, [mbOK],0);
    end;
  end;
end;

function TCreateAppdatabase.CreateDatabase: boolean;
begin
  if CheckDatabaseFile then begin // check if database file exists
    //Set SQlite database settings
    SqliteAutoVacuum;
    SqliteJournalMode;
    SqliteSynchronous;
    SqliteTemStore;
    SqliteUserVersion;

    // Create the tables
    CreateAllTables;
    result := true;
  end
  else begin
    result := true;
  end;
end;

procedure TCreateAppdatabase.CreateAllTables;
begin
  if FileExists(dbFile) then begin
    if DatabaseVersion = '1' then begin
      if not FError then CreTable(Tablename.SETTINGS_META, creTblSetmeta, '1');
      if not FError then CreTable(Tablename.FOLDER_LIST, creTblFolderList, '1');
      if not FError then CreTable(Tablename.QUERY_LIST, creTblQueryList, '1');
      if not FError then CreTable(Tablename.SETTINGS_APP, CreTblAppSetApp, '1');
      if not FError then InsertMeta('1');

      if not FError then begin
        messageDlg('Gereed.', 'Het aanmaken van de database (tabellen) is gereed.', mtInformation, [mbOK],0);
        FrmMain.Logging.WriteToLogInfo('Het aanmaken van de database (tabellen) is gereed. (Versie: ' + DatabaseVersion + ').');
      end;
    end
    else begin
      // '2'
    end;
  end
  else begin  // database file does not exists
    FrmMain.Logging.WriteToLogError('De database is niet gevonden.');
    messageDlg('Let op', 'De database is niet gevonden.', mtError, [mbOK],0);
    FError := true;
  end;
end;

procedure TCreateAppdatabase.CreTable(TableName, SqlText, Version : String);
begin
  try
    FrmMain.Logging.WriteToLogInfo('Aanmaken tabel: ' + TableName + '. (Versie: ' + Version + ').');
      With DataModule1 do begin
        SQLite3Connection.Close();
        SQLite3Connection.DatabaseName:=dbFile;
        SQLite3Connection.Open;
        SQLTransaction.Active:=True;

        SQLite3Connection.ExecuteDirect(SqlText);

        SQLTransaction.Commit;
        SQLite3Connection.Close();
      end;
  except
    on E : Exception do begin
      FrmMain.Logging.WriteToLogError('Fout bij het aanmaken van de tabel: ' + TableName + '. (Versie: ' + Version + ').');
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);

      messageDlg('Let op', 'Het aanmaken van de tabel "' + TableName + '" is mislukt.', mtError, [mbOK],0);
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.InsertMeta(Version : String);
var
  SqlString : String;
begin
  SqlString := 'insert into ' + Tablename.SETTINGS_META + ' (KEY, VALUE) values (:KEY, :VERSION)';
  try
    With DataModule1 do begin
      SQLQuery.Close;

      SQLite3Connection.Close();
      SQLite3Connection.DatabaseName:=dbFile;

      SQLQuery.SQL.Text :=SqlString;
      SQLQuery.Params.ParamByName('KEY').AsString := 'Version';
      SQLQuery.Params.ParamByName('VERSION').AsString := Version;

      SQLite3Connection.Open;
      SQLTransaction.Active:=True;

      SQLQuery.ExecSQL;

      SQLTransaction.Commit;
      SQLite3Connection.Close();
      FrmMain.Logging.WriteToLogInfo('Versie is toegevoegd aan tabel '+ Tablename.SETTINGS_META + '.');
    end;
  except
    on E: EDatabaseError do begin
      FrmMain.Logging.WriteToLogError('Melding:');
      FrmMain.Logging.WriteToLogError(E.Message);
      messageDlg('Fout.', 'Het invoeren van "Versienummmer" is mislukt.', mtError, [mbOK],0);
      FError := true;
    end;
  end;
end;


end.

