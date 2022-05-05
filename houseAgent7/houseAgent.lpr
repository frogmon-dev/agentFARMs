program houseAgent;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, indylaz, runtimetypeinfocontrols, tachartlazaruspkg, uHouseAgent,
  uManual, uTemper, uTime, uAuto, uKeyPad, uSensor, uSetTime, uGraph, csvBase,
  uProductLogin
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmSetTime, frmSetTime);
  Application.CreateForm(TfrmKeyPad, frmKeyPad);
  Application.CreateForm(TfrmManual, frmManual);
  Application.CreateForm(TfrmTemper, frmTemper);
  Application.CreateForm(TfrmTime, frmTime);
  Application.CreateForm(TfrmAuto, frmAuto);
  Application.CreateForm(TfrmSensor, frmSensor);
  Application.CreateForm(TfrmGraph, frmGraph);
  Application.CreateForm(TfrmProductLogin, frmProductLogin);
  Application.Run;
end.

