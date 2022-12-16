unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    SQLite3Connection: TSQLite3Connection;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private

  public

  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  SQLite3Connection.Transaction := SQLTransaction;
  SQLQuery.DataBase := SQLite3Connection;
end;

end.

