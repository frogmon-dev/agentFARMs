unit uProductLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, IdHTTP
      { COMMON }
  , ucommon
  , uglobal
  , DOM
  , xmlread
  , XMLWrite               // XML
  ;

type

  { TfrmProductLogin }

  TfrmProductLogin = class(TForm)
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function avoidWordCrash(idHttp: TidHttp; url: String): String;
    function xml_proc(strXml: String): Boolean;

  public
    function doLogin(): Boolean;
  end;

var
  frmProductLogin: TfrmProductLogin;

implementation

uses
  uHouseAgent;
{$R *.lfm}

{ TfrmProductLogin }

procedure TfrmProductLogin.FormShow(Sender: TObject);
begin

end;

procedure TfrmProductLogin.Button1Click(Sender: TObject);
begin
  frmMain.close();
end;

function TfrmProductLogin.xml_proc(strXml: String): Boolean;
var
  doc: TXMLDocument;
  ChannelNode, ItemNode:  TDOMNode;
  msgs: String;
  msgCode: Integer;
  S : TStringStream;
begin
  result := false;

  doc := TXMLDocument.Create;
  S:= TStringStream.Create(strXml);
  try
    ReadXMLFile(doc, S);

    { HEADER 채크 }
    ChannelNode := doc.DocumentElement.FindNode('msgHeader');

    ItemNode := ChannelNode.FindNode('headerCd');
    if ItemNode = nil then begin
      SaveTraceToLogFile2(gLogDir, 'syslog',
              'product login Error');
      exit;
    end;

    msgCode := strToInt(AnsiString(ItemNode.FirstChild.NodeValue));

    ItemNode := ChannelNode.FindNode('headerMsg');
    msgs := AnsiString(ItemNode.FirstChild.NodeValue);

    if msgCode <> 0 then begin
      SaveTraceToLogFile2(gLogDir, 'syslog',
              format('product login Error Code [%d]:%s', [msgCode, msgs]));
      exit;
    end
    else begin
      result := true;
    end;
  finally
    freeAndNil(S);
    freeAndNil(doc);
  end;

end;


// -------------------------------------------------------------
/// @fn     avoidWordCrash
/// @brif   한글깨짐 보완
/// @auther frogmon
/// @parm   http객체, url주소
/// @return XML String
// -------------------------------------------------------------
function TfrmProductLogin.avoidWordCrash(idHttp: TidHttp; url: String): String;
var
  MemoryStream: TBytesStream;
begin
  MemoryStream := TBytesStream.Create;
  result := '';
  try
    idHttp.Get(url, MemoryStream);
    if assigned(MemoryStream) then begin
       result := TEncoding.UTF8.GetString(MemoryStream.Bytes, 0, MemoryStream.Size);
    end
  finally
    MemoryStream.Free;
  end;
end;

function TfrmProductLogin.doLogin(): Boolean;
var
  url: String;
  user_id: String;
  product_id: String;
  mac_address: String;
  http : TIdHTTP;
  mXml: String;

begin
  result := false;
  user_id     := ReadConfigString(gConfFile, 'SETUP', 'user_id', '-');
  product_id  := ReadConfigString(gConfFile, 'AGENT', 'id', '-');
  mac_address := getMacAddr();

  url := format('http://frogmon.synology.me/svr_api/product_login.php?user_id=%s&product_id=%s&mac_address=%s', [user_id, product_id, mac_address]);

  http := TIdHTTP.Create;
  http.readTimeout := 5000;
  try
    try
      mXml := avoidWordCrash(http, url);
      result := xml_proc(mXml);
    except
      on E: Exception do
      begin
        SaveTraceToLogFile2(gLogDir, 'syslog',
            format('[ERROR] %s', [e.Message]));
      end;
    end;
    http.Disconnect;
    FreeAndNil(http);
  finally

  end;
end;

end.

