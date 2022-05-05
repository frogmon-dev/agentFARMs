unit uGraph;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ExtDlgs, jvCSVBase
  { COMMON }
  , ucommon
  , uglobal
  { USER }
  { USER ADD }
  , DateUtils, TAChartAxisUtils;

type

  { TfrmGraph }

  TfrmGraph = class(TForm)
    baseCSV: TjvCSVBase;
    cdDate: TCalendarDialog;
    ctAgent1: TChart;
    ctAgent1_CDS: TLineSeries;
    ctAgent1_humi: TLineSeries;
    ctAgent1_outTemp: TLineSeries;
    ctAgent1_temp: TLineSeries;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label8: TLabel;
    lbCSVhumi: TjvCSVLabel;
    lbCSVlight: TjvCSVLabel;
    lbCSVoutTemp: TjvCSVLabel;
    lbCSVtemp: TjvCSVLabel;
    lbCSVTime: TjvCSVLabel;
    lbHistoryDate: TLabel;
    sbHumi: TSpeedButton;
    sbLight: TSpeedButton;
    sbTemp: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    tmGraphUpdate: TTimer;
    procedure cdDateCanClose(Sender: TObject; var CanClose: boolean);
    procedure cdDateChange(Sender: TObject);
    procedure cdDateClose(Sender: TObject);
    procedure ctAgent1AxisList1MarkToText(var AText: String; AMark: Double);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbHumiClick(Sender: TObject);
    procedure sbLightClick(Sender: TObject);
    procedure sbTempClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure tmGraphUpdateTimer(Sender: TObject);
  private
    mOnChange : boolean;
    procedure resetGraph();
    procedure showGrahp(strDate: String);

  public
    graphDate: String;

  end;

var
  frmGraph: TfrmGraph;

implementation

{$R *.lfm}
uses
  uHouseAgent;

procedure TfrmGraph.sbTempClick(Sender: TObject);
begin
  ctAgent1_temp.Active:= true;
  ctAgent1_outTemp.Active:= true;
  ctAgent1_humi.Active:= false;
  ctAgent1_CDS.Active:= false;

  sbTemp.Flat:= true;
  sbHumi.Flat:= false;
  sbLight.Flat:= false;
  ctAgent1.LeftAxis.Title.Caption := '°C';
  ctAgent1.LeftAxis.Range.Max := 40;
  ctAgent1.LeftAxis.Range.Min := 0;
  RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.SpeedButton2Click(Sender: TObject);
begin
  resetGraph();
  RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.SpeedButton3Click(Sender: TObject);
var
  aDate: TDateTime;
begin
    aDate := ScanDateTime('yyyymmdd', graphDate) - 1;
    lbHistoryDate.Caption := FormatDateTime('m월 d일', aDate);
    graphDate := FormatDateTime('yyyymmdd', aDate);
    showGrahp(graphDate);
    RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.SpeedButton4Click(Sender: TObject);
begin
  tmGraphUpdate.Enabled:=false;
  frmMain.Visible:=true;
  Visible:=false;
end;


procedure TfrmGraph.SpeedButton5Click(Sender: TObject);
var
  aDate: TDateTime;
begin
    aDate := ScanDateTime('yyyymmdd', graphDate) + 1;
    lbHistoryDate.Caption := FormatDateTime('m월 d일', aDate);
    graphDate := FormatDateTime('yyyymmdd', aDate);
    showGrahp(graphDate);
    RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.SpeedButton6Click(Sender: TObject);
var
  aDate: TDateTime;
begin
  if cdDate.Execute then
  begin
    aDate := cdDate.Date;
    lbHistoryDate.Caption := FormatDateTime('m월 d일', aDate);
    graphDate := FormatDateTime('yyyymmdd', aDate);
    showGrahp(graphDate);
    RestartTimer(tmGraphUpdate);
  end;
end;

procedure TfrmGraph.tmGraphUpdateTimer(Sender: TObject);
begin
  frmMain.Visible:=true;
  Visible:=false;
  tmGraphUpdate.Enabled:=false;
end;

procedure TfrmGraph.sbHumiClick(Sender: TObject);
begin
    ctAgent1_temp.Active:= false;
    ctAgent1_outTemp.Active:= false;
    ctAgent1_humi.Active:= true;
    ctAgent1_CDS.Active:= false;

    sbTemp.Flat:= false;
    sbHumi.Flat:= true;
    sbLight.Flat:= false;
    ctAgent1.LeftAxis.Title.Caption := '%';
    ctAgent1.LeftAxis.Range.Max := 100;
    ctAgent1.LeftAxis.Range.Min := 0;
    RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.FormShow(Sender: TObject);
begin
    mOnChange := false;
    tmGraphUpdate.Enabled:=true;
    resetGraph();
    sbTemp.Click();
end;

procedure TfrmGraph.FormCreate(Sender: TObject);
begin

end;

procedure TfrmGraph.ctAgent1AxisList1MarkToText(var AText: String; AMark: Double
  );
var
  aNumber: Integer;
  aMin: Integer;
  aHour: Integer;
  strtrim: String;
begin
  strtrim := Trim(AText);
  if not IsDigit(strtrim) then
     exit();
  aNumber := strToInt(strtrim);
  aHour := aNumber div 60;
  aMin  := aNumber mod 60;
  AText := format('%.2d:%.2d', [aHour, aMin]);
end;

procedure TfrmGraph.cdDateClose(Sender: TObject);
begin
end;

procedure TfrmGraph.cdDateCanClose(Sender: TObject; var CanClose: boolean);
begin
end;

procedure TfrmGraph.cdDateChange(Sender: TObject);
begin
end;

procedure TfrmGraph.sbLightClick(Sender: TObject);
begin
    ctAgent1_temp.Active:= false;
    ctAgent1_outTemp.Active:= false;
    ctAgent1_humi.Active:= false;
    ctAgent1_CDS.Active:= true;

    sbTemp.Flat:= false;
    sbHumi.Flat:= false;
    sbLight.Flat:= true;
    ctAgent1.LeftAxis.Title.Caption := 'Cds';
    ctAgent1.LeftAxis.Range.Max := 800;
    ctAgent1.LeftAxis.Range.Min := 0;
    RestartTimer(tmGraphUpdate);
end;

procedure TfrmGraph.resetGraph();
begin
  graphDate := gStrDate;
  lbHistoryDate.Caption := gStrKrDate;
  showGrahp(graphDate);
end;

function timeToCount(strTime: String): Integer;
var
  aTime: TDateTime;
begin
  aTime := ScanDateTime('hh:nn:ss', strTime);
  result := FormatDateTime('hh', aTime).ToInteger *60 + FormatDateTime('nn', aTime).ToInteger;
end;

procedure TfrmGraph.showGrahp(strDate: String);
var
  fileName: String;
  cnt: Integer;
  iTemp: double;
  aveTemp: double;
  cntTemp: Integer;
  avehumi: double;
  cntHumi: Integer;
  avelight: double;
  cntLight: Integer;
  lstCnt: Integer;
begin
  cnt := 0;
  aveTemp := 0; avehumi := 0; avelight := 0;
  cntTemp := 0; cntHumi := 0; cntLight := 0;
  lstCnt := 0;
  { clear }
  ctAgent1_temp.Clear;
  ctAgent1_outTemp.Clear;
  ctAgent1_humi.Clear;
  ctAgent1_CDS.Clear;
  try
    fileName := gLogDir + format('grp_%s.csv', [strDate]);
    if FileExists(fileName) then begin
        baseCSV.DataBaseOpen(fileName);
        baseCSV.RecordFirst;
        while baseCSV.RecordNext = true do begin
            cnt := timeToCount(lbCSVTime.Caption);
            aveTemp := aveTemp + strToFloat(lbCSVtemp.Caption);
            inc(cntTemp);
            if IsDigit(lbCSVhumi.Caption) then begin
                avehumi := avehumi + strToInt(lbCSVhumi.Caption);
                inc(cntHumi);
            end;
            if IsDigit(lbCSVlight.Caption) then begin
                avelight := avelight + strToInt(lbCSVlight.Caption);
                inc(cntLight);
            end;
            { 5 minute averave data drow to Graph }
            if ((cnt mod 5) = 0) and (lstCnt <> cnt) then begin
                lstCnt := cnt;
                ctAgent1_temp.AddXY(cnt, aveTemp/cntTemp, lbCSVTime.Caption, clRed);
                if (lbCSVoutTemp.Caption = '') or (lbCSVoutTemp.Caption = '-') then begin
                    iTemp := 0;
                end
                else begin
                    iTemp := strtoFloat(lbCSVoutTemp.Caption);
                end;
                ctAgent1_outTemp.AddXY(cnt, iTemp, lbCSVoutTemp.Caption, clAqua);
                ctAgent1_humi.AddXY(cnt, avehumi/cntHumi, lbCSVhumi.Caption, clAqua);
                ctAgent1_CDS.AddXY(cnt, avelight/cntLight, lbCSVlight.Caption, clAqua);
                aveTemp := 0; cntTemp := 0;
                avehumi := 0; cntHumi := 0;
                avelight := 0; cntLight := 0;
            end;
        end;
    end;
  except
    on e: exception do begin
        SaveTraceToLogFile2(gLogDir, 'syslog', format('Error: %s', [e.Message]));
    end;
  end;
end;

end.

