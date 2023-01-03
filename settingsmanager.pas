unit Settingsmanager;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, ExtCtrls;


type

  { TSettingsmanager }

  TSettingsmanager = class(TObject)
    private
      FConfigurationFile, FDefaultLanguage, FBaseFolder: String;
      FSslDllLocation_F1, FSslDllLocation_F2, FSQLiteDllLocation : String;

      FActivateLogging, FAppendLogFile, FDisplayHelpText : Boolean;
      FSetActiveBackGround, FTreeViewHotTrack : Boolean;
      FFileCopyCount, FFileCopyCurrent : Integer;

      procedure ReadSettings;
      procedure GetConfigurationFileLocation;

      property ConfigurationFile : String  Read FConfigurationFile Write FConfigurationFile;
      property BaseFolder : String Read FBaseFolder Write FBaseFolder;
    public
      constructor Create; overload;
      destructor  Destroy; override;
      procedure SaveSettings;
      procedure StoreFormState(aForm: TForm);
      procedure RestoreFormState(aForm: TForm);
      function CheckFormIsEntireVisible(Rect: TRect): TRect;
      procedure StoreSplitterPos(aSplitter: TSplitter);
      procedure RestoreSplitterPos(aSplitter: TSplitter);

      // Configure form
      property ActivateLogging       : Boolean Read FActivateLogging     Write FActivateLogging default True;
      property AppendLogFile         : Boolean Read FAppendLogFile       Write FAppendLogFile default True;
      property SslDllLocation_file1  : String  Read FSslDllLocation_F1   Write FSslDllLocation_F1;
      property SslDllLocation_file2  : String  Read FSslDllLocation_F2   Write FSslDllLocation_F2;
      property SQLiteDllLocation     : String  Read FSQLiteDllLocation   Write FSQLiteDllLocation;
      property DefaultLanguage       : String  Read FDefaultLanguage     Write FDefaultLanguage;
      property SetActiveBackGround   : Boolean Read FSetActiveBackGround Write FSetActiveBackGround;
      property FileCopyCount         : Integer Read FFileCopyCount       Write FFileCopyCount;
      property FileCopyCurrent       : Integer Read FFileCopyCurrent     Write FFileCopyCurrent;
      property SetTreeViewHotTrack   : Boolean Read FTreeViewHotTrack    Write FTreeViewHotTrack default False;
      property DisplayHelpText       : Boolean Read FDisplayHelpText     Write FDisplayHelpText default False;

  end;

implementation
uses Settings, IniFiles, Form_Main;

{ TSettingsmanager }

{%region constructor - destructor}
constructor TSettingsmanager.Create;
begin
  inherited;
  BaseFolder := ExtractFilePath(Application.ExeName);
  GetConfigurationFileLocation;
  ReadSettings;
end;

destructor TSettingsmanager.Destroy;
begin
  // ..
  inherited Destroy;
end;

{%endregion constructor - destructor}

procedure TSettingsmanager.GetConfigurationFileLocation;
var
  UserName : string;
begin
  UserName := StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  ConfigurationFile := BaseFolder + Settings.SettingsFolder + PathDelim + UserName + Settings.ConfigurationFile;
end;

procedure TSettingsmanager.ReadSettings;
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      // Form_Configure
      if ReadInteger('Configure', 'ActivateLogging', 1) = 1 then begin
        ActivateLogging := True;
      end
      else begin
        ActivateLogging := False;
      end;

      if ReadInteger('Configure', 'AppendLogFile', 1) = 1 then begin
        AppendLogFile := True;
      end
      else begin
        AppendLogFile := False;
      end;

      SslDllLocation_file1 := ReadString('Configure', 'SslDllLocation_1', BaseFolder + 'libeay32.dll');
      SslDllLocation_file2 := ReadString('Configure', 'SslDllLocation_2', BaseFolder + 'ssleay32.dll');
      SQLiteDllLocation := ReadString('Configure', 'SQLiteDllLocation', BaseFolder + 'sqlite3.dll');

      if ReadBool('Configure', 'SetActiveBackGround', True) then begin
        SetActiveBackGround := True;
      end
      else begin
        SetActiveBackGround := False;
      end;

      FileCopyCount := ReadInteger('Configure', 'FileCopyCount', 10);
      FileCopyCurrent := ReadInteger('Configure', 'FileCopyCurrent', 0);

      if ReadInteger('Configure', 'TreeViewHotTrack', 0) = 0 then begin
        SetTreeViewHotTrack := False;
      end
      else begin
        SetTreeViewHotTrack := True;
      end;

      if ReadInteger('Configure', 'DisplayHelpText', 0) = 0 then begin
        DisplayHelpText := False;
      end
      else begin
        DisplayHelpText := True;
      end;

      DefaultLanguage := ReadString('Configure', 'DefaultLanguage', 'en');

    finally
      Free;
    end;
end;

procedure TSettingsmanager.SaveSettings;
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      WriteString('Application', 'Name', Settings.ApplicationName);
      WriteString('Application', 'Version', Settings.Version);
      WriteString('Application', 'Database version', Settings.DataBaseVersion);
      WriteString('Application', 'Build Date' , Settings.BuildDate);

      WriteBool('Configure', 'ActivateLogging', ActivateLogging);
      WriteBool('Configure', 'AppendLogFile', AppendLogFile);
      WriteString('Configure', 'SslDllLocation_1', SslDllLocation_file1);
      WriteString('Configure', 'SslDllLocation_2', SslDllLocation_file2);
      WriteString( 'Configure', 'SQLiteDllLocation', SQLiteDllLocation);
      WriteBool('Configure', 'SetActiveBackGround', SetActiveBackGround);
      WriteInteger('Configure', 'FileCopyCount', FileCopyCount);
      WriteInteger('Configure', 'FileCopyCurrent', FileCopyCurrent);
      WriteBool('Configure', 'TreeViewHotTrack', SetTreeViewHotTrack);
      WriteBool('Configure', 'DisplayHelpText', DisplayHelpText);
      WriteString('Configure', 'DefaultLanguage', DefaultLanguage);
    finally
      Free;
    end;
end;

procedure TSettingsmanager.StoreFormState(aForm: TForm);
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      try
        writeinteger('Position', aForm.Name + '_Windowstate', integer(aForm.WindowState));
        WriteInteger('Position', aForm.Name + '_Left', aForm.Left);
        WriteInteger('Position', aForm.Name + '_Top', aForm.Top);
        WriteInteger('Position', aForm.Name + '_Width', aForm.Width);
        WriteInteger('Position', aForm.Name + '_Height', aForm.Height);

        WriteInteger('Position', aForm.Name + '_RestoredLeft', aForm.RestoredLeft);
        WriteInteger('Position', aForm.Name + '_RestoredTop', aForm.RestoredTop);
        WriteInteger('Position', aForm.Name + '_RestoredWidth', aForm.RestoredWidth);
        WriteInteger('Position', aForm.Name + '_RestoredHeight', aForm.RestoredHeight);

        FrmMain.Logging.WriteToLogInfo('Opslaan schermpositie van scherm: ' + ' (' + aForm.Name + ').' );
      finally
        Free;
      end;
    Except
      FrmMain.Logging.WriteToLogError('Opslaan schermpositie van scherm: ' + aForm.Name + ' is mislukt.' );
    end;
end;

procedure TSettingsmanager.RestoreFormState(aForm: TForm);
var
  LastWindowState: TWindowState;
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      try
        LastWindowState := TWindowState(ReadInteger('Position', aForm.Name + '_WindowState', Integer(aForm.WindowState)));

        if LastWindowState = wsMaximized then
          begin
            aForm.WindowState := wsNormal;
            aForm.BoundsRect := Bounds(
            ReadInteger('Position', aForm.Name + '_RestoredLeft', aForm.RestoredLeft),
            ReadInteger('Position', aForm.Name + '_RestoredTop', aForm.RestoredTop),
            ReadInteger('Position', aForm.Name + '_RestoredWidth', aForm.RestoredWidth),
            ReadInteger('Position', aForm.Name + '_RestoredHeight', aForm.RestoredHeight));

            aForm.WindowState := wsMaximized;
          end
        else
          begin
            aForm.WindowState := wsNormal;
            aForm.BoundsRect := Bounds(
            ReadInteger('Position', aForm.Name + '_Left', aForm.Left),
            ReadInteger('Position', aForm.Name + '_Top', aForm.Top),
            ReadInteger('Position', aForm.Name + '_Width', aForm.Width),
            ReadInteger('Position', aForm.Name + '_Height', aForm.Height));

            aForm.BoundsRect := CheckFormIsEntireVisible(aForm.BoundsRect);
        end;

        FrmMain.Logging.WriteToLogInfo('Ophalen schermpositie van scherm: ' + aForm.Name + ' is gereed.' );
      finally
        Free;
      end;
    Except
      FrmMain.Logging.WriteToLogError('Ophalen schermpositie van scherm: ' + aForm.Name + ' is mislukt.');
    end;
end;

function TSettingsmanager.CheckFormIsEntireVisible(Rect: TRect): TRect;
var
  Width: Integer;
  Height: Integer;
begin
  Result := Rect;
  Width := Rect.Right - Rect.Left;
  Height := Rect.Bottom - Rect.Top;
  if Result.Left < (Screen.DesktopLeft) then begin
    Result.Left := Screen.DesktopLeft;
    Result.Right := Screen.DesktopLeft + Width;
  end;
  if Result.Right > (Screen.DesktopLeft + Screen.DesktopWidth) then begin
    Result.Left := Screen.DesktopLeft + Screen.DesktopWidth - Width;
    Result.Right := Screen.DesktopLeft + Screen.DesktopWidth;
  end;
  if Result.Top < Screen.DesktopTop then begin
    Result.Top := Screen.DesktopTop;
    Result.Bottom := Screen.DesktopTop + Height;
  end;
  if Result.Bottom > (Screen.DesktopTop + Screen.DesktopHeight) then begin
    Result.Top := Screen.DesktopTop + Screen.DesktopHeight - Height;
    Result.Bottom := Screen.DesktopTop + Screen.DesktopHeight;
  end;
end;

procedure TSettingsmanager.StoreSplitterPos(aSplitter: TSplitter);
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      try
        writeinteger('Position', aSplitter.Name + '_Left', aSplitter.Left);
        writeinteger('Position', aSplitter.Name + '_Top', aSplitter.Top);
      finally
        Free;
      end;
    Except
      FrmMain.Logging.WriteToLogError('Opslaan splitter van splitter: ' + aSplitter.Name + ' is mislukt.' );
    end;
end;

procedure TSettingsmanager.RestoreSplitterPos(aSplitter: TSplitter);
begin
  With TIniFile.Create(ConfigurationFile) do
    try
      try
        aSplitter.Left := ReadInteger('Position', aSplitter.Name + '_Left', aSplitter.Left);
        aSplitter.Top := ReadInteger('Position', aSplitter.Name + '_Top', aSplitter.Top);
      finally
        Free;
      end;
    Except
      FrmMain.Logging.WriteToLogError('Ophalen positie van splitter: ' + aSplitter.Name + ' is mislukt.');
    end;
end;

end.

