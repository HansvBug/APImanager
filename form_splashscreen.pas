unit Form_SplashScreen;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TFrm_SplashScreen }

  TFrm_SplashScreen = class(TForm)
    Image1: TImage;
    LabelAppName: TLabel;
    LabelCopyright: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    TimerFader: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TimerFaderTimer(Sender: TObject);
  private
    FAlphaIncrement : integer;

  public
    Completed: Boolean;
  end;

const
  FADE_SPEED = 15;  { alpha steps per timer }

var
  Frm_SplashScreen: TFrm_SplashScreen;

implementation

uses settings;

{$R *.lfm}

{ TFrm_SplashScreen }

procedure TFrm_SplashScreen.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := AlphaBlendValue <= 0; { can only close once faded out completely }
  FAlphaIncrement := -FADE_SPEED; { rate of fade-out }
  TimerFader.Enabled := not CanClose; { enable the timer if we're not ready to close}
end;

procedure TFrm_SplashScreen.FormShow(Sender: TObject);
begin
  TimerFader.OnTimer := @TimerFaderTimer;
  AlphaBlend := True;
  AlphaBlendValue := 50;
  FAlphaIncrement := FADE_SPEED;
  TimerFader.Interval := 100;
  TimerFader.Enabled := True;

  OnShow := nil;
  Completed := False;
  Timer1.Interval := 2000; // 2s minimum time to show splash screen
  Timer1.Enabled := True;
end;

procedure TFrm_SplashScreen.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Completed := True;
end;

procedure TFrm_SplashScreen.TimerFaderTimer(Sender: TObject);
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

end.

