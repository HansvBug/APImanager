unit ApplicationEnvironment;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, lazfileutils, Dialogs;

type
  { TApplicationEnvironment }
  TApplicationEnvironment = class

    private

    public
      procedure CreateFolder(const BaseFolderPath : string; const NewFolderName : string);
      procedure CreateSettingsFile(SettingsFileName : string);
      function CheckDllFiles : Boolean;
  end;

implementation

uses Settings;

{ TApplicationEnvironment }

procedure TApplicationEnvironment.CreateFolder(const BaseFolderPath: string;
  const NewFolderName: string);
begin
  if not DirectoryExists(BaseFolderPath + NewFolderName) then
  begin
    if DirectoryIsWritable(BaseFolderPath) then
    begin
      CreateDir(BaseFolderPath+NewFolderName);
    end
    else
    begin
      MessageDlg('Fout.', 'U heeft geen schrijfrechten in de map.' + '', mtWarning, [mbOk], 0);
    end;
  end;
end;

procedure TApplicationEnvironment.CreateSettingsFile(SettingsFileName: string);
var
  UserName : string;
  tfOut: TextFile;
begin
  UserName := StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  SettingsFileName := SettingsFileName +  UserName + Settings.ConfigurationFile;
  if not FileExists(SettingsFileName) then
  begin
    try
      AssignFile(tfOut, SettingsFileName);
      //FileCreate (SettingsFileName, fmShareDenyNone);
      rewrite(tfOut);   //create the file
      CloseFile(tfOut);
    except
      MessageDlg('Fout.', 'Het maken van het settings bestand is mislukt.' + '', mtWarning, [mbOk], 0);
    end;
  end;
end;

function TApplicationEnvironment.CheckDllFiles : Boolean;
var
  BaseFolder : string;
  s : String;
  Error : Boolean;
begin
  s := 'Een belangrijk dll bestand ontbreekt. Alle functionaliteit wordt uitgezet.' + sLineBreak + sLineBreak +
       'Deze 3 dll bestanden moeten in de programma map staan: ' + sLineBreak
        + sLineBreak +
        'libeay32.dll (Nodig voor https request).' + sLineBreak +
        'ssleay32.dll (Nodig voor https request).' +  sLineBreak +
        'sqlite3.dll  (Nodig voor de SQlite applicatie database).';
  Error := false;

  BaseFolder :=  ExtractFilePath(Application.ExeName);
  if not FileExists(BaseFolder +  'libeay32.dll') then
    begin
      Error := true;
    end;
  if not FileExists(BaseFolder + 'ssleay32.dll') then
    begin
      Error := true;
    end;
  if not FileExists(BaseFolder + 'sqlite3.dll') then
    begin
      begin
        Error := true;
      end;
    end;
  if Error then
    begin
      messageDlg('Fout.', s, mtInformation, [mbOK],0);
    end;
  Result := Error;
end;

end.

