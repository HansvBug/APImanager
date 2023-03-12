unit AppDb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms;

type

  { TAppDatabase }

  TAppDatabase = class(TObject)
    private
      FdbFile, FBaseFolder, FDatabaseVersion : String;

    protected
      property dbFile          : String Read FdbFile Write FdbFile;
      property BaseFolder   : String Read FBaseFolder Write FBaseFolder;
      property DatabaseVersion : String Read FDatabaseVersion write FDatabaseVersion;


    public
      constructor Create; overload;
      destructor  Destroy; override;

      function CheckEntrylength(aText : String; aLength : Integer) : Boolean;
    published
  end;

const
  SETTINGS_META = 'SETTINGS_META';
  FOLDER_LIST = 'FOLDER_LIST';
  QUERY_LIST = 'QUERY_LIST';
  SETTINGS_APP = 'SETTINGS_APP';

implementation

uses Settings, lazfileutils;

{ TAppDatabase }

function TAppDatabase.CheckEntrylength(aText: String; aLength: Integer
  ): Boolean;
begin
  if (aText = '') and (aLength <= 0) then exit;

  if (Length(aText) <= aLength) then begin
    Result := True;
  end
  else
    Result := False;
end;

constructor TAppDatabase.Create;
begin
  inherited;
  BaseFolder := ExtractFilePath(Application.ExeName);
  dbFile := BaseFolder + Settings.DatabaseFolder + PathDelim + Settings.DatabaseName;
  DatabaseVersion := Settings.DataBaseVersion;
end;

destructor TAppDatabase.Destroy;
begin
  //..
  inherited Destroy;
end;

end.

