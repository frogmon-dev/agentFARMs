unit uKeyPad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmKeyPad }

  TfrmKeyPad = class(TForm)
    btn1: TButton;
    btn0: TButton;
    btnBackSpace: TButton;
    btnClear: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    edNumber: TEdit;
    ToggleBox1: TToggleBox;
    procedure btn0Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btnBackSpaceClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private

  public
    targetEdit: TEdit;
    procedure inputText(edt: TEdit; reset: boolean);

  end;

var
  frmKeyPad: TfrmKeyPad;

implementation

{$R *.lfm}

{ TfrmKeyPad }

procedure TfrmKeyPad.FormCreate(Sender: TObject);
begin
  top := 10;
  left := 100;
end;

procedure TfrmKeyPad.ToggleBox1Change(Sender: TObject);
begin
  targetEdit.Text := edNumber.Text;
  close;
end;

procedure TfrmKeyPad.inputText(edt: TEdit; reset: boolean);
begin
  targetEdit := edt;
  edNumber.Text := edt.Text;
  if reset then begin
     edNumber.Caption := '';
  end;
end;

procedure TfrmKeyPad.btn1Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '1';
end;

procedure TfrmKeyPad.btn0Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '0';
end;

procedure TfrmKeyPad.btn2Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '2';
end;

procedure TfrmKeyPad.btn3Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '3';
end;

procedure TfrmKeyPad.btn4Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '4';
end;

procedure TfrmKeyPad.btn5Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '5';
end;

procedure TfrmKeyPad.btn6Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '6';
end;

procedure TfrmKeyPad.btn7Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '7';
end;

procedure TfrmKeyPad.btn8Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '8';
end;

procedure TfrmKeyPad.btn9Click(Sender: TObject);
begin
  edNumber.Text := edNumber.Text + '9';
end;

procedure TfrmKeyPad.btnBackSpaceClick(Sender: TObject);
begin
  edNumber.Text := copy(edNumber.Text, 0, length(edNumber.Text)-1);
end;

procedure TfrmKeyPad.btnClearClick(Sender: TObject);
begin
  edNumber.Text := '';
end;

end.

