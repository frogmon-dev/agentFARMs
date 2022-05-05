unit uSetTime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls
  { COMMON }
  , ucommon
  , uglobal
  { USER CUSTOM}
  , uKeyPad
  { USER ADD}
  , LCLType
;

type

  { TfrmSetTime }

  TfrmSetTime = class(TForm)
    Button1: TButton;
    edMinute: TEdit;
    edYear: TEdit;
    edSecond: TEdit;
    edHour: TEdit;
    edMonth: TEdit;
    edDay: TEdit;
    Label1: TLabel;
    lbCustomName: TLabel;
    lbCustomName1: TLabel;
    lbCustomName2: TLabel;
    lbCustomName3: TLabel;
    lbCustomName4: TLabel;
    lbCustomName5: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure edDayClick(Sender: TObject);
    procedure edHourClick(Sender: TObject);
    procedure edMinuteClick(Sender: TObject);
    procedure edMonthClick(Sender: TObject);
    procedure edSecondClick(Sender: TObject);
    procedure edYearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    procedure setDate();
  end;

var
  frmSetTime: TfrmSetTime;

implementation

{$R *.lfm}

{ TfrmSetTime }

uses
  uHouseAgent;

procedure TfrmSetTime.Button1Click(Sender: TObject);
var
  Reply, BoxStyle: Integer;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox('저장하시겠습니까?', '설정저장', BoxStyle);
  if Reply = IDYES then begin
    setDateTime(strToInt(edYear.Caption)
              , strToInt(edMonth.Caption)
              , strToInt(edDay.Caption)
              , strToInt(edHour.Caption)
              , strToInt(edMinute.Caption)
              , strToInt(edSecond.Caption)
              );
  end;

  frmMain.tmModCheck.Enabled := true;
  frmMain.tmControl.Enabled  := true;
  frmMain.Visible := true;
  Timer1.Enabled:= false;
  Visible := false;
end;

procedure TfrmSetTime.edDayClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edDay, true);
  RestartTimer(timer1);
end;

procedure TfrmSetTime.edHourClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edHour, true);
  RestartTimer(timer1);
end;


procedure TfrmSetTime.edMinuteClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute, true);
  RestartTimer(timer1);
end;

procedure TfrmSetTime.edMonthClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMonth, true);
  RestartTimer(timer1);
end;

procedure TfrmSetTime.edSecondClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edSecond, true);
  RestartTimer(timer1);
end;


procedure TfrmSetTime.edYearClick(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edYear, true);
  RestartTimer(timer1);
end;

procedure TfrmSetTime.FormCreate(Sender: TObject);
begin
  Visible := false;
end;

procedure TfrmSetTime.FormShow(Sender: TObject);
begin
  Timer1.Enabled := true;
end;

procedure TfrmSetTime.Timer1Timer(Sender: TObject);
begin
  frmMain.tmModCheck.Enabled := true;
  frmMain.tmControl.Enabled  := true;
  Timer1.Enabled := false;
  Visible := false;
end;

procedure TfrmSetTime.setDate();
begin
  edYear.Text   := intTostr(gYear);
  edMonth.Text  := intTostr(gMonth);
  edDay.Text    := intTostr(gDay);
  edHour.Text   := intTostr(gHour);
  edMinute.Text := intTostr(gMin);
  edSecond.Text := intTostr(gSec);
end;

end.

