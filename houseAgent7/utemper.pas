unit uTemper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls
  { COMMON }
  , ucommon
  , uglobal
  ;

type

  { TfrmTemper }

  TfrmTemper = class(TForm)
    cbWeatherChk: TCheckBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    lbTempSetMorning: TLabel;
    lbTempSetAfternoon: TLabel;
    btnUpMorning: TSpeedButton;
    btnDownMorning: TSpeedButton;
    SpeedButton3: TSpeedButton;
    btnUpAfternoon: TSpeedButton;
    btnDownAfternoon: TSpeedButton;
    tmClear: TTimer;
    procedure btnDownAfternoonClick(Sender: TObject);
    procedure btnUpAfternoonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnUpMorningClick(Sender: TObject);
    procedure btnDownMorningClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure tmClearTimer(Sender: TObject);
  private
    temper_group1: Integer;
    temper_group2: Integer;
    clearCnt: Integer;
    function saveSeting: Boolean;

  public
    procedure unShow();

  end;

var
  frmTemper: TfrmTemper;

implementation

{$R *.lfm}
uses
  uHouseAgent;

{ TfrmTemper }

procedure TfrmTemper.Button1Click(Sender: TObject);
begin

end;

procedure TfrmTemper.btnUpAfternoonClick(Sender: TObject);
begin
  temper_group2 := temper_group2 + 1;
  lbTempSetAfternoon.Caption := intToStr(temper_group2);
  clearCnt := 0;
end;

procedure TfrmTemper.btnDownAfternoonClick(Sender: TObject);
begin
  temper_group2 := temper_group2 - 1;
  lbTempSetAfternoon.Caption := intToStr(temper_group2);
  clearCnt := 0;
end;

procedure TfrmTemper.FormCreate(Sender: TObject);
begin
  left := 0;
  top := 0;
  clearCnt := 0;
end;

procedure TfrmTemper.FormShow(Sender: TObject);
begin
  temper_group1 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group1', 0);
  temper_group2 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group2', 0);;
  lbTempSetMorning.Caption := intToStr(temper_group1);
  lbTempSetAfternoon.Caption := intToStr(temper_group2);;
  tmClear.Enabled:= true;
  clearCnt := 0;
end;

procedure TfrmTemper.btnUpMorningClick(Sender: TObject);
begin
  temper_group1 := temper_group1 + 1;
  lbTempSetMorning.Caption := intToStr(temper_group1);
  clearCnt := 0;
end;

procedure TfrmTemper.btnDownMorningClick(Sender: TObject);
begin
  temper_group1 := temper_group1 - 1;
  lbTempSetMorning.Caption := intToStr(temper_group1);
  clearCnt := 0;
end;

procedure TfrmTemper.SpeedButton3Click(Sender: TObject);
begin
  if saveSeting then begin
    frmMain.Show();
    {
      frmMain.Visible:= true;
      frmMain.mWeatherUse := cbWeatherChk.Checked;
      frmMain.mTemperGroup1 := temper_group1;
      frmMain.mTemperGroup2 := temper_group2;
      }
      tmClear.Enabled:= false;
      Visible := false;
    end;
end;

procedure TfrmTemper.tmClearTimer(Sender: TObject);
begin
  clearCnt := clearCnt + 1;
  if clearCnt > 30 then begin
    if saveSeting then begin
      frmMain.Show();
      {
      frmMain.Visible:= true;
      frmMain.mWeatherUse := cbWeatherChk.Checked;
      frmMain.mTemperGroup1 := temper_group1;
      frmMain.mTemperGroup2 := temper_group2;
      }
      tmClear.Enabled:= false;
      Visible := false;

      tmClear.Enabled:= false;
      Visible := false;
    end;
  end;
end;

function TfrmTemper.saveSeting: Boolean;
begin
  result := false;
  try
    WriteConfigString(gConfFile, 'SETUP', 'temp_def_group1', lbTempSetMorning.Caption);
    WriteConfigString(gConfFile, 'SETUP', 'temp_def_group2', lbTempSetAfternoon.Caption);

    if cbWeatherChk.Checked then
      WriteConfigString(gConfFile, 'WEATHER', 'use', '1')
    else
      WriteConfigString(gConfFile, 'WEATHER', 'use', '0');

    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (SETUP:n)', [gConfFile]));
    SaveTraceToLogFile2(gLogDir, 'syslog', format('[TempMod] SET Temperature group1 %s', [lbTempSetMorning.Caption]));
    SaveTraceToLogFile2(gLogDir, 'syslog', format('[TempMod] SET Temperature group2 %s', [lbTempSetAfternoon.Caption]));
    result := true;
  except
    //todo log
  end;
end;

procedure TfrmTemper.unShow();
begin
  tmClear.Enabled:= false;
  Visible := false;
end;

end.

