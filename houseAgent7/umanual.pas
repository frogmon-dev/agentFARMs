unit uManual;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls
  { COMMON }
  , ucommon
  , uglobal
  { USER }
  ;

type

  { TfrmManual }

  TfrmManual = class(TForm)
    Button1: TButton;
    Image1: TImage;
    imgRightDown: TImage;
    imgRightStop: TImage;
    imgLeftup: TImage;
    imgLeftStop: TImage;
    imgLeftdown: TImage;
    imgRightUp: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbLeftStat: TLabel;
    lbRightStat: TLabel;
    tmClear: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgLeftdownClick(Sender: TObject);
    procedure imgLeftStopClick(Sender: TObject);
    procedure imgLeftupClick(Sender: TObject);
    procedure imgRightDownClick(Sender: TObject);
    procedure imgRightStopClick(Sender: TObject);
    procedure imgRightUpClick(Sender: TObject);
    procedure tmClearTimer(Sender: TObject);
  private
    clearCnt: Integer;


  public

  end;

var
  frmManual: TfrmManual;

implementation

uses
  uHouseAgent;

{$R *.lfm}

{ TfrmManual }


procedure TfrmManual.FormCreate(Sender: TObject);
begin
  left := 0;
  top := 0;
  clearCnt:=0;
end;


procedure TfrmManual.FormShow(Sender: TObject);
begin
//   btnLeftDown.Glyph.LoadFromFile('./images/arrow_up.png');
end;

procedure TfrmManual.imgLeftdownClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group1', 2);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group1 := 2;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Left Moter DOWN');

    imgleftup.Picture.LoadFromFile('./images/up.png');
    imgleftStop.Picture.LoadFromFile(gImageDir + 'stop.png');
    imgleftDown.Picture.LoadFromFile('./images/down_push.png');

    lbLeftStat.Caption:= '닫힘';
    clearCnt := 0;

end;

procedure TfrmManual.imgLeftStopClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group1', 0);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group1 := 0;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Left Moter STOP');

    imgleftup.Picture.LoadFromFile('./images/up.png');
    imgleftStop.Picture.LoadFromFile(gImageDir + 'stop_push.png');
    imgleftDown.Picture.LoadFromFile('./images/down.png');

    lbLeftStat.Caption:= '정지';
    clearCnt := 0;

end;

procedure TfrmManual.imgLeftupClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group1', 1);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group1 := 1;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Left Moter UP');

    imgleftup.Picture.LoadFromFile(gImageDir + 'up_push.png');
    imgleftStop.Picture.LoadFromFile(gImageDir + 'stop.png');
    imgleftDown.Picture.LoadFromFile(gImageDir + 'down.png');

    lbLeftStat.Caption:= '열림';
    clearCnt := 0;
end;

procedure TfrmManual.imgRightDownClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group2', 2);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group2 := 2;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Right Moter DOWN');

    imgRightUp.Picture.LoadFromFile('./images/up.png');
    imgRightStop.Picture.LoadFromFile(gImageDir + 'stop.png');
    imgRightDown.Picture.LoadFromFile('./images/down_push.png');

    lbRightStat.Caption:= '닫힘';
    clearCnt := 0;

end;

procedure TfrmManual.imgRightStopClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group2', 0);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group2 := 0;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Right Moter STOP');

    imgRightUp.Picture.LoadFromFile('./images/up.png');
    imgRightStop.Picture.LoadFromFile(gImageDir + 'stop_push.png');
    imgRightDown.Picture.LoadFromFile('./images/down.png');

    lbRightStat.Caption:= '정지';
    clearCnt := 0;
end;

procedure TfrmManual.imgRightUpClick(Sender: TObject);
begin
    WriteConfigInteger(gStatFile, 'CONTROL', 'am_mode', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group2', 1);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    frmMain.mControl.group2 := 1;
    SaveTraceToLogFile2(gLogDir, 'control', '[Manual] Right Moter UP');

    imgRightUp.Picture.LoadFromFile('./images/up_push.png');
    imgRightStop.Picture.LoadFromFile(gImageDir + 'stop.png');
    imgRightDown.Picture.LoadFromFile('./images/down.png');

    lbRightStat.Caption:= '열림';
    clearCnt := 0;

end;

procedure TfrmManual.tmClearTimer(Sender: TObject);
begin
  clearCnt := clearCnt + 1;
  if clearCnt > 30 then begin
    frmMain.Show();
    tmClear.Enabled:= false;
  end;
end;



end.

