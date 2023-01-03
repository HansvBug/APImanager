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
  LCLTranslator, Forms, Settings, DataModule, Form_SplashScreen, Form_Main,
  ApplicationEnvironment,
  Logging, form_maintain_api_data, AppDbCreate, AppDb, SettingsManager,
  Form_Configure, Tablename, appdbFQ, AppDbFolder, AppDbQuery, Visual,
  ApiRequest, Form_About, Encryption;

{$R *.res}
var
  SplashFrm : TFrm_SplashScreen;

begin
  RequireDerivedFormResource:=True;
  Application.Scaled := True;
  Application.Initialize;

  //Added
  SplashFrm := TFrm_SplashScreen.Create(nil);
  try
    SplashFrm.Show;

    Application.CreateForm(TDataModule1, DataModule1);
    Application.CreateForm(TFrmMain, FrmMain);

    while not SplashFrm.Completed do // show splash form at least 2 seconds
      Application.ProcessMessages;

    SplashFrm.Close;
  finally
    SplashFrm.Free;
  end;

  Application.Run;
end.

