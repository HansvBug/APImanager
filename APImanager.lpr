program APImanager;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, DataModule, Form_Main, ApplicationEnvironment, Settings, Logging,
  form_maintain_api_data, AppDbCreate, AppDb, 
  SettingsManager, Form_Configure, Tablename, 
appdbFQ, AppDbFolder, AppDbQuery, Visual, ApiRequest;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled :=True;
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

