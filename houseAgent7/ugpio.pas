unit uGpio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,
  { User Add }
  math,
  LCLType,
  IntfGraphics,
  fpImage,
  { User Custom }
  ucommon,
  uglobal,
  uLedScreen,
  uBitoper,
  GPIOInterface;

type
  {TGpioThread}
  TGpioThread = class(TThread)
    private
      procedure printLED;
    protected
       procedure Execute; override;
    public
       scr_x, scr_y: Integer;
  end;

  { TfrmGPIO }
  TfrmGPIO = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FGpioInterface: TGpioInterface;

  public
    { GPIO CONTROL }
    procedure resetGPIO;
    function  sendCK: Integer;
    function  sendLT(level: Boolean): Integer;
    function  sendOE(level: Boolean): Integer;
    function  sendA0(level: Boolean): Integer;
    function  sendA1(level: Boolean): Integer;
    function  sendA2(level: Boolean): Integer;
    function  sendA3(level: Boolean): Integer;
  end;

var
  frmGPIO: TfrmGPIO;

implementation

{$R *.lfm}

{ TGpioThread }

procedure TGpioThread.printLED;
var
  i: Integer;
  stat: Integer;
begin
  frmGPIO.resetGPIO;
  stat := 0;

  while (stat < 16) do begin
    for i := 0 to 96 - 1 do begin
        frmGPIO.sendCK;
    end;

    frmGPIO.sendOE(true);
    frmGPIO.sendLT(true);

    inc(stat);
    frmGPIO.sendA0(dec2binN(stat, 0));
    frmGPIO.sendA1(dec2binN(stat, 1));
    frmGPIO.sendA2(dec2binN(stat, 2));
    frmGPIO.sendA3(dec2binN(stat, 3));

    frmGPIO.sendLT(false);
    frmGPIO.sendOE(false);
  end;
end;

procedure TGpioThread.Execute;
begin
  Synchronize(@printLED);
end;

{ TfrmGPIO }

procedure TfrmGPIO.Button1Click(Sender: TObject);
var
  GPIOthr: TGpioThread;
begin
  FGpioInterface := TGpioInterface.Create;
  GPIOthr := TGpioThread.Create(True);
  GPIOthr.scr_x:= 124;
  GPIOthr.scr_y:= 48;
  GPIOthr.Start;
end;

procedure TfrmGPIO.FormCreate(Sender: TObject);
begin
 // FGpioInterface := TGpioInterface.Create;
end;

procedure TfrmGPIO.resetGPIO;
begin
  FGpioInterface.ResetGPIO;
end;


function TfrmGPIO.sendCK: Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_CK] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_CK,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_CK,FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_CK] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_CK,true);
         FGpioInterface.Output(GPIO_CK,false);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_CK]));
  end;
end;

function TfrmGPIO.sendLT(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_LT] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_LT,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_LT,FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_LT] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_LT,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_LT]));
  end;
end;

function TfrmGPIO.sendOE(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_OE] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_OE,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_OE, FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_OE] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_OE,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_OE]));
  end;
end;

function TfrmGPIO.sendA0(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_A0] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_A0,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_A0, FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_A0] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_A0,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_A0]));
  end;
end;

function TfrmGPIO.sendA1(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_A1] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_A1,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_A1, FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_A1] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_A1,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_A1]));
  end;
end;

function TfrmGPIO.sendA2(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_A2] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_A2,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_A2, FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_A2] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_A2,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_A0]));
  end;
end;

function TfrmGPIO.sendA3(level: Boolean): Integer;
begin
  result := -1;
  if FGpioInterface.GpioStatus[GPIO_A3] = ioUnset then
  begin
     FGpioInterface.Setup(GPIO_A3,ioOutput);
     frmMain.Log_Proc(format('GPIO%d not in output mode, set to ouput mode: %d',[GPIO_A3, FGpioInterface.ReturnCode]));
  end;
  if FGpioInterface.GpioStatus[GPIO_A3] = ioOutput then
  begin
         FGpioInterface.Output(GPIO_A3,level);
         result := 0;
  end
  else
  begin
     frmMain.Log_Proc(format('Turn GPIO%d High abosted',[GPIO_A3]));
  end;
end;

end.

