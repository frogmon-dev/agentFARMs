unit uTime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Buttons
  , uKeyPad
  , ucommon
  , uglobal
  , DateUtils;

type

  { TfrmTime }

  TfrmTime = class(TForm)
    cbTime1: TCheckBox;
    cbTime2: TCheckBox;
    cbTime3: TCheckBox;
    cbWeatherChk: TCheckBox;
    edTime1: TEdit;
    edTime4: TEdit;
    edMinute3: TEdit;
    edMinute4: TEdit;
    edTime2: TEdit;
    edMinute1: TEdit;
    edMinute2: TEdit;
    edTime5: TEdit;
    edTime6: TEdit;
    edMinute5: TEdit;
    edMinute6: TEdit;
    edTime3: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    plTime1: TPanel;
    plTime3: TPanel;
    plTime2: TPanel;
    ScrollBox1: TScrollBox;
    SpeedButton4: TSpeedButton;
    tmClear: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure cbTime1Click(Sender: TObject);
    procedure cbTime2Click(Sender: TObject);
    procedure cbTime3Click(Sender: TObject);
    procedure edMinute1Click(Sender: TObject);
    procedure edMinute2Click(Sender: TObject);
    procedure edMinute3Click(Sender: TObject);
    procedure edMinute4Click(Sender: TObject);
    procedure edMinute5Click(Sender: TObject);
    procedure edMinute6Click(Sender: TObject);
    procedure edTime1Click(Sender: TObject);
    procedure edTime2Click(Sender: TObject);
    procedure edTime3Click(Sender: TObject);
    procedure edTime4Click(Sender: TObject);
    procedure edTime5Click(Sender: TObject);
    procedure edTime6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure tmClearTimer(Sender: TObject);
  private
    clearCnt: Integer;
    arrPanel: array [0..5] of TPanel;
    function saveTimeSet: Boolean;
    procedure loadTimeSet;
  public
    procedure unShow();

  end;

var
  frmTime: TfrmTime;

implementation

{$R *.lfm}

uses
  uHouseAgent;

{ TfrmTime }

procedure TfrmTime.FormCreate(Sender: TObject);
begin
  left := 0;
  top := 0;
  arrPanel[0] := plTime1;
  arrPanel[1] := plTime2;
  arrPanel[2] := plTime3;

  clearCnt := 0;
end;

procedure TfrmTime.FormShow(Sender: TObject);
begin
  loadTimeSet;

  if ReadConfigInteger(gConfFile, 'WEATHER', 'use', 0) = 1 then
    cbWeatherChk.checked := true
  else
    cbWeatherChk.checked := false;

  tmClear.Enabled:= true;
  clearCnt := 0;
end;

procedure TfrmTime.SpeedButton4Click(Sender: TObject);
begin
  try
  if saveTimeSet then begin
    {
    frmMain.Visible:= true;
    frmKeyPad.Visible:= false;
    }
    frmMain.show();
    frmMain.mWeatherUse := cbWeatherChk.Checked;
    tmClear.Enabled:=false;
    Visible := false;
  end;
  except
    //togo Log
  end;
end;

procedure TfrmTime.tmClearTimer(Sender: TObject);
begin
  clearCnt := clearCnt + 1;
  if clearCnt > 30 then begin
    if saveTimeSet then begin
      frmMain.Show();
      //frmMain.Visible:= true;
      tmClear.Enabled:= false;
      Visible := false;
    end;
  end;
end;

function TfrmTime.saveTimeSet: Boolean;
begin
  result := false;

  if cbWeatherChk.Checked then
    WriteConfigString(gConfFile, 'WEATHER', 'use', '1')
  else
    WriteConfigString(gConfFile, 'WEATHER', 'use', '0');

  try
  if cbTime1.Checked then begin
     WriteConfigInteger(gConfFile, 'TIMER', 'check1', 1);
     WriteConfigString (gConfFile, 'TIMER', 'start1', format('%s:%s', [edTime1.Text, edMinute1.Text]));
     WriteConfigString (gConfFile, 'TIMER', 'end1', format('%s:%s', [edTime2.Text, edMinute2.Text]));
     SaveTraceToLogFile2(gLogDir, 'syslog', format('[Timer] SET Timer1 %s:%s ~ %s:%s', [edTime1.Text, edMinute1.Text, edTime2.Text, edMinute2.Text]));
  end
  else begin
    WriteConfigInteger(gConfFile, 'TIMER', 'check1', 0);
    WriteConfigString (gConfFile, 'TIMER', 'start1', '');
    WriteConfigString (gConfFile, 'TIMER', 'end1', '');
  end;

  if cbTime2.Checked then begin
    WriteConfigInteger(gConfFile, 'TIMER', 'check2', 1);
    WriteConfigString (gConfFile, 'TIMER', 'start2', format('%s:%s', [edTime3.Text, edMinute3.Text]));
    WriteConfigString (gConfFile, 'TIMER', 'end2', format('%s:%s', [edTime4.Text, edMinute4.Text]));
    SaveTraceToLogFile2(gLogDir, 'syslog', format('[Timer] SET Timer2 %s:%s ~ %s:%s', [edTime3.Text, edMinute3.Text, edTime4.Text, edMinute4.Text]));
  end
  else begin
    WriteConfigInteger(gConfFile, 'TIMER', 'check2', 0);
    WriteConfigString (gConfFile, 'TIMER', 'start2', '');
    WriteConfigString (gConfFile, 'TIMER', 'end2', '');
  end;

  if cbTime3.Checked then begin
     WriteConfigInteger(gConfFile, 'TIMER', 'check3', 1);
     WriteConfigString (gConfFile, 'TIMER', 'start3', format('%s:%s', [edTime5.Text, edMinute5.Text]));
     WriteConfigString (gConfFile, 'TIMER', 'end3', format('%s:%s', [edTime6.Text, edMinute6.Text]));
     SaveTraceToLogFile2(gLogDir, 'syslog', format('[Timer] SET Timer3 %s:%s ~ %s:%s', [edTime5.Text, edMinute5.Text, edTime6.Text, edMinute6.Text]));
  end
  else begin
    WriteConfigInteger(gConfFile, 'TIMER', 'check3', 0);
    WriteConfigString (gConfFile, 'TIMER', 'start3', '');
    WriteConfigString (gConfFile, 'TIMER', 'end3', '');
  end;
  SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (SETUP:n)', [gConfFile]));

  result := true;
  except
    //todo: log
  end;
end;

procedure TfrmTime.loadTimeSet;
var
  tmpDate: TDateTime;
begin
  if ReadConfigInteger(gConfFile, 'TIMER', 'check1', 0) = 1 then begin
    cbTime1.Checked:=true;
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start1', '00:00'));
    edTime1.Text := FormatDateTime('hh', tmpDate);
    edMinute1.Text := FormatDateTime('nn', tmpDate);
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end1', '00:00'));
    edTime2.Text := FormatDateTime('hh', tmpDate);
    if edTime2.Text = '00' then edTime2.Text := '24';
    edMinute2.Text := FormatDateTime('nn', tmpDate);
  end
  else begin
    cbTime1.Checked:=false;
    edTime1.Enabled:=false;
    edTime2.Enabled:=false;
    edMinute1.Enabled:=false;
    edMinute2.Enabled:=false;
  end;

  if ReadConfigInteger(gConfFile, 'TIMER', 'check2', 0) = 1 then begin
    cbTime2.Checked:=true;
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start2', '00:00'));
    edTime3.Text := FormatDateTime('hh', tmpDate);
    edMinute3.Text := FormatDateTime('nn', tmpDate);
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end2', '00:00'));
    edTime4.Text := FormatDateTime('hh', tmpDate);
    if edTime4.Text = '00' then edTime4.Text := '24';
    edMinute4.Text := FormatDateTime('nn', tmpDate);
  end
  else begin
    cbTime2.Checked:=false;
    edTime3.Enabled:=false;
    edTime4.Enabled:=false;
    edMinute3.Enabled:=false;
    edMinute4.Enabled:=false;
  end;

  if ReadConfigInteger(gConfFile, 'TIMER', 'check3', 0) = 1 then begin
    cbTime3.Checked:=true;
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start3', '00:00'));
    edTime5.Text := FormatDateTime('hh', tmpDate);
    edMinute5.Text := FormatDateTime('nn', tmpDate);
    tmpDate := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end3', '00:00'));
    edTime6.Text := FormatDateTime('hh', tmpDate);
    if edTime6.Text = '00' then edTime6.Text := '24';
    edMinute6.Text := FormatDateTime('nn', tmpDate);
  end
  else begin
    cbTime3.Checked:=false;
    edTime5.Enabled:=false;
    edTime6.Enabled:=false;
    edMinute5.Enabled:=false;
    edMinute6.Enabled:=false;
  end;
end;

procedure TfrmTime.unShow();
begin
  tmClear.Enabled:= false;
  Visible := false;
end;

procedure TfrmTime.Button1Click(Sender: TObject);
begin
end;

procedure TfrmTime.cbTime1Click(Sender: TObject);
begin
  if cbTime1.Checked then begin
    edTime1.Enabled:=true;
    edTime2.Enabled:=true;
    edMinute1.Enabled:=true;
    edMinute2.Enabled:=true;
  end
  else begin
    edTime1.Enabled:=false;
    edTime2.Enabled:=false;
    edMinute1.Enabled:=false;
    edMinute2.Enabled:=false;
  end;
end;

procedure TfrmTime.cbTime2Click(Sender: TObject);
begin
  if cbTime2.Checked then begin
    edTime3.Enabled:=true;
    edTime4.Enabled:=true;
    edMinute3.Enabled:=true;
    edMinute4.Enabled:=true;
  end
  else begin
    edTime3.Enabled:=false;
    edTime4.Enabled:=false;
    edMinute3.Enabled:=false;
    edMinute4.Enabled:=false;
  end;
end;

procedure TfrmTime.cbTime3Click(Sender: TObject);
begin
  if cbTime3.Checked then begin
    edTime5.Enabled:=true;
    edTime6.Enabled:=true;
    edMinute5.Enabled:=true;
    edMinute6.Enabled:=true;
  end
  else begin
    edTime5.Enabled:=false;
    edTime6.Enabled:=false;
    edMinute5.Enabled:=false;
    edMinute6.Enabled:=false;
  end;
end;

procedure TfrmTime.edMinute1Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute1, true);
  clearCnt := 0;
end;

procedure TfrmTime.edMinute2Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute2, true);
  clearCnt := 0;
end;

procedure TfrmTime.edMinute3Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute3, true);
  clearCnt := 0;
end;

procedure TfrmTime.edMinute4Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute4, true);
  clearCnt := 0;
end;

procedure TfrmTime.edMinute5Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute5, true);
  clearCnt := 0;
end;

procedure TfrmTime.edMinute6Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edMinute6, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime1Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime1, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime2Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime2, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime3Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime3, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime4Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime4, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime5Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime5, true);
  clearCnt := 0;
end;

procedure TfrmTime.edTime6Click(Sender: TObject);
begin
  frmKeyPad.Visible:= true;
  frmKeyPad.inputText(edTime6, true);
  clearCnt := 0;
end;

end.

