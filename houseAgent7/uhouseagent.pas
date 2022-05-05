unit uHouseAgent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  DateUtils
  { COMMON }
  , ucommon
  , uglobal
  { USER }
  , uManual
  , uTemper
  , uTime
  , uAuto
  , uSensor
  , uSetTime
  , uGraph
  , uProductLogin
  { User ADD }
  , jsonparser
  , fpjson
  , fphttpclient
  , RegexPr
  ;

type

  { TfrmMain }
  TfrmMain = class(TForm)
    btnSensorSearch: TSpeedButton;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    imgCap: TImage;
    imgLimit: TImage;
    imgTop: TImage;
    Image2: TImage;
    imgBattry: TImage;
    imgSensorError: TImage;
    Label1: TLabel;
    Label10: TLabel;
    lbSensorError: TLabel;
    Label9: TLabel;
    lbCap: TLabel;
    lbCustomValue1: TLabel;
    lbTempUptoCap: TLabel;
    lbTemploHi: TLabel;
    lbDate: TLabel;
    Label8: TLabel;
    lbAPM: TLabel;
    lbBattryRate: TLabel;
    lbhighlow: TLabel;
    lbSoilmoisture: TLabel;
    lbSoilfertility: TLabel;
    lbLight: TLabel;
    lbCurrTemp: TLabel;
    lbCustomValue: TLabel;
    lbCustomName: TLabel;
    lbTime: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    pnlRemoteControl: TPanel;
    SpeedButton1: TSpeedButton;
    btnGraph: TSpeedButton;
    tmControl: TTimer;
    tmSys: TTimer;
    tmModCheck: TTimer;
    procedure btnSensorSearchClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ColorSpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure lbTimeClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnGraphClick(Sender: TObject);
    procedure tmControlTimer(Sender: TObject);
    procedure tmModCheckTimer(Sender: TObject);
    procedure tmSysTimer(Sender: TObject);
  private
    mHouseMode: Integer;
    mWifiMode: Integer;
    initCheck: Boolean;
    mLstGroup1: Integer;
    mLstGroup2: Integer;

    function  chkInterNet(): Boolean;
    function  getRemoteControl(): Boolean;
    function  getWeatherInfo(): Boolean;
    function  saveDeviceJsonFile(fileName: String): boolean;
    procedure showRemoteControlMode();
    function  whoAmI(): String;
    function getJsonValueStr(jData: TJSONData; section: String; def: String
      ): String;
    function  getJsonValueInt(jData: TJSONData; section: String; def: Integer): Integer;
    function  getJsonStrValue(strData: String; section: String; def: String
      ): String;

  public
    strDateTime: String;
    //mTemper: integer;
    mTemperGroup1: integer;
    mTemperGroup2: integer;

    mGepTemp: Integer;
    mControl: TControlInfo;
    mWeatherUse: Boolean;
    mAutoPlant: TAutoPlant;
    mSensors: TSensorInfo;
    mSensorStat: boolean;
    mAlarm: Integer;
    mAlarmMent: String;
    mLastControl: Integer;
    mDayHighest: double;
    mDayLowest: double;
    mDevType: Integer;
    mOutWeather: TWeatherInfo;
    mSensorType: Integer;
    mShutDownCount: Integer;
    mWeatherCnt: Integer;
    mUserID: String;
    mLastAlarm: Integer;

    function getMode(def: Integer): Integer;
    function getCustomTime: Boolean;
    function getPlantInfo(): Boolean;
    procedure setStatus(stat: Boolean);
    function getAutoToOpen: Integer;
    procedure saveAlarm();
    procedure setCap(OC: Integer);
    procedure setAutoCap(TF: Boolean);

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.tmSysTimer(Sender: TObject);
var
  command: String;
begin
  TickTock();
  lbDate.Caption := format('%d월 %d일(%s)', [gMonth, gDay, getDayToday(now)]);
  if gHour > 12 then begin
    lbTime.Caption := format('%.2d:%.2d', [gHour-12, gMin]);
    lbAPM.Caption := 'PM';
  end
  else begin
    lbTime.Caption := format('%.2d:%.2d', [gHour, gMin]);
    lbAPM.Caption := 'AM';
  end;

  mSensorStat := getPlantInfo();
  if (not mSensorStat) and (mHouseMode <> HOUSE_TIME) then begin
    tmControl.Enabled := false;
    imgSensorError.Visible := not imgSensorError.Visible;
    lbSensorError.Visible := not lbSensorError.Visible;

  end
  else begin
      tmControl.Enabled := true;
      imgSensorError.Visible := false;
      lbSensorError.Visible := false;
  end;

  setStatus(mSensorStat);

  // todo read Remote.json
  if getRemoteControl() then begin
      showRemoteControlMode();
  end
  else begin
      if mHouseMode = HOUSE_REMOTE then begin
          { control.ini Init }
          WriteConfigInteger(gStatFile, 'CONTROL', 'group1'    , 0);
          WriteConfigInteger(gStatFile, 'CONTROL', 'group2'    , 0);
          WriteConfigInteger(gStatFile, 'CONTROL', 'group1_pos', 0);
          WriteConfigInteger(gStatFile, 'CONTROL', 'group2_pos', 0);
          SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write', [gStatFile]));

          mLstGroup1:=0;
          mLstGroup2:=0;
          pnlRemoteControl.Visible:= false;
          tmModCheck.Enabled:= true;
          tmControl.Enabled:= true;
      end;
  end;

  if gSec = 0 then begin
    mTemperGroup1 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group1', 0);
    mTemperGroup2 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group2', 0);

     if ReadConfigInteger(gConfFile, 'SETUP', 'wifi'    , 0) = 1 then begin
        //ProcessStart(format('./sfcom.sh --get_control_info &', [whoAmI()])); // didn't work so crontab
        //SaveTraceToLogFile2(gLogDir, 'mclog', 'Call Control Info');
       {
       inc(mWeatherCnt);
        if mWeatherCnt > 5 then begin
          ProcessStart(format('./sfcom.sh --weather_info_get', [mSensorType]));
          SaveTraceToLogFile2(gLogDir, 'mclog', 'Call Weather Info');
          mWeatherCnt := 0;
        end;
        }
     end;
     WriteConfigString(gConfFile, 'SETUP', 'lstworkdt', gStrDateTime);
     SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (SETUP:lstworkdt)', [gConfFile]));
     if not getWeatherInfo() then begin
        SaveTraceToLogFile2(gLogDir, 'mclog', 'Weather Info Error');
        mOutWeather.temp := 0.0;
        mOutWeather.angle:= 0;
        mOutWeather.humi := 0;
        mOutWeather.rain := 0.0;
        mOutWeather.wind := 0.0;
     end;
  end;
end;

function TfrmMain.chkInterNet(): Boolean;
var
  HTTPClient: TFPHTTPClient;
  IPRegex: TRegExpr;
  RawData: string;
begin
  try
      HTTPClient := TFPHTTPClient.Create(nil);
      IPRegex := TRegExpr.Create;
      try
        RawData:=HTTPClient.Get('http://checkip.dyndns.org');
        IPRegex.Expression := RegExprString('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
        if IPRegex.Exec(RawData) then
        begin
          gGlobalIp := IPRegex.Match[0];
          result := true;
        end
        else
        begin
          result := false;
        end;
      except
        on E: Exception do
        begin
          result := false;
        end;
      end;
    finally
      HTTPClient.Free;
      IPRegex.Free;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  mHouseMode := 0;
  left := 0;
  top := 0;
//  mTemper := 0;
  mTemperGroup1 := 0;
  mTemperGroup2 := 0;
  mShutDownCount := 0;
  mLastAlarm := 0;

  TickTock();

  gStartDir    := ExtractFilePath(Application.ExeName);
  {$IFDEF WINDOWS}
    gLogDir      := gStartDir + 'logs\';
    gConfDir     := gStartDir;
    gDataDir     := gStartDir + 'json\';
    gImageDir    := gStartDir + 'images\';
    gConfFile    := gStartDir + 'setup.ini';
    gStatFile    := gStartDir + 'control.ini';
  {$ELSE}
  gLogDir      := gStartDir + 'logs/';
  gConfDir     := gStartDir;
  gDataDir     := gStartDir + 'json/';
  gImageDir    := gStartDir + 'images/';
  gConfFile    := gStartDir + 'setup.ini';
  gStatFile    := gStartDir + 'control.ini';
  {$ENDIF}

  mControl.group1_pos:= 0;
  mControl.group2_pos:= 0;
  mControl.group1:= 0;
  mControl.group2:= 0;
  mDayHighest := 0;
  mDayLowest := 100;
  mWeatherCnt := 0;

  mAlarm := ERROR_INIT;

  mGepTemp  := ReadConfigInteger(gConfFile, 'SETUP', 'gep_temp', 3);
  mDevType  := ReadConfigInteger(gConfFile, 'SETUP', 'dev_type', 0);
  mWifiMode := ReadConfigInteger(gConfFile, 'SETUP', 'wifi'    , 0);
  mUserID   := ReadConfigString (gConfFile, 'SETUP', 'user_id', 'empty');
  if ReadConfigInteger(gConfFile, 'WEATHER', 'use', 0) = 1 then
    mWeatherUse := true
  else
    mWeatherUse := false;

  SaveTraceToLogFile2(gLogDir, 'mclog', 'Program Start!');

  //btnSensorSearch.Top := 124;
  initCheck := false;

  { control.ini Init }
  WriteConfigInteger(gStatFile, 'CONTROL', 'group1'    , 0);
  WriteConfigInteger(gStatFile, 'CONTROL', 'group2'    , 0);
  WriteConfigInteger(gStatFile, 'CONTROL', 'group1_pos', 0);
  WriteConfigInteger(gStatFile, 'CONTROL', 'group2_pos', 0);
  SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));
  mLstGroup1:=0;
  mLstGroup2:=0;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  strLstWorkDt: String;
  lstWorkDt: TDateTime;
begin
  mAlarm := ERROR_NORMAL;

  //todo product login
  {
  if not frmProductLogin.doLogin() then begin
    frmProductLogin.Visible:= true;
  end;
  }

  { Check Dial Mode }
  case getMode(0) of
      HOUSE_MANUAL: begin
        //lbModType.Caption := '수동모드';
          if FileExists(gImageDir + 'top_manual.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_manual.png');
          lbCustomName.Caption := '설정모드';
          lbCustomValue.Caption := '수동';
          frmManual.Show();
          {
          frmManual.Visible := true;
          frmMain.Visible := false;
          }
          frmTemper.unShow();
          frmTime.unShow();
          frmAuto.unShow();

          mAlarm := ERROR_MANUAL;
          mAlarmMent := 'Manual Mode';
          setAutoCap(false);
      end;
      HOUSE_TEMPER: begin
          //lbModType.Caption := '온도우선모드';
          if FileExists(gImageDir + 'top_temp.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_temp.png');
          lbCustomName.Caption := '설정온도';

          mTemperGroup1 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group1', 0);
          mTemperGroup2 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group2', 0);

          lbCustomValue.Font.Size := 45;

          lbCustomValue.Caption := intToStr(mTemperGroup1) + ' - ' + intToStr(mTemperGroup2) ;

          setAutoCap(false);
      end;
      HOUSE_TIME: begin
          //lbModType.Caption := '시간우선모드';
          if FileExists(gImageDir + 'top_timer.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_timer.png');
          lbCustomName.Caption := '현재시간';
          lbCustomValue.Font.Size := 72;
          if getCustomTime then begin
            lbCustomValue.Caption := '열림';
          end
          else begin
            lbCustomValue.Caption := '닫힘';
          end;
          setAutoCap(false);
      end;
      HOUSE_AUTO: begin
          //lbModType.Caption := '자동모드';
          if FileExists(gImageDir + 'top_auto.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_auto.png');
          lbCustomName.Caption := '작물종류';
          mAutoPlant := frmAuto.getPlantInfoByName(ReadConfigString(gConfFile, 'AUTO', 'name', ''));
          if Length(mAutoPlant.plantNM) > 12 then begin
              lbCustomValue.Font.Size := 30;
          end
          else begin
              lbCustomValue.Font.Size := 68;
          end;
          lbCustomValue.Caption := mAutoPlant.plantNM;
          setAutoCap(true);
      end;
  end;
end;

procedure TfrmMain.Image1Click(Sender: TObject);
begin
end;

procedure TfrmMain.Image1DblClick(Sender: TObject);
begin
  close();
end;

procedure TfrmMain.lbTimeClick(Sender: TObject);
begin
  frmSetTime.setDate();
  frmSetTime.Show();
  //frmSetTime.Visible := true;
  //Visible := false;
end;



procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  case mHouseMode of
       HOUSE_MANUAL: begin
           frmManual.show();
           {
           frmManual.Visible := true;
           frmMain.Visible := false;
           frmTemper.Visible := false;
           frmTime.Visible := false;
           frmAuto.Visible := false;
           }
       end;
       HOUSE_TEMPER: begin
           frmTemper.Show();
           {
           frmTemper.Visible := true;
           frmMain.Visible := false;
           frmManual.Visible := false;
           frmTime.Visible := false;
           frmAuto.Visible := false;
           }
       end;
       HOUSE_TIME: begin
           frmTime.Show();
           {
           frmTime.Visible := true;
           frmMain.Visible := false;
           frmManual.Visible := false;
           frmTemper.Visible := false;
           frmAuto.Visible := false;
           }
       end;
       HOUSE_AUTO: begin
           frmAuto.Show();
           //frmAuto.Visible := true;
       end;
   end;
end;

procedure TfrmMain.btnGraphClick(Sender: TObject);
begin
  frmGraph.Show();
  //frmGraph.Visible:=true;
  //Visible:=false;
end;

procedure TfrmMain.tmControlTimer(Sender: TObject);
var
   iTemp: Integer;

   function compNChg(newVal:Integer; var oldVal:Integer; section: String): Boolean;
   begin
     result := false;
     if newVal <> oldVal then begin
       try
         WriteConfigInteger(gStatFile, 'CONTROL', section   , newVal);
         SaveTraceToLogFile2(gLogDir, 'mclog', format('remote control %s:%d->%d', [section, oldVal, newVal]));
         oldVal := newVal;
         result := true;
       except
         result := false;
       end;
     end;
   end;
begin
  try
    case mHouseMode of
        HOUSE_MANUAL: begin
          mAlarm := ERROR_MANUAL;
        end;
        HOUSE_TEMPER: begin
          iTemp := round(mSensors.temperature);
          // todo rain check and light check
          if (mOutWeather.pty > 0) and (mSensors.light < 10000) and mWeatherUse then begin

            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

            setCap(MOTER_CLOSE);
            mControl.group1  := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[TempMod] House close by rain (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_rain64.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_rain64.png');
              imgLimit.Visible:= true;
            end;
          end
          else if (mOutWeather.wind > 14) and mWeatherUse then begin
            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');
            setCap(MOTER_CLOSE);
            mControl.group1 := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[TempMod] House close by wind (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_windy.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_windy.png');
              imgLimit.Visible:= true;
            end;
          end
          else begin
            imgLimit.Visible:= false;
            lbCustomValue.Caption := intToStr(mTemperGroup1) + ' - ' + intToStr(mTemperGroup2) ;
            if iTemp > (mTemperGroup1) then begin
              {Manual Mode}
              compNChg(MOTER_OPEN, mLstGroup1, 'group1');
              setCap(MOTER_OPEN);

              mControl.group1 := MOTER_OPEN;
              if mLastControl <> MOTER_OPEN then begin
                  mLastControl := MOTER_OPEN;
                  SaveTraceToLogFile2(gLogDir, 'mclog',
                      format('[TempMod] House group1 open %.2f', [mSensors.temperature]));
              end;
              {todo : Auto Mode}
            end
            else if iTemp < (mTemperGroup1) then begin
              {Manual Mode}
              compNChg(MOTER_CLOSE, mLstGroup1, 'group1');

              setCap(MOTER_CLOSE);
              mControl.group1 := MOTER_CLOSE;
              if mLastControl <> MOTER_CLOSE then begin
                  mLastControl := MOTER_CLOSE;
                  SaveTraceToLogFile2(gLogDir, 'mclog',
                      format('[TempMod] House group1 close %.2f', [mSensors.temperature]));
              end;
            end
            else begin
                compNChg(MOTER_STOP, mLstGroup1, 'group1');
                setCap(MOTER_STOP);
                mControl.group1  := MOTER_STOP;
                if mLastControl <> MOTER_STOP then begin
                    mLastControl := MOTER_STOP;
                    SaveTraceToLogFile2(gLogDir, 'mclog',
                        format('[TempMod] House group1 stop %.2f', [mSensors.temperature]));
                end;
            end;

            if iTemp > (mTemperGroup2) then begin
              {Manual Mode}
              compNChg(MOTER_OPEN, mLstGroup2, 'group2');
              setCap(MOTER_OPEN);
              mControl.group2 := MOTER_OPEN;
              if mLastControl <> MOTER_OPEN then begin
                  mLastControl := MOTER_OPEN;
                  SaveTraceToLogFile2(gLogDir, 'mclog',
                      format('[TempMod] House group2 open %.2f', [mSensors.temperature]));
              end;
              {todo : Auto Mode}
            end
            else if iTemp < (mTemperGroup2) then begin
              {Manual Mode}
              compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

              setCap(MOTER_CLOSE);
              mControl.group2 := MOTER_CLOSE;
              if mLastControl <> MOTER_CLOSE then begin
                  mLastControl := MOTER_CLOSE;
                  SaveTraceToLogFile2(gLogDir, 'mclog',
                      format('[TempMod] House group2 close %.2f', [mSensors.temperature]));
              end;
            end
            else begin
                compNChg(MOTER_STOP, mLstGroup2, 'group2');

                setCap(MOTER_STOP);
                mControl.group2 := MOTER_STOP;
                if mLastControl <> MOTER_STOP then begin
                    mLastControl := MOTER_STOP;
                    SaveTraceToLogFile2(gLogDir, 'mclog',
                        format('[TempMod] House group2 stop %.2f', [mSensors.temperature]));
                end;
            end;
          end;
        end;
        HOUSE_TIME: begin
          // todo rain check and light check
          if (mOutWeather.pty > 0) and (mSensors.light < 10000) and mWeatherUse then begin
            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

            setCap(MOTER_CLOSE);
            mControl.group1 := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[Timer] House close by rain (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_rain64.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_rain64.png');
              imgLimit.Visible:= true;
            end;
          end
          else if (mOutWeather.wind > 14) and mWeatherUse then begin
            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

            setCap(MOTER_CLOSE);
            mControl.group1  := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[TempMod] House close by wind (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_windy.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_windy.png');
              imgLimit.Visible:= true;
            end;
          end
          else begin
            imgLimit.Visible:= false;
            if getCustomTime then begin
              {Manual Mode}
              compNChg(MOTER_OPEN, mLstGroup1, 'group1');
              compNChg(MOTER_OPEN, mLstGroup2, 'group2');

              setCap(MOTER_OPEN);
              mControl.group1  := MOTER_OPEN;
              mControl.group2 := MOTER_OPEN;
              lbCustomValue.Caption := '열림';
              if mLastControl <> MOTER_OPEN then begin
                  mLastControl := MOTER_OPEN;
                  SaveTraceToLogFile2(gLogDir, 'mclog', '[Timer] House open');
              end;
              {todo: Auto Mode}
            end else begin
              {Manual Mode}
              compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
              compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

              setCap(MOTER_CLOSE);
              mControl.group1  := MOTER_CLOSE;
              mControl.group2 := MOTER_CLOSE;
              lbCustomValue.Caption := '닫힘';
              if mLastControl <> MOTER_CLOSE then begin
                  mLastControl := MOTER_CLOSE;
                  SaveTraceToLogFile2(gLogDir, 'mclog', '[Timer] House close');
              end;
              {todo: Auto Mode}
            end;
          end;
        end;
        HOUSE_AUTO: begin
          // todo rain check and light check
          if (mOutWeather.pty > 0) and (mSensors.light < 10000) and mWeatherUse then begin
            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

            setCap(MOTER_CLOSE);
            mControl.group1  := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[Auto] House close by rain (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_rain64.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_rain64.png');
              imgLimit.Visible:= true;
            end;
          end
          else if (mOutWeather.wind > 14) and mWeatherUse then begin
            compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
            compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

            setCap(MOTER_CLOSE);
            mControl.group1  := MOTER_CLOSE;
            mControl.group2 := MOTER_CLOSE;
            if mLastControl <> MOTER_CLOSE then begin
                mLastControl := MOTER_CLOSE;
                SaveTraceToLogFile2(gLogDir, 'mclog',
                    format('[TempMod] House close by wind (%d:%d)', [mOutWeather.pty, mSensors.light]));
            end;
            if FileExists(gImageDir + 'w_windy.png') then begin
              imgLimit.Picture.LoadFromFile(gImageDir + 'w_windy.png');
              imgLimit.Visible:= true;
            end;
          end
          else begin
            imgLimit.Visible:= false;
            case getAutoToOpen() of
                  MOTER_OPEN: begin
                      {Manual Moter Mode}
                      compNChg(MOTER_OPEN, mLstGroup1, 'group1');
                      compNChg(MOTER_OPEN, mLstGroup2, 'group2');

                      setCap(MOTER_OPEN);
                      mControl.group1  := MOTER_OPEN;
                      mControl.group2 := MOTER_OPEN;
                      if mLastControl <> MOTER_OPEN then begin
                          mLastControl := MOTER_OPEN;
                          SaveTraceToLogFile2(gLogDir, 'mclog',
                              format('[Auto] House open %.2f', [mSensors.temperature]));
                      end;
                      {todo: Auto Moter Mode}
                  end;
                  MOTER_CLOSE : begin
                      {Manual Moter Mode}
                      compNChg(MOTER_CLOSE, mLstGroup1, 'group1');
                      compNChg(MOTER_CLOSE, mLstGroup2, 'group2');

                      setCap(MOTER_CLOSE);
                      mControl.group1  := MOTER_CLOSE;
                      mControl.group2 := MOTER_CLOSE;
                      if mLastControl <> MOTER_CLOSE then begin
                          mLastControl := MOTER_CLOSE;
                          SaveTraceToLogFile2(gLogDir, 'mclog',
                              format('[Auto] House close %.2f', [mSensors.temperature]));
                      end;
                      {todo: Auto Moter Mode}
                  end;
                  MOTER_STOP : begin
                       {Manual Moter Mode}
                      compNChg(MOTER_STOP, mLstGroup1, 'group1');
                      compNChg(MOTER_STOP, mLstGroup2, 'group2');

                      setCap(MOTER_STOP);
                      mControl.group1  := MOTER_STOP;
                      mControl.group2 := MOTER_STOP;
                      if mLastControl <> MOTER_STOP then begin
                          mLastControl := MOTER_STOP;
                          SaveTraceToLogFile2(gLogDir, 'mclog',
                              format('[Auto] House stop %.2f', [mSensors.temperature]));
                      end;
                      {todo: Auto Moter Mode}
                  end;
              end;
          end;
        end;
          // check Plant temp and Move
          // todo 1: find out the day, night dualing time
    end;
    saveAlarm();
  except

  end;
end;


procedure TfrmMain.btnSensorSearchClick(Sender: TObject);
begin
  //close();
  frmSensor.Show;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  if DeleteFile(gDataDir+'action.json') then begin
    { control.ini Init }
    WriteConfigInteger(gStatFile, 'CONTROL', 'group1'    , 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group2'    , 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group1_pos', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'group2_pos', 0);
    WriteConfigInteger(gStatFile, 'CONTROL', 'remote'    , 0);
    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));

    mLstGroup1:=0;
    mLstGroup2:=0;
    pnlRemoteControl.Visible:= false;
    tmModCheck.Enabled:= true;
    tmControl.Enabled:= true;

  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  frmSetTime.Visible := true;
  //close;
end;

procedure TfrmMain.ColorSpeedButton1Click(Sender: TObject);
begin
end;

procedure TfrmMain.tmModCheckTimer(Sender: TObject);
var
  imod: Integer;
begin
  imod := getMode(mHouseMode);
  if mHouseMode <> imod then begin
    mHouseMode := imod;
    mAlarm := ERROR_NORMAL;
    case mHouseMode of
        HOUSE_MANUAL: begin
          //lbModType.Caption := '수동모드';
          if FileExists(gImageDir + 'top_manual.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_manual.png');
          lbCustomName.Caption := '설정모드';
          lbCustomValue.Caption := '수동';
          frmManual.Show();
          {
          frmManual.Visible := true;
          frmMain.Visible := false;
          }
          frmTemper.unShow();
          frmTime.unShow();
          frmAuto.unShow();

          mAlarm := ERROR_MANUAL;
          mAlarmMent := 'Manual Mode';

          setAutoCap(false);
          SaveTraceToLogFile2(gLogDir, 'mclog', '[Main] Mod Change to Manual');
          setAutoCap(false);
        end;
        HOUSE_TEMPER: begin
            if FileExists(gImageDir + 'top_temp.png') then
              imgTop.Picture.LoadFromFile(gImageDir + 'top_temp.png');
            lbCustomName.Caption := '설정온도';

            mTemperGroup1 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group1', 0);
            mTemperGroup2 := ReadConfigInteger(gConfFile, 'SETUP', 'temp_def_group2', 0);

            lbCustomValue.Font.Size := 45;

            lbCustomValue.Caption := intToStr(mTemperGroup1) + ' - ' + intToStr(mTemperGroup2) ;

            setAutoCap(false);

            frmTemper.Show();
            SaveTraceToLogFile2(gLogDir, 'mclog', '[Main] Mod Change to Temperature');
        end;
        HOUSE_TIME: begin
          if FileExists(gImageDir + 'top_timer.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_timer.png');
          lbCustomName.Caption := '현재시간';
          lbCustomValue.Font.Size := 72;
          if getCustomTime then begin
            lbCustomValue.Caption := '열림';
          end
          else begin
            lbCustomValue.Caption := '닫힘';
          end;
          setAutoCap(false);

          frmTime.Show();
          SaveTraceToLogFile2(gLogDir, 'mclog', '[Main] Mod Change to Timer');
        end;
        HOUSE_AUTO: begin
          //lbModType.Caption := '자동모드';
          if FileExists(gImageDir + 'top_auto.png') then
            imgTop.Picture.LoadFromFile(gImageDir + 'top_auto.png');
          lbCustomName.Caption := '작물종류';
          mAutoPlant := frmAuto.getPlantInfoByName(ReadConfigString(gConfFile, 'AUTO', 'name', ''));
          if Length(mAutoPlant.plantNM) > 12 then begin
              lbCustomValue.Font.Size := 30;
          end
          else begin
              lbCustomValue.Font.Size := 68;
          end;
          lbCustomValue.Caption := mAutoPlant.plantNM;
          setAutoCap(true);
          frmAuto.Show();
          SaveTraceToLogFile2(gLogDir, 'mclog', '[Main] Mod Change to Auto');
        end;
    end;
    saveAlarm();
  end
  ;{
  else begin
      if mHouseMode = HOUSE_MANUAL then begin
         if frmManual.Visible = false then begin
            frmManual.Visible := true;
         end;
      end;
  end;
  }
end;

function TfrmMain.getMode(def: Integer): Integer;
begin
  try
    result := ReadConfigInteger(gConfFile, 'SETUP', 'mod', def);
  except
    result := def;
  end;
end;

function TfrmMain.getCustomTime: Boolean;
var
    todayDT: TDateTime;
    startDT: TDateTime;
    endDT: TDateTime;
begin
    todayDT := ScanDateTime('yyyymmdd', gStrDate);
    result := false;
    { Check Date No.1 }
    if ReadConfigInteger(gConfFile, 'TIMER', 'check1', 0) = 1 then begin
        startDT := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start1', '00:00'));
        endDT   := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end1'  , '00:00'));
        startDT := todayDT + startDT;
        endDT := todayDT + endDT;
        if (startDT < now()) and (now()< endDT) then begin
          result := true;
          //lbDateTime.Caption := formatDateTime('yyyymmdd', endDT);
          exit;
        end;
    end;

    { Check Date No.2 }
    if ReadConfigInteger(gConfFile, 'TIMER', 'check2', 0) = 1 then begin
        startDT := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start2', '00:00'));
        endDT   := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end2'  , '00:00'));
        startDT := todayDT + startDT;
        endDT := todayDT + endDT;
        if (startDT < now()) and (now()< endDT) then begin
          result := true;
          //lbDateTime.Caption := formatDateTime('yyyymmdd', endDT);
          exit;
        end;
    end;

    { Check Date No.3 }
    if ReadConfigInteger(gConfFile, 'TIMER', 'check3', 0) = 1 then begin
        startDT := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'start3', '00:00'));
        endDT   := ScanDateTime('hh:nn', ReadConfigString(gConfFile, 'TIMER', 'end3'  , '00:00'));
        startDT := todayDT + startDT;
        endDT := todayDT + endDT;
        if (startDT < now()) and (now()< endDT) then begin
          result := true;
          //lbDateTime.Caption := formatDateTime('yyyymmdd', endDT);
          exit;
        end;
    end;
end;

function TfrmMain.getRemoteControl(): Boolean;
var
  jData: TJSONData;
  aStrLst: TStringList;
  val: Integer;

  function compNChg(newVal, oldVal:Integer; section: String): Boolean;
  begin
    result := false;
    if newVal <> oldVal then begin
      try
        WriteConfigInteger(gStatFile, 'CONTROL', section, newVal);
        SaveTraceToLogFile2(gLogDir, 'mclog', format('remote control %s:%d->%d', [section, oldVal, newVal]));
        result := true;
      except
        result := false;
      end;
    end;
  end;
begin
  result := false;
  aStrLst := TStringList.Create();
  try
    if FileExists(gDataDir+'action.json') then begin
      aStrLst.LoadFromFile(gDataDir+'action.json');

      val := StrToInt(getJsonStrValue(aStrlst.Text, 'group1', '99'));
      if val <> 99 then begin
        if compNChg(val, mLstGroup1, 'group1') then begin
          mLstGroup1 := val;
        end;
        result := true;
      end;

      val := StrToInt(getJsonStrValue(aStrlst.Text, 'group2', '99'));
      if val <> 99 then begin
        if compNChg(val, mLstGroup2, 'group2') then begin
          mLstGroup2 := val;
        end;
        result := true;
      end;

      val := StrToInt(getJsonStrValue(aStrlst.Text, 'active', '99'));
      if val = 1 then begin
        result := true;
      end
      else if val = 0 then begin
        result := false;
      end;
    end;
  finally
    FreeAndNil(aStrLst);
  end;
end;

function TfrmMain.saveDeviceJsonFile(fileName: String): boolean;
var
  json : TJSONObject;
  List: TStringList;
begin
  List := TStringList.Create;
  json := TJSONObject.Create;
  result := false;
  try
    try
    json.Add('DEV_ID'  , whoAmI());
    json.add('MODE'    , mHouseMode);
    json.add('ALARM'   , mAlarm);
    json.add('TEMP'    , format('%.2f', [mSensors.temperature]));
    json.add('HUMI'    , mSensors.humidity);
    json.add('MOIST'   , mSensors.moisture);
    json.add('COND'    , mSensors.conductivity);
    json.add('CDS'     , mSensors.light);
    json.add('BATTERY' , mSensors.battery);
    json.add('OUT_TEMP', format('%.2f', [mSensors.out_temp]));
    json.add('OUT_HUMI', mSensors.out_humi);
    json.add('OUT_WIND', mSensors.out_wind);
    json.add('OUT_BATT', mSensors.out_batt);
    json.add('OUT_RAIN', mOutWeather.pty);
    json.add('OUT_SKY' , mOutWeather.sky);



    json.add('LASTUPDT', formatDateTime('yyyymmddhhnnss', mSensors.lastUpDt));
    List.Add(Utf8Encode(json.FormatJSON));
    List.SaveToFile(fileName);
    result := true;
    except
      on E: Exception do
      begin
        SaveTraceToLogFile2(gLogDir, 'mclog',
            format('[ERROR] %s', [e.Message]));
      end;
    end;
  finally
    json.Free;
    List.Free;
  end;

end;

{
function TfrmMain.getPlantInfo(): Boolean;
var
  jData: TJSONData;
  aStrLst: TStringList;
  chkUpdate: boolean;
  csvMsg: String;
begin
  chkUpdate := false;
  aStrLst := TStringList.Create();
  try
    if FileExists(gDataDir+'sensor01.json') then begin
      try
        aStrLst.LoadFromFile(gDataDir+'sensor01.json');
        jData := GetJson(aStrlst.Text);
        { Update check }
        if (mSensors.timestamp <> TJSONObject(jData).Get('timestamp')) then
        begin
           chkUpdate := true;

           mSensors.name         := TJSONObject(jData).Get('name');
           mSensors.moisture     := TJSONObject(jData).Get('moisture');
           mSensors.temperature  := TJSONObject(jData).Get('temperature');
           mSensors.light        := TJSONObject(jData).Get('light');
           mSensors.conductivity := TJSONObject(jData).Get('conductivity');
           mSensors.timestamp    := TJSONObject(jData).Get('timestamp');
           mSensors.firmware     := TJSONObject(jData).Get('firmware');
           mSensors.battery      := TJSONObject(jData).Get('battery');
           mSensors.lastUpDt     := ScanDateTime('YYYY-MM-DD hh:nn:ss', mSensors.timestamp);
        end;

        if SecondsBetween(now(), mSensors.lastUpDt) > 300 then begin
          result := false;
        end
        else begin
          if mSensors.temperature > mDayHighest then
              mDayHighest := mSensors.temperature;
          if mSensors.temperature < mDayLowest then
              mDayLowest := mSensors.temperature;

          if chkUpdate then begin
            { graph csv file save }
            csvMsg := format('%s,%.2f,%d,%d,%.2f', [formatDateTime('hh:nn:ss', mSensors.lastUpDt), mSensors.temperature, mSensors.moisture, mSensors.light, mOutWeather.temp]);
            ToCSVFile(gLogDir, format('grp_%s', [formatDateTime('yyyymmdd', mSensors.lastUpDt)]), 'hhnnss,temp,humi,light,outTemp', csvMsg);
          end;

          result := true;
        end;
      except
          result := false;
      end;
    end
    else begin
      result := false;
    end;

    if chkUpdate then begin
      { save device.json file }
       saveDeviceJsonFile(gDataDir+'device.json');
    end;

  finally
    FreeAndNil(aStrLst);
  end;
end;
}


function TfrmMain.getPlantInfo(): Boolean;
var
  jData: TJSONData;
  aStrLst: TStringList;
  chkUpdate: boolean;
  csvMsg: String;
begin
  chkUpdate := false;
  aStrLst := TStringList.Create();
  try
    if FileExists(gDataDir+'device.json') then begin
      try
        aStrLst.LoadFromFile(gDataDir+'device.json');
        jData := GetJson(aStrlst.Text);
        { Update check }
        if (mSensors.timestamp <> TJSONObject(jData).Get('LASTUPDT')) then
        begin
           chkUpdate := true;

           mSensors.name         := whoAmI();
           mSensors.moisture     := TJSONObject(jData).Get('MOIST');
           mSensors.temperature  := TJSONObject(jData).Get('TEMP');
           mSensors.light        := TJSONObject(jData).Get('CDS');
           mSensors.conductivity := TJSONObject(jData).Get('COND');
           mSensors.timestamp    := TJSONObject(jData).Get('LASTUPDT');
           //mSensors.firmware     := TJSONObject(jData).Get('firmware');
           mSensors.battery      := TJSONObject(jData).Get('BATTERY');
           mSensors.lastUpDt     := ScanDateTime('YYYYMMDDhhnnss', TJSONObject(jData).Get('LASTUPDT'));
        end;

        if SecondsBetween(now(), mSensors.lastUpDt) > 600 then begin
          mAlarm := ERROR_CONNECT;
          result := false;
        end
        else begin
          if mSensors.temperature > mDayHighest then
              mDayHighest := mSensors.temperature;
          if mSensors.temperature < mDayLowest then
              mDayLowest := mSensors.temperature;

          if chkUpdate then begin
            { graph csv file save }
            csvMsg := format('%s,%.2f,%d,%d,%.2f', [formatDateTime('hh:nn:ss', mSensors.lastUpDt), mSensors.temperature, mSensors.moisture, mSensors.light, mOutWeather.temp]);
            ToCSVFile(gLogDir, format('grp_%s', [formatDateTime('yyyymmdd', mSensors.lastUpDt)]), 'hhnnss,temp,humi,light,outTemp', csvMsg);
          end;

          result := true;
        end;
      except
          result := false;
      end;
    end
    else begin
      result := false;
    end;

    {{
    if chkUpdate then begin
      { save device.json file }
       saveDeviceJsonFile(gDataDir+'device.json');
       if ReadConfigInteger(gConfFile, 'SETUP', 'wifi'    , 0) = 1 then begin
          ProcessStart(format('./sfcom.sh --status_upload', [mSensorType]));
          if mUserID <> 'empty' then
             ProcessStart(format('./sfcom.sh --DIYs_update %s %s', [mUserID, whoAmI()]));

       end;
    end;
    }}
  finally
    FreeAndNil(aStrLst);
  end;
end;

function TfrmMain.getWeatherInfo(): Boolean;
begin
  result := false;
  if ReadConfigInteger(gConfFile, 'WEATHER', 'location0'    , 0) > 0 then begin
    mOutWeather.temp      := ReadConfigInteger(gConfFile, 'WEATHER', 't1h'    , 0);
    mOutWeather.humi      := ReadConfigInteger(gConfFile, 'WEATHER', 'reh'    , 0);
    mOutWeather.wind      := ReadConfigInteger(gConfFile, 'WEATHER', 'wsd'    , 0);
    mOutWeather.sky       := ReadConfigInteger(gConfFile, 'WEATHER', 'sky'    , 0);
    mOutWeather.pty       := ReadConfigInteger(gConfFile, 'WEATHER', 'pty'    , 0);
    result := true;
  end;
end;

{
function TfrmMain.getWeatherInfo(): Boolean;
var
  jData: TJSONData;
  aStrLst: TStringList;
begin
  aStrLst := TStringList.Create();
  try
    if FileExists(gDataDir+'weather.json') then begin
      try
        aStrLst.LoadFromFile(gDataDir+'weather.json');
        jData := GetJson(aStrlst.Text);
        { Update check }
        if (mOutWeather.timestamp <> TJSONObject(jData).Get('timestamp')) then
        begin
           mOutWeather.temp      := strTofloat(TJSONObject(jData).Get('temp'));
           mOutWeather.humi      := strToInt  (TJSONObject(jData).Get('humi'));
           mOutWeather.wind      := strTofloat(TJSONObject(jData).Get('wind'));
           mOutWeather.angle     := strToInt  (TJSONObject(jData).Get('angle'));
           mOutWeather.rain      := strTofloat(TJSONObject(jData).Get('rain'));
           mOutWeather.sky       := strToInt  (TJSONObject(jData).Get('sky'));
           mOutWeather.pty       := strToInt  (TJSONObject(jData).Get('pty'));

           mOutWeather.timestamp := TJSONObject(jData).Get('lastupdt');
           mOutWeather.lastupdt  := ScanDateTime('YYYYMMDDhhnnss', mOutWeather.timestamp);
        end;

        if mOutWeather.temp < -50 then begin
           result := false;
        end
        else if SecondsBetween(now(), mOutWeather.lastUpDt) > 60*60*5 then begin
          result := false;
        end
        else begin
          result := true;
        end;
      except
          result := false;
      end;
    end
    else begin
      result := false;
    end;
  finally
    FreeAndNil(aStrLst);
  end;
end;
}


procedure TfrmMain.setStatus(stat: Boolean);
begin
  if stat then begin
     mShutDownCount := 0;
     btnSensorSearch.Visible:=false;
     lbCurrTemp.Caption := format('%2.1f', [mSensors.temperature]);
     lbSoilmoisture.Caption := intToStr(mSensors.moisture);
     if mSensors.conductivity = 0 then
        mSensors.conductivity := 1;
     lbSoilfertility.Caption := format('%.2f', [mSensors.conductivity/1000]);
     lbLight.Caption := intToStr(mSensors.light);
     lbBattryRate.Caption := intToStr(mSensors.battery) + '%';
     if mSensors.battery > 80 then begin
       if FileExists(gImageDir + 'battery_full.png') then
          imgBattry.Picture.LoadFromFile(gImageDir + 'battery_full.png');
     end
     else if mSensors.battery > 30 then begin
       if FileExists(gImageDir + 'battery_half.png') then
          imgBattry.Picture.LoadFromFile(gImageDir + 'battery_half.png');
     end
     else begin
       if FileExists(gImageDir + 'battery_low.png') then
          imgBattry.Picture.LoadFromFile(gImageDir + 'battery_low.png');
     end;
     lbhighlow.Caption := format('최고 %d   최저 %d', [round(mDayHighest), trunc(mDayLowest)]);
  end
  else begin
    inc(mShutDownCount);
    if mShutDownCount > 30 then begin
       //ProcessStart(format('./shutdown.sh %d &', [mSensorType]));
       //close();
    end;
    lbCurrTemp.Caption := '-';
    lbSoilmoisture.Caption := '-';
    lbSoilfertility.Caption := '-';
    lbLight.Caption := '-';
    lbBattryRate.Caption := '-';
    btnSensorSearch.Visible:=true;
    if FileExists(gImageDir + 'battery_low.png') then
      imgBattry.Picture.LoadFromFile(gImageDir + 'battery_low.png');
    lbhighlow.Caption := '최고 -   최저 -';
  end;
end;

function TfrmMain.getAutoToOpen: Integer;
begin
  result := MOTER_STOP;
  if (gHour < 6) or (gHour > 18) then begin
      lbCustomName.Caption := '작물종류(야간)';
      lbTemploHi.Caption := format('%d ~ %d', [mAutoPlant.night_downto, mAutoPlant.night_upto]);
      {night}
      if mAutoPlant.night_downto > mSensors.temperature then begin
          {close}
          result := MOTER_CLOSE;
      end
      else if mAutoPlant.night_upto < mSensors.temperature then begin
          {open}
          result := MOTER_OPEN;
      end;

      if mAutoPlant.night_limit > mSensors.temperature then begin
          {alarm}
          mAlarm := ERROR_LOW_TEMPER;
          mAlarmMent := format('Temperature Too Low (%.2f)', [mSensors.temperature]);
          SaveTraceToLogFile2(gLogDir, 'mclog',
              format('[Auto] %s', [mAlarmMent]));
          if FileExists(gImageDir + 'ice.png') then
             imgLimit.Picture.LoadFromFile(gImageDir + 'ice.png');
      end
      else begin
          mAlarm := ERROR_NORMAL;
          mAlarmMent := '';
      end;
  end
  else begin
      lbCustomName.Caption := '작물종류(주간)';
      lbTemploHi.Caption := format('%d ~ %d', [mAutoPlant.day_downto, mAutoPlant.day_upto]);
      {day}
      if mAutoPlant.day_downto > mSensors.temperature then begin
          {close}
          result := MOTER_CLOSE;
      end
      else if mAutoPlant.day_upto < mSensors.temperature then begin
          {open}
          result := MOTER_OPEN;
      end;

      if mAutoPlant.day_limit < mSensors.temperature then begin
          {alarm}
          mAlarm := ERROR_HI_TEMPER;
          mAlarmMent := format('Temperature Too High (%.2f)', [mSensors.temperature]);
          SaveTraceToLogFile2(gLogDir, 'mclog',
              format('[Auto] %s', [mAlarmMent]));
          if FileExists(gImageDir + 'fire.png') then
             imgLimit.Picture.LoadFromFile(gImageDir + 'fire.png');
      end
      else begin
          mAlarm := ERROR_NORMAL;
          mAlarmMent := '';
      end;
  end;
end;

procedure TfrmMain.saveAlarm();
begin
  if mAlarm > 0 then begin
    if mLastAlarm <> mAlarm then begin
      mLastAlarm := mAlarm;
      WriteConfigInteger(gStatFile, 'CONTROL', 'alarm', 1);
      WriteConfigInteger(gConfFile, 'AGENT'  , 'alarm', mAlarm);
      WriteConfigString (gConfFile, 'AGENT'  , 'alarmment', mAlarmMent);
      SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:alarm)', [gStatFile]));
    end;
  end
  else begin
    if mLastAlarm <> mAlarm then begin
      mLastAlarm := mAlarm;
      WriteConfigInteger(gStatFile, 'CONTROL', 'alarm', 0);
      WriteConfigInteger(gConfFile, 'AGENT'  , 'alarm', mAlarm);
      WriteConfigString (gConfFile, 'AGENT'  , 'alarmment', mAlarmMent);
      //SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (CONTROL:n)', [gStatFile]));
    end;
  end;
end;

procedure TfrmMain.setCap(OC: Integer);
begin
  case OC of
    MOTER_OPEN: begin
        lbCap.Caption := '열림';
        if FileExists(gImageDir + 'bullet_green.png') then
            imgCap.Picture.LoadFromFile(gImageDir + 'bullet_green.png');
    end;
    MOTER_CLOSE: begin
        lbCap.Caption := '닫힘';
        if FileExists(gImageDir + 'bullet_red.png') then
            imgCap.Picture.LoadFromFile(gImageDir + 'bullet_red.png');
    end;
    MOTER_STOP: begin
        lbCap.Caption := '멈춤';
    end;
  end;
end;

procedure TfrmMain.setAutoCap(TF: Boolean);
begin
  if TF then begin
    lbTempUptoCap.Visible:= true;
    lbTemploHi.Visible:= true;
  end
  else begin
    lbTempUptoCap.Visible:= false;
    lbTemploHi.Visible:= false;
  end;
end;

function TfrmMain.whoAmI():String;
begin
  result := ReadConfigString(gConfFile, 'AGENT', 'id', '0000');
end;

function TfrmMain.getJsonValueStr(jData: TJSONData; section: String; def: String): String;
begin
  try
    result := TJSONObject(section).Get(section);
  except
    result := def;
  end;
end;

function TfrmMain.getJsonValueInt(jData: TJSONData; section: String;
  def: Integer): Integer;
begin
  try
    result := TJSONObject(section).Get(section);
  except
    result := def;
  end;
end;

function TfrmMain.getJsonStrValue(strData: String; section: String; def: String
  ): String;
var
  jData: TJSONData;
begin
  try
    jData  := GetJson(strData);
    result := TJSONObject(jData).Get(section);
  except
    result := def;
  end;
end;

procedure TfrmMain.showRemoteControlMode();
begin
  //pnlRemoteControl.top := 70;
  pnlRemoteControl.Visible:= true;
  tmControl.Enabled:= false;
  tmModCheck.Enabled:= false;
  mHouseMode := HOUSE_REMOTE;
  mAlarm := ERROR_REMOTE;

  frmMain.Show();
  {
  frmMain.Visible := true;
  frmManual.Visible := false;
  frmTemper.unShow();
  frmTime.unShow();
  frmAuto.unShow();
  frmGraph.Visible := false;
  }
  saveAlarm();
end;

end.

