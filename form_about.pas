unit Form_About;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TFrm_About }

  TFrm_About = class(TForm)
    Image1: TImage;
    LabelAppName: TLabel;
    LabelBuildDate: TLabel;
    LabelCopyright: TLabel;
    LabelVersion: TLabel;
    Panel1: TPanel;
    TimerFader: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerFaderTimer(Sender: TObject);
  private
    FAlphaIncrement : integer;

  public

  end;

const
  FADE_SPEED = 15;  { alpha steps per timer }

var
  Frm_About: TFrm_About;

implementation

uses settings;

{$R *.lfm}

{ TFrm_About }

procedure TFrm_About.FormCreate(Sender: TObject);
begin
  labelAppName.Caption := Settings.ApplicationName;
  LabelVersion.Caption := 'Version : ' + Settings.Version;
  LabelBuildDate.Caption := 'Build date : ' + Settings.BuildDate;
  LabelCopyright.Caption := Settings.Copyright;
end;

procedure TFrm_About.FormShow(Sender: TObject);
begin
  { initialise timer & variables }
  TimerFader.OnTimer := @TimerFaderTimer;
  AlphaBlend := True;
  AlphaBlendValue := 50; { starting fade level }
  FAlphaIncrement := FADE_SPEED;
  TimerFader.Interval := 100; { rate of animation }
  TimerFader.Enabled := True;
end;

procedure TFrm_About.TimerFaderTimer(Sender: TObject);
var
  b : integer; { local var for fade stage }
begin
  b := AlphaBlendValue + FAlphaIncrement;  { change fade level up or down }
  if b > 255 then { completely faded in }
  begin
    b := 255;
    TimerFader.Enabled := False; { disable timer - no longer fading }
  end
  else
  if b < 0 then
  begin
    b := 0;
    TimerFader.Enabled := False; { disable timer - no longer fading }
    Close;  { completely faded out - close form now }
  end;
  AlphaBlendValue := b; { update value }
  Caption := IntToStr(AlphaBlendValue); { display current alpha fade in caption for debugging }
end;

procedure TFrm_About.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_About.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := AlphaBlendValue <= 0; { can only close once faded out completely }
  FAlphaIncrement := -FADE_SPEED; { rate of fade-out }
  TimerFader.Enabled := not CanClose; { enable the timer if we're not ready to close }
end;

end.

