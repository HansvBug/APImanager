unit ApplicationDatabase;

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

    published
  end;

implementation

uses Settings, lazfileutils;

{ TAppDatabase }

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

