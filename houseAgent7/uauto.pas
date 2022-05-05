unit uAuto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  StdCtrls
  { COMMON }
  , ucommon
  , uglobal
  { User ADD }
  , jsonparser
  , fpjson;

type

  { TfrmAuto }

  TfrmAuto = class(TForm)
    cbWeatherChk: TCheckBox;
    Image1: TImage;
    Label3: TLabel;
    Label8: TLabel;
    lbPlantName: TLabel;
    Panel1: TPanel;
    pnlSelectPlant: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    tmClear: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure GetCtrlName(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure tmClearTimer(Sender: TObject);
  private
    clearCnt: Integer;
    function saveSetting: Boolean;
  public
    procedure unShow();
    function getPlantInfoByName(PlantNM: String): TAutoPlant;
  end;

var
  frmAuto: TfrmAuto;

implementation

{$R *.lfm}

uses
  uHouseAgent;

{ TfrmAuto }

procedure TfrmAuto.Button1Click(Sender: TObject);
begin

end;

procedure TfrmAuto.FormCreate(Sender: TObject);
var
  Count1 :integer = 0;
  i, j: Integer;
  jData: TJSONData;
//  jItem: TJSONData;
  aStrLst: TStringList;
  xs, ys: Integer;
begin
  left := 0;
  top := 0;
  pnlSelectPlant.Left:= 15;
  pnlSelectPlant.Top := 70;
  xs := 2;
  ys := 3;

  clearCnt := 0;

  aStrLst := TStringList.Create();
  if FileExists(gDataDir+'plant.json') then begin
      aStrLst.LoadFromFile(gDataDir+'plant.json');
      jData := GetJson(aStrlst.Text);
      if jData.Count <= 12 then begin
        xs := 2;
        ys := 3;
      end
      else if jData.Count <= 20 then begin
        xs := 3;
        ys := 4;
      end
      else if jData.Count <= 30 then begin
        xs := 4;
        ys := 5;
      end;

      for i := 0 to xs do begin
        for j := 0 to ys do begin
          // 버튼을 동적으로 생성①
          //jItem := jData.Items[Count1];
          if jData.Count <= Count1 then
            break;
          with TButton.Create(Self) do begin
            Parent := pnlSelectPlant;
            Height := round(pnlSelectPlant.Height / (xs+1))-1;
            Width := round(pnlSelectPlant.Width / (ys+1))-1;
            Left := j * Width;
            Top := i * Height;
            Name := Format('D1Button%d',[Count1]);
            Caption := TJSONObject(jData).Names[Count1];
            OnClick := @GetCtrlName;
            font.size := 20;
          end;
          Count1 := Count1 + 1;
        end;
      end;

      FreeAndNil(aStrLst);
  end;
end;

procedure TfrmAuto.FormShow(Sender: TObject);
begin
    tmClear.Enabled:= true;
    clearCnt := 0;
    lbPlantName.Caption := ReadConfigString(gConfFile, 'AUTO', 'name', '');
    if ReadConfigInteger(gConfFile, 'WEATHER', 'use', 0) = 1 then
      cbWeatherChk.checked := true
    else
      cbWeatherChk.checked := false;
end;

procedure TfrmAuto.SpeedButton1Click(Sender: TObject);
begin
  clearCnt := 0;
  pnlSelectPlant.Visible:= true;
end;

// 동적으로 만들어진 컨트롤을 클릭했을 때 실행
procedure TfrmAuto.GetCtrlName(Sender: TObject);
begin
  lbPlantName.Caption  := (Sender as TButton).Caption;
  pnlSelectPlant.Visible:= false;
end;

procedure TfrmAuto.SpeedButton3Click(Sender: TObject);
begin
  if saveSetting then begin
      with frmmain do begin
        if Length(mAutoPlant.plantNM) > 12 then begin
            lbCustomValue.Font.Size := 25;
        end
        else begin
            lbCustomValue.Font.Size := 46;
        end;
        frmMain.mWeatherUse := cbWeatherChk.Checked;
        lbCustomValue.Caption := mAutoPlant.plantNM;
      end;
    //frmMain.Visible:= true;
    frmMain.Show();
    tmClear.Enabled:= false;
    Visible := false;
  end;
end;

procedure TfrmAuto.tmClearTimer(Sender: TObject);
begin
  clearCnt := clearCnt + 1;
    if clearCnt > 30 then begin
      if saveSetting then begin
        //frmMain.Visible:= true;
        frmMain.Show();
        tmClear.Enabled:= false;
        Visible := false;
      end;
    end;
end;

function TfrmAuto.saveSetting: Boolean;
begin
  result := false;
  try
    with frmMain do begin
      mAutoPlant := getPlantInfoByName(lbPlantName.Caption);
      WriteConfigString (gConfFile, 'AUTO', 'name'          , lbPlantName.Caption);
      {
      WriteConfigInteger(gConfFile, 'AUTO', 'day_upto'      , mAutoPlant.day_upto);
      WriteConfigInteger(gConfFile, 'AUTO', 'day_downto'    , mAutoPlant.day_downto);
      WriteConfigInteger(gConfFile, 'AUTO', 'day_limit'     , mAutoPlant.day_limit);
      WriteConfigInteger(gConfFile, 'AUTO', 'night_upto'    , mAutoPlant.night_upto);
      WriteConfigInteger(gConfFile, 'AUTO', 'night_downto'  , mAutoPlant.night_downto);
      WriteConfigInteger(gConfFile, 'AUTO', 'night_limit'   , mAutoPlant.night_limit);
      WriteConfigInteger(gConfFile, 'AUTO', 'land_upto'     , mAutoPlant.land_upto);
      WriteConfigInteger(gConfFile, 'AUTO', 'land_downto'   , mAutoPlant.land_downto);
      WriteConfigInteger(gConfFile, 'AUTO', 'land_uplimit'  , mAutoPlant.land_uplimit);
      WriteConfigInteger(gConfFile, 'AUTO', 'land_downlimit', mAutoPlant.land_downlimit);
      }
    end;
    if cbWeatherChk.Checked then
      WriteConfigString(gConfFile, 'WEATHER', 'use', '1')
    else
      WriteConfigString(gConfFile, 'WEATHER', 'use', '0');


    SaveTraceToLogFile2(gLogDir, 'mclog', format('%s ini file write (SETUP:n)', [gConfFile]));
    SaveTraceToLogFile2(gLogDir, 'syslog', format('[AutoMod] SET Plant %s', [lbPlantName.Caption]));
    result := true;
  except
    //todo Log
  end;
end;

procedure TfrmAuto.unShow();
begin
  tmClear.Enabled:= false;
  Visible := false;
end;

function TfrmAuto.getPlantInfoByName(PlantNM: String): TAutoPlant;
var
  jData: TJSONData;
  jItem: TJSONData;
  jItemChild: TJSONData;
  i: Integer;
  aStrLst: TStringList;
begin
  result.plantNM := '';
  aStrLst := TStringList.Create();
  try
  if FileExists(gDataDir+'plant.json') then begin
    aStrLst.LoadFromFile(gDataDir+'plant.json');
    jData := GetJson(aStrlst.Text);
    for i := 0 to jData.Count -1 do begin
        jItem := jData.Items[i];
        if PlantNM = TJSONObject(jData).Names[i] then begin
          result.plantNM := PlantNM;
          jItemChild := TJSONObject(jItem).Find('day');
          result.day_limit  := TJSONObject(jItemChild).Get('highlimit');
          result.day_upto   := TJSONObject(jItemChild).Get('upto');
          result.day_downto := TJSONObject(jItemChild).Get('downto');

          jItemChild := TJSONObject(jItem).Find('night');
          result.night_limit  := TJSONObject(jItemChild).Get('lowlimit');
          result.night_upto   := TJSONObject(jItemChild).Get('upto');
          result.night_downto := TJSONObject(jItemChild).Get('downto');

          jItemChild := TJSONObject(jItem).Find('land');
          result.land_uplimit   := TJSONObject(jItemChild).Get('highlimit');
          result.land_downlimit := TJSONObject(jItemChild).Get('lowlimit');
          result.land_upto      := TJSONObject(jItemChild).Get('upto');
          result.land_downto    := TJSONObject(jItemChild).Get('downto');
          Break;
        end;
    end;
  end;
  finally
    FreeAndNil(aStrLst);
  end;
end;

end.

