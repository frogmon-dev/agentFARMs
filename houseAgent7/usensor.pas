unit uSensor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, StdCtrls
  { COMMON }
  , ucommon
  , uglobal
  { USER ADD }
  , Process
  ;

type

  { TfrmSensor }

  TfrmSensor = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    lbCurrTemp2: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    pnlSearching: TPanel;
    SpeedButton2: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbSensorType1Click(Sender: TObject);
    procedure rbSensorType2Click(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    procedure scanSensor();

  public

  end;

var
  frmSensor: TfrmSensor;

implementation

{$R *.lfm}

uses
  uHouseAgent;

{ TfrmSensor }

procedure TfrmSensor.btnScanClick(Sender: TObject);
var
  cnt: Integer;
begin
  {
  pnlSearching.Top := 80;
  pnlSearching.Visible:= true;
  btnScan.Flat := true;
  btnScan.Enabled:= false;
  btnScan.Down := true;

  try
    try
      DeleteSection(gConfFile, 'DEVICE');
      //todo: sudo python3 SensorS.py
      if FileExists('scan.sh') then begin
          ProcessStart('./scan.sh &');
      end
      else begin
          SaveTraceToLogFile2(gLogDir, 'syslog', 'scan.sh file not exist!!');
      end;
      //todo: waiting image show
      Sleep(500);
      cnt := ReadConfigInteger(gConfFile, 'General', 'sensor_cnt', 0);
      if cnt = 0 then begin
          SaveTraceToLogFile2(gLogDir, 'syslog', 'Sensor Not Found!!');
          showmessage('SenSor Not Found!!');
      end;
    except
      on e: Exception do
          SaveTraceToLogFile2(gLogDir, 'syslog', format('[Sensor] Error :%s', [e.Message]));
    end;
  finally
    btnScan.Down := false;
    btnScan.Enabled:= true;
    btnScan.Flat := false;
    pnlSearching.Visible:= false;

  end;
  }
end;

procedure TfrmSensor.SpeedButton2Click(Sender: TObject);
begin

  try
    {
    if rbSensorType1.Checked then begin
        WriteConfigInteger(gConfFile, 'SETUP', 'flowercare'    , 0);
    end
    else begin
         WriteConfigInteger(gConfFile, 'SETUP', 'flowercare'    , 1);
    end;
    if cbOutSensor.Checked then begin
        WriteConfigInteger(gConfFile, 'General', 'out_sensor'    , 1);
    end
    else begin
         WriteConfigInteger(gConfFile, 'General', 'out_sensor'    , 0);
    end;
    if cbFanControl.Checked then begin
        WriteConfigInteger(gConfFile, 'General', 'fan_control'    , 1);
    end
    else begin
         WriteConfigInteger(gConfFile, 'General', 'fan_control'    , 0);
    end;
    if cbWaterControl.Checked then begin
        WriteConfigInteger(gConfFile, 'General', 'water_control'    , 1);
    end
    else begin
         WriteConfigInteger(gConfFile, 'General', 'water_control'    , 0);
    end;
    if cbWifi.Checked then begin
        WriteConfigInteger(gConfFile, 'SETUP', 'wifi'    , 1);
    end
    else begin
         WriteConfigInteger(gConfFile, 'SETUP', 'wifi'    , 0);
    end;
    if cbStandAlone.Checked then begin
        WriteConfigInteger(gConfFile, 'SETUP', 'standalone'    , 1);
    end
    else begin
         WriteConfigInteger(gConfFile, 'SETUP', 'standalone'    , 0);
    end;
    }
    frmMain.Show();
  except

  end;
end;

procedure TfrmSensor.scanSensor();
var
  hProcess: TProcess;
  sPass: String;

begin
  hProcess := TProcess.Create(nil);
  hProcess.Executable := '/bin/sh';

  hProcess.Parameters.Add('./scan.sh');
  hProcess.Options:= hProcess.Options + [poWaitOnExit, poUsePipes];
  hProcess.Execute;

  Memo1.Lines.LoadFromStream(hProcess.Output);

  hProcess.Free;

end;

procedure TfrmSensor.Button1Click(Sender: TObject);
begin

end;

procedure TfrmSensor.BitBtn1Click(Sender: TObject);
begin
  if ReadConfigString(gConfFile, 'DEVICE', 'sensor01', '') = '' then begin
    WriteConfigInteger(gConfFile, 'FLOWERCARE', 'sensor_cnt', 0);
    WriteConfigString(gConfFile, 'DEVICE', 'sensor01', '');
  end;

  scanSensor();
  memo1.Lines.Add('센서 찾기 완료');
end;

procedure TfrmSensor.FormCreate(Sender: TObject);
begin
  left := 0;
  top := 0;
end;

procedure TfrmSensor.FormShow(Sender: TObject);
begin
  {
  if ReadConfigInteger(gConfFile, 'SETUP', 'flowercare', 0) = 0 then begin
     rbSensorType1.Checked:= true;
     btnScan.Enabled:= false;
  end
  else begin
     rbSensorType2.Checked:= true;
     btnScan.Enabled:= true;
  end;

  if ReadConfigInteger(gConfFile, 'General', 'out_sensor', 0) = 0 then begin
     cbOutSensor.Checked:= false;
  end
  else begin
     cbOutSensor.Checked:= true;
  end;

  if ReadConfigInteger(gConfFile, 'General', 'fan_control', 0) = 0 then begin
     cbFanControl.Checked:= false;
  end
  else begin
     cbFanControl.Checked:= true;
  end;

  if ReadConfigInteger(gConfFile, 'General', 'water_control', 0) = 0 then begin
     cbWaterControl.Checked:= false;
  end
  else begin
     cbWaterControl.Checked:= true;
  end;

  if ReadConfigInteger(gConfFile, 'SETUP', 'wifi', 0) = 0 then begin
     cbWifi.Checked:= false;
  end
  else begin
     cbWifi.Checked:= true;
  end;

  if ReadConfigInteger(gConfFile, 'SETUP', 'standalone', 0) = 0 then begin
     cbWifi.Checked:= false;
  end
  else begin
     cbWifi.Checked:= true;
  end;
  }
end;

procedure TfrmSensor.rbSensorType1Click(Sender: TObject);
begin
  //btnScan.Enabled:= false;
end;


procedure TfrmSensor.rbSensorType2Click(Sender: TObject);
begin
  {
  if rbSensorType2.Checked then begin
       btnScan.Enabled:= true;
  end
  else begin
       btnScan.Enabled:= false;
  end;
  }
end;




end.

