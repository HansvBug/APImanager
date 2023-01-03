unit Logging;

{$mode objfpc}{$H+}

interface
{$M+}
{$MODESWITCH TYPEHELPERS}

uses Classes, Sysutils, FileUtil, Forms;

type

  { TLog_File }

  TLog_File = class(TObject)
  private
    strlist                : TStringList;
    FileStream1            : TFileStream;
    FLogFolder, FUserName  : String;
    FAppendCurrentLogfile, FActivateLogging  : Boolean;
    szCurrentTime          : String;

    function GetAppendCurrentLogfile: Boolean;
    function GetLogFolder: String;
    function GetCurUserName: String;
    procedure SetAppendCurrentLogfile(AValue: Boolean);
    procedure SetLogFolder(AValue: String);
    procedure SetCurUserName(AValue: String);

    function    CurrentDate: String;                      //Bepalen huidige datum
    procedure   Logging;                                  //De gegevens worden in het bestand gezet
    procedure   CurrentTime;

    procedure   WriteToLog(Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogAndFlush(Commentaar : String);  //Tekst direct naar logbestand schrijven

    property LogFolder        : String  Read GetLogFolder            Write SetLogFolder;
    property Username         : String  Read GetCurUserName          Write SetCurUserName;

  public
    constructor Create();
    destructor  Destroy; override;
    procedure   StartLogging;                             //Aanmaken/openen log bestand
    procedure   StopLogging;                              //Bestand opslaan en sluiten
    procedure   WriteToLogInfo(Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogWarning(Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogError(Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogDebug(Commentaar : String);          //Tekst naar logbestand schrijven

    procedure   WriteToLogAndFlushInfo(Commentaar : String);  //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushWarning(Commentaar : String);  //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushError(Commentaar : String);  //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushDebug(Commentaar : String);  //Tekst direct naar logbestand schrijven

    property AppendLogFile    : Boolean Read GetAppendCurrentLogfile Write SetAppendCurrentLogfile;
    property ActivateLogging  : Boolean Read FActivateLogging        Write FActivateLogging;


end;

implementation

uses lazfileutils,
     Settings;

{ TLog_File.TLogTypeHelper }



{ TLog_File }

//Public

{%region% properties}
function TLog_File.GetLogFolder: String;
begin
  Result := FLogFolder;
end;

procedure TLog_File.SetLogFolder(AValue: String);
begin
  FLogFolder := AValue;
end;

function TLog_File.GetCurUserName: String;
begin
  Result := FUserName;
end;
procedure TLog_File.SetCurUserName(AValue: String);
begin
  FUserName := AValue;
end;

function TLog_File.GetAppendCurrentLogfile: Boolean;
begin
  Result := FAppendCurrentLogfile;
end;

procedure TLog_File.SetAppendCurrentLogfile(AValue: Boolean);
begin
  FAppendCurrentLogfile := AValue;
end;

{%endregion% properties}



constructor TLog_File.Create();
begin
  LogFolder := AppendPathDelim(ExtractFilePath(Application.ExeName) + Settings.LoggingFolder);
  strlist := TStringList.Create;
  UserName := StringReplace(GetEnvironmentVariable('USERNAME'), ' ', '_', [rfIgnoreCase, rfReplaceAll]);

{  if LogFolder = '' then
    begin
      ActivateLogging := False;
      AppendLogFile := False;
    end;}
end;

destructor TLog_File.Destroy;
begin
  FileStream1.Free;
  strlist.Free;
  inherited;
end;

procedure TLog_File.CurrentTime;  //Bepaal het huidige tijdstip
begin
  szCurrentTime := FormatDateTime('hh:mm:ss', Now) + ' --> | ';
end;

function TLog_File.CurrentDate: String;
var
  Present           : TDateTime;
  Year, Month, Day  : Word;
begin
  Present := Now;                         //de huidige datum en tijd opvragen
  DecodeDate(Present, Year, Month, Day);  //de datum bepalen die met present is opgehaald
  Result :=  IntToStr(Day) + '-' + IntToStr(Month) + '-' + IntToStr(Year);
end;

procedure TLog_File.Logging;
var
  retry      : Boolean;
  retries, i : Integer;
  MyString   : String;
const
  MAXRETRIES = 10;
  RETRYBACKOFFDELAYMS = 50;
begin
  if ActivateLogging then begin
    try
      // Retry mechanisme voor een SaveToFile()
      retry := True;
      retries := 0;
      while retry do
      try
        //wegschrijven
        for I := 0 to strlist.Count-1 do
          begin
            try
              FileStream1.seek(0,soFromEnd);  ////cursor aan het eind van het bestand zetten
              MyString := strlist[i] + sLineBreak;
              FileStream1.WriteBuffer(MyString[1], Length(MyString) * SizeOf(Char));
            finally
              //
            end;
          end;
        strlist.Clear;  //Stringlist leegmaken
        retry := False;
      except
        on EInOutError do
        begin
          Inc(retries);
          Sleep(RETRYBACKOFFDELAYMS * retries);
          if retries > MAXRETRIES then
          begin
            WriteToLog('INFORMATIE | Na 10 pogingen is het opslaan in het logbestand afgebroken.');
            Exit;
          end;
        end;
      end;
    finally
      //
    end;
  end;
end;

procedure TLog_File.StartLogging;

begin
  if ActivateLogging then begin
    if AppendLogFile = True then
      begin
        if FileExists(LogFolder
                       + Username
                       + '_'
                       + Settings.LogFileName) then
          begin
            FileStream1 := TFileStream.Create(LogFolder
                                                 + Username
                                                 + '_'
                                                 + Settings.LogFileName,
                           fmOpenReadWrite or fmShareDenyNone);  //fmShareDenyNone : Do not lock file
          end
        else  //wel append maar het bestand bestaat nog niet dan aanmaken
          begin
            FileStream1 := TFileStream.Create(LogFolder
                                                 + Username
                                                 + '_'
                                                 + Settings.LogFileName,
                           fmCreate or fmShareDenyNone);
          end;
      end
    else  //nieuw bestand aanmaken
      begin
        FileStream1 := TFileStream.Create(LogFolder
                                                   + Username
                                                   + '_'
                                                   + Settings.LogFileName,
                             fmCreate or fmShareDenyNone);

      end;

    try
      strlist.Add('##################################################################################################');
      strlist.Add(' Programma: ' + Settings.ApplicationName);
      strlist.Add(' Versie   : ' + Settings.Version);
      strlist.Add(' Datum    : ' + CurrentDate);
      strlist.Add('##################################################################################################');
      Logging;  //Direct opslaan
      CurrentTime;
    except
      strlist.Add('FOUT      | Onverwachte fout opgetreden bij de opstart van de logging procedure.');
    end;
  end;
end;

procedure TLog_File.StopLogging;
begin
  strlist.Add('');
  strlist.Add('##################################################################################################');
  strlist.Add(' Programma ' + Settings.ApplicationName + ' is afgesloten');
  strlist.Add('##################################################################################################');
  strlist.Add('');
  strlist.Add('');
  strlist.Add('');
  Logging;  //Direct opslaan
end;

procedure TLog_File.WriteToLogInfo(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : INFORMATIE   | ' + Commentaar);
end;

procedure TLog_File.WriteToLogWarning(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : WAARSCHUWING | ' + Commentaar);
end;

procedure TLog_File.WriteToLogError(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : FOUT         | ' + Commentaar);
end;

procedure TLog_File.WriteToLogDebug(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : DEBUG        | ' + Commentaar);
end;


procedure TLog_File.WriteToLog(Commentaar : String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' :              | ' + Commentaar);  //In de stringgrid gereed zetten
end;


procedure TLog_File.WriteToLogAndFlushInfo(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : INFORMATIE   | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushWarning(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : WAARSCHWING  | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushError(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : ERROR        | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushDebug(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : DEBUG        | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlush(Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' :              | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;  // Direct opslaan
end;

end.

