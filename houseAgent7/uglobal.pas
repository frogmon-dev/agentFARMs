unit uglobal;


{$mode objfpc}{$H+}

interface

uses
    Classes
  , SysUtils
  , IniFiles
  , syncobjs
  , DateUtils
  , math
  , Graphics
  , Process
  , ExtCtrls
  , fphttpclient
  , RegexPr
  {$IFDEF WINDOWS}
   , ShellApi
  {$ELSE}
  {$ENDIF}
//  , TlHelp32
  { User Add }
  , ucommon
    ;


procedure WriteConfigString(fName,Section,Item, val: String);
procedure WriteConfigInteger(fName,Section,Item: String; Val:Integer);
procedure CleanConfigFile(fileName: String);
procedure SaveTraceToLogFile(APath, AFileName, ALogData: String);
procedure SaveTraceToLogFile2(APath, AFileName, ALogData: String);
procedure BusDataToCSVLog(APath, AFileName, bus_data: String);
procedure SavePrMsgToFile(APath, AFileName, Messages: String);
procedure Make_Dir(Dir: String);
procedure Canvas_Fill(dCanvas:TCanvas; clr:TColor; x1, y1, x2, y2:Integer);

function  ReadConfigString(fName,Section,Item:String; Def:String):String;
function  ReadConfigInteger(fName,Section,Item:String; Def:Integer):Integer;
procedure DeleteSection(fName,Section:String);
function  ReadWithoutSectionString(fName, Item: String; Def:String):String;
function  ReadWithoutSectionInteger(fName, Item: String; Def:Integer):Integer;
function  IsDigit(AString:String):Boolean;
function  getEasyDate(fullStrDate: String): String;
function  getDateTime(date:String): TDateTime;
function  getTimeDiff(fromDt, toDt: TDateTime): integer;
function  getSecToMin(leften, sec: Integer): Integer;
function  ifDefWideStrToInt(source: WideString; def: Integer): Integer;
function  ifDefWideStrToDate(source: WideString; def: TDateTime): TDateTime;
function  ifDefWideStrToString(source: WideString; def: String): String;
function  IsPurposeDirBus(dir_type: Byte): Boolean;
function  getNSort(x, y, pos: Integer): Integer;
function  ReadFileToPChar(fileName: String; fileData: PChar): Boolean;
function  GetFileLength(FileName:String):LongInt;

function dec2bin(Value: Integer): String;
function dec2binN(Value: Integer; loc: Integer): Boolean;
{$IFDEF WINDOWS}
{$ELSE}
function getMacAddr(): String;
{$ENDIF}
//function getStrToDate(DateStr: String): TDateTime;
function  Char2String(data: PChar; size: Integer): String;
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
function  Crc16(data:PChar; count:Integer):Word;
procedure Write_File(file_name: String; file_data: PChar; file_size: Integer);

function getXMLStrDateToDate(DateStr: String): TDateTime;
function CheckVillageBusPos(msg_no: String): Integer;

procedure killProcess(filename: String);
procedure ProcessStart(commands: String);
procedure setDateTime(aYear, aMonth, aDay, aHour, aMin, aSec: Integer);
procedure encodeCP949(fromFileName, toFileName: String);
function getPCMVolume(value: Integer): Integer;
procedure makeVoiceFile(filename: String; LstVoiceData: TStringList);
function  unmungestr(const instr: String): String;
procedure ErrorToCSVLog(APath, AFileName, msg: String);
procedure ToCSVFile(APath, AFileName, headline, msg: String);

function  setWindCase(wind: double): String;
function  chkInterNet(): Boolean;

function  getDayToday(ADate: TDateTime): String;
procedure RestartTimer(Timer: TTimer);
procedure TickTock();

implementation

procedure Write_File(file_name: String; file_data: PChar; file_size: Integer);
var
    FileStream: TFileStream;
begin
    try
        FileStream := TFileStream.Create(file_name, fmOpenWrite or fmCreate);
        try
            FileStream.Write(file_data[0], file_size);
        finally
            FileStream.Free;
        end;
    except
    end;
end;

function Crc16(data:PChar; count:Integer):Word;
var
    i : Integer;
    accum, comb_val : Word;
begin
    accum := 0;
    for i:=0 to count-1 do
    begin
        comb_val := accum xor Integer(data[i]);
        accum := (accum shr 8) xor crc16tbl[comb_val and $00ff];
    end;

    Crc16 := accum;
end;

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
begin
  Move(Source^, Destination^, Length);
end;

function Char2String(data: PChar; size: Integer): String;
var
    btmp  : Byte;
    i     : Integer;
    stmp  : String;
begin
    stmp := '';
    for i:=0 to size-1 do
    begin
        btmp := Ord(data[i]);
        stmp := stmp + ASC[btmp] + ' ';
    end;

    Char2String := stmp;
end;

function getNSort(x, y, pos: Integer): Integer;
var
  base: Integer;
begin
  inc(pos);
  x := x+1;
  base :=  pos mod (x*y);

  if x = 2 then begin
    case y of
      2 : begin
        case base of
          2 : result := 3;
          3 : result := 2;
          else result := base;
        end;
      end;
      3 : begin
        case base of
          2 : result := 4;
          3 : result := 2;
          4 : result := 5;
          5 : result := 3;
          else result := base;
        end;
      end;
      4 : begin
        case base of
          2 : result := 5;
          3 : result := 2;
          4 : result := 6;
          5 : result := 3;
          6 : result := 7;
          7 : result := 4;
          else result := base;
        end;
      end;
      else result := base;
    end;
    result := ((pos div (x*y))*(x*y)) + result;
  end
  else
    result := pos;

  result := result - 1;

end;

function IsPurposeDirBus(dir_type: Byte): Boolean;
begin
    if dir_type = 0 then
        Result := False
    else
        Result := True;
end;

procedure Canvas_Fill(dCanvas:TCanvas; clr:TColor; x1, y1, x2, y2:Integer);
begin
    dCanvas.Brush.Color := clr;
    dCanvas.FillRect(Rect(x1, y1, x2, y2));
end;

function  ReadFileToPChar(fileName: String; fileData: PChar): Boolean;
var
  str: TStringList;
begin
     result := false;
     str := TStringlist.Create;
     try
         if FileExists(fileName) then
         begin
             str.LoadFromFile(fileName);
             StrPCopy(PChar(@fileData[0]), str.Text);
             result := true;
         end;
     finally
         str.free;
     end;
end;

function ifDefWideStrToInt(source: WideString; def: Integer): Integer;
var
   str: String;
begin
    str := String(source);
    try
        if IsDigit(str) then
            result := strToInt(str)
        else
            result := def;
    except
       result := def;
    end;
end;

function ifDefWideStrToDate(source: WideString; def: TDateTime): TDateTime;
var
   str: String;
begin
  str := String(source);
  try
     result := strToDateTime(str);
  except
     result := def;
  end;

end;

function ifDefWideStrToString(source: WideString; def: String): String;
var
   str: String;
begin
  str := String(source);
  try
     result := str;
  except
     result := def;
  end;

end;

function ReadConfigInteger(fName,Section,Item:String; Def:Integer):Integer;
var
   IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(fName);
     try
     Result := IniFile.ReadInteger(Section, Item, Def);
     finally
            IniFile.Free;
     end;
end;

procedure Make_Dir(Dir: String);
var
    sr : TSearchRec;
begin
    if FindFirst(Dir, faDirectory, sr) <> 0 then
        ForceDirectories(Dir);

    FindClose(sr);
end;

procedure CleanConfigFile(fileName: String);
var
  LOF: TStringList;
  i: integer;
begin
  LOF := TStringList.Create;
  try
  LOF.LoadFromFile(fileName);

  for i := LOF.Count - 1 downto 0 do begin
    LOF[i] := trim(LOF[i]);
  end;
  LOF.SaveToFile(fileName);
  finally
    LOF.Free;
  end;
end;

function ReadConfigString(fName, Section, Item: String; Def: String): String;
var
   IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(fName);
     try
     Result := IniFile.ReadString(Section, Item, Def);
     finally
       IniFile.Free;
     end;
end;

procedure DeleteSection(fName, Section: String);
var
   IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(fName);
     try
         if IniFile.SectionExists(Section) then begin
           IniFile.EraseSection(Section);
         end;
     finally
       IniFile.Free;
     end;

end;

function ReadWithoutSectionString(fName, Item: String; Def: String): String;
begin
  result := Def;
  with TStringList.Create do
    try
      LoadFromFile(fName);
      result := Values[Item];
    finally
      Free;
    end;
end;

function ReadWithoutSectionInteger(fName, Item: String; Def: Integer): Integer;
begin
  result := Def;
  with TStringList.Create do
    try
      LoadFromFile(fName);
      result := StrToInt(Values[Item]);
    finally
      Free;
    end;
end;

function IsDigit(AString:String):Boolean;
var
   i: Integer;
begin
     Result := True;
     for i:=1 to Length(AString) do
     begin
          if (AString[i]<'0') or (AString[i]>'9') then
          begin
             Result := false;
             break;
          end;
     end;
end;

function getEasyDate(fullStrDate: String): String;
var
  stList: TStringList;
  dt: Array[0..5] of Word;
  str_date, str_time: String;
  i: Integer;
begin
  // 최초 업데이트 일자 코드화
  result := '';
  stList := TStringList.Create;
  try
    FillChar(dt, SizeOf(dt), 0);
    str_date := Copy(fullStrDate,  1, 10);
    str_time := Copy(fullStrDate, 12, 18);
    ExtractStrings(['-'], [], PChar(str_date), stList);
    ExtractStrings([':'], [], PChar(str_time), stList);
    for i:=0 to stList.Count - 1 do
        if IsDigit(stList[i]) then begin
          dt[i] := StrToInt(stList[i]);
          result := result + stList[i];
        end;
  finally
    freeAndNil(stList);
  end;
end;

procedure SaveTraceToLogFile(APath, AFileName, ALogData: String);
Var
  aHandle : TextFile;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS := TCriticalSection.create;
  Try
    MCS.Acquire;
    AFilePath := APath + 'Tracelog';
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath+'/'+'['+AFileName+']'+formatdatetime('yyyymmdd',Now) + '.txt';

    If FileExists(AFileName) Then
    Begin
      AssignFile(aHandle, AFileName);
      Append(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
    End;

    szTmp := '';
    szTmp := ALogData;
    WriteLn(aHandle, szTmp);

//    szTmp :=   '*------------*--------------*--------------*-------------------*'+timetostr(time())+Char(13);
//    WriteLn(aHandle, szTmp);

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;

procedure SaveTraceToLogFile2(APath, AFileName, ALogData: String);
Var
  aHandle : TextFile;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS := TCriticalSection.create;
  Try
    MCS.Acquire;
    AFilePath := APath;
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath+AFileName+'_'+formatdatetime('yyyymmdd',Now) + '.log';

    If FileExists(AFileName) Then
    Begin
      AssignFile(aHandle, AFileName);
      Append(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
    End;

    szTmp := '';
    szTmp := '[' + timetostr(time()) + '] ' +ALogData;
    WriteLn(aHandle, szTmp);

//    szTmp :=   '*------------*--------------*--------------*-------------------*'+timetostr(time())+Char(13);
//    WriteLn(aHandle, szTmp);

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;

procedure BusDataToCSVLog(APath, AFileName, bus_data: String);
Var
  aHandle : TextFile;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS:=TCriticalSection.create;
  Try
    MCS.Acquire;
    AFilePath := APath;
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath+AFileName+'_'+formatdatetime('yyyymmdd',Now) + '.csv';

    If FileExists(AFileName) Then
    Begin
      AssignFile(aHandle, AFileName);
      Append(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
      szTmp :=   '수집시간, 순서,버스번호,유형,타입,여행시간,저상,막차,잔여,도착정류장,'+
                 '출발도착,재차타입,도착순위,운행종료,재차표출,방향';
      WriteLn(aHandle, szTmp);
    End;

    szTmp := '';
    szTmp := bus_data;
    WriteLn(aHandle, szTmp);

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;

function getDateTime(date:String): TDateTime;
var
    year, month, day, hour, min, sec : Word;
    r_value : TDateTime;
begin
    //r_value := EncodeDateTime(0, 0, 0, 0, 0, 0, 0);

    if IsDigit(date) = True then
    begin
        year  := StrToInt(Copy(date, 1,4));
        month := StrToInt(Copy(date, 5,2));
        day   := StrToInt(Copy(date, 7,2));
        hour  := StrToInt(Copy(date, 9,2));
        min   := StrToInt(Copy(date,11,2));
        sec   := StrToInt(Copy(date,13,2));

        r_value := EncodeDateTime(year, month, day, hour, min, sec, 0);
    end;

    Result := r_value;
end;

procedure SavePrMsgToFile(APath, AFileName, Messages: String);
Var
  aHandle : TextFile;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS:=TCriticalSection.create;
  if AFileName = '' then
    exit;
  Try
    MCS.Acquire;
    AFilePath := APath;
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath + AFileName;

    If FileExists(AFileName) Then
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
    End;

    szTmp := '';
    szTmp := Messages;
    WriteLn(aHandle, Utf8ToAnsi(szTmp));

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;


{
procedure SavePrMsgToFile(APath, AFileName, Messages: String);
Var
    prStream : TStringStream;
    aFile : TStringList;
    Encoding: TEncoding;
begin
    Encoding := TEncoding.ANSI;
    prStream := TStringStream.Create(Messages, Encoding);

    aFile := TStringList.Create;
    aFile.Text := prStream.DataString;

    aFile.SaveToFile(APath+AFileName);
end;
}

procedure WriteConfigString(fName,Section,Item, val: String);
var
   IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(fName);
     try
     IniFile.WriteString(Section, Item, val);
     finally
            IniFile.Free;
     end;
end;

procedure WriteConfigInteger(fName,Section,Item: String; Val:Integer);
var
   IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(fName);
  try
  IniFile.WriteInteger(Section, Item, val);
  finally
         IniFile.Free;
  end;
end;


function  getTimeDiff(fromDt, toDt: TDateTime): integer;
begin
   result := abs(SecondsBetween(fromDt, toDt));
end;

// -------------------------------------------------------------
/// @fn     getSecToMin
/// @brif   도착정보 초 -> 분 변경로직
/// @auther frogmon
/// @parm   잔여정류장, 초
/// @return 도착예정시간 (분)
// -------------------------------------------------------------
function getSecToMin(leften, sec: Integer): Integer;
var
  _plus: double;
begin
  _plus := 21.0;
  result := floor((60.0 + sec - _plus) / 60.0);

  if leften <= 1 then begin
    if result <= 1 then
      result := 1;
  end
  else if leften = 2 then begin
       if result <= 2 then
        result := 2;
  end
  else begin
    if sec < (30.0 * leften) then
      result := floor((60.0 + (30.0 * leften) - _plus) / 60.0);
  end;
end;

function GetFileLength(FileName:String):LongInt;
var
   f: file of Byte;
   size : Longint;
begin
     if FileExists(FileName) then
     begin
          AssignFile(f, FileName);
          Reset(f);
          size := FileSize(f);
          CloseFile(f);
          GetFileLength := size;
     end
     else
         GetFileLength := 0;
end;

function dec2bin(Value: Integer): String;
var
   i: Integer;
   s: String;
begin
  s := '';
  for i:=3 downto 0 do
    if (Value and (1 shl i)) <> 0 then s := s + '1'
    else s := s + '0';
  result := s;
end;

function dec2binN(Value: Integer; loc: Integer): Boolean;
begin
  if (Value and (1 shl loc)) <> 0 then result := true
    else result := false;
end;

{$IFDEF WINDOWS}

{$ELSE}
function getMacAddr: String;
var
  AProcess:TProcess;
  AStringList:TStringList;
begin
  AProcess := TProcess.Create(nil);
  AStringList := TStringList.Create;
  AProcess.CommandLine := 'cat /sys/class/net/eth0/address';
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AStringList.LoadFromStream(AProcess.Output);
  writeln(AStringList.CommaText);
  result := AStringList[0];
  Aprocess.Destroy;
end;
{$ENDIF}

function getPCMVolume(value: Integer): Integer;
begin
    case value of
      0: begin
        result := 0;
      end;
      1: begin
        result := 70;
      end;
      2: begin
        result := 80;
      end;
      3: begin
        result := 90;
      end;
      4: begin
        result := 95;
      end;
      5: begin
        result := 100;
      end;
      else
        result := 100;
    end;
end;

{
function getStrToDate(DateStr: String): TDateTime;
var
  F: TFormatSettings;
  s: String;
  i: Integer;
  separator: integer;
begin
  GetLocaleFormatSettings(0, F);
  F.ShortDateFormat := 'yyyy/mm/dd';
  F.ShortTimeFormat := 'hh:nn:ss';
  F.DateSeparator := '/';
  F.TimeSeparator := ':';

  separator := Pos(F.DateSeparator, DateStr);

  if separator = 0 then
    Raise Exception.Create('No date separator in date ' + DateStr);

  s := Copy(DateStr, 1, separator-1 );

  i := High(ShortMonthNames);

  while ( i >= Low(ShortMonthNames) ) and not SameText ( s, ShortMonthNames[i] ) do
    dec ( i );

  s := IntToStr(i) + Copy ( DateStr, separator, length(DateStr) );
  if i >=  Low(ShortMonthNames) then
    result := StrToDateTime ( s, F )
  else
    Raise Exception.Create('Could not convert the date ' + DateStr)
end;
 }

function getXMLStrDateToDate(DateStr: String): TDateTime;
var
    year, month, day, hour, min, sec : Word;
    r_value : TDateTime;
begin
    //r_value := yyyy/mm

    year  := StrToInt(Copy(DateStr, 1,4));
    month := StrToInt(Copy(DateStr, 6,2));
    day   := StrToInt(Copy(DateStr, 9,2));
    hour  := StrToInt(Copy(DateStr,12,2));
    min   := StrToInt(Copy(DateStr,15,2));
    sec   := StrToInt(Copy(DateStr,18,2));

    r_value := EncodeDateTime(year, month, day, hour, min, sec, 0);

    Result := r_value;
end;

function CheckVillageBusPos(msg_no: String): Integer;
var
    gu_pos : Integer;
    bus_no : String;

begin
    gu_pos := 0;

    bus_no := copy(msg_no, 1, 6);

    if bus_no = '종로' then
         gu_pos := 1
    else if bus_no = '중구' then
         gu_pos := 2
    else if bus_no = '용산' then
         gu_pos := 3
    else if bus_no = '성동' then
         gu_pos := 4
    else if bus_no = '광진' then
         gu_pos := 5
    else if bus_no = '동대' then  // 3 char
         gu_pos := 6
    else if bus_no = '중랑' then
         gu_pos := 7
    else if bus_no = '성북' then
         gu_pos := 8
    else if bus_no = '강북' then
         gu_pos := 9
    else if bus_no = '도봉' then
         gu_pos := 10
    else if bus_no = '노원' then
         gu_pos := 11
    else if bus_no = '은평' then
         gu_pos := 12
    else if bus_no = '서대' then  // 3 char
         gu_pos := 13
    else if bus_no = '마포' then
         gu_pos := 14
    else if bus_no = '양천' then
         gu_pos := 15
    else if bus_no = '강서' then
         gu_pos := 16
    else if bus_no = '구로' then
         gu_pos := 17
    else if bus_no = '금천' then
         gu_pos := 18
    else if bus_no = '영등' then  // 3 char
         gu_pos := 19
    else if bus_no = '동작' then
         gu_pos := 20
    else if bus_no = '관악' then
         gu_pos := 21
    else if bus_no = '서초' then
         gu_pos := 22
    else if bus_no = '강남' then
         gu_pos := 23
    else if bus_no = '송파' then
         gu_pos := 24
    else if bus_no = '강동' then
         gu_pos := 25;
    Result := gu_pos;
end;

procedure killProcess(filename: String);
var
    output: AnsiString;
begin
  {$IFDEF WINDOWS}
    RunCommand('taskkill /f /im '+ filename, output);
  {$ELSE}
    RunCommand('pkill -9 '+ filename, output);
  {$ENDIF}
end;

procedure ProcessStart(commands: String);
var
    output: AnsiString;
begin
  {$IFDEF WINDOWS}
    RunCommand(commands, output);
  {$ELSE}
    RunCommand(commands, output);
  {$ENDIF}
end;

procedure setDateTime(aYear, aMonth, aDay, aHour, aMin, aSec: Integer);
var
    output: AnsiString;
    strCmd: String;
begin
    strCmd := format('sudo date -s "%d-%d-%d %d:%d:%d"', [aYear, aMonth, aDay, aHour, aMin, aSec]);
    RunCommand(strCmd, output);
end;

procedure encodeCP949(fromFileName, toFileName: String);
var
    output: AnsiString;
    commandLn: String;
begin
    fromFileName := gFileOverDir + fromFileName;
    toFileName   := gFileOverDir + toFileName;
    {$IFDEF WINDOWS}
    //    ShellExecute( 0, nil, PChar('utf8toansi.bat'), PChar(fromFileName + ' ' + toFileName), nil, 0);
    //    sleep(1000);
    {$ELSE}

    {$ENDIF}
end;

procedure makeVoiceFile(filename: String; LstVoiceData: TStringList);
var
    i: Integer;
    StrLst: TStringList;
    SoundLists: String;
begin
    SoundLists := '';
    SoundLists := './voice/' +  'mt_init.wav ';
    for i := 0 to LstVoiceData.Count - 1 do begin
        SoundLists := SoundLists + './busvoice/' +  LstVoiceData[i] + '.wav ';
    end;
    SoundLists := SoundLists + './voice/' +  'mt_last.wav';
    if LstVoiceData.Count = 0 then
      SoundLists := '';

    StrLst := TStringList.create;
    try
      StrLst.add(SoundLists);
      StrLst.SaveToFile(filename);
    finally
      StrLst.free;
    end;
end;


function unmungestr(const instr: String): String;
  function IfThen( b : Boolean; f, a : Integer):Integer;
  begin
    if( b )then
      Result := f
    else
      Result := a;
  end;
var
  inChr:PChar;
  res, ResTmp : PChar;
  len : integer;
  i, j : Integer;
begin
  len := Length(instr) * 3;

  inChr := PChar( instr );
  GetMem( res, len );
  {$IFDEF WINDOWS}
      FillByte(res, len,0);
  {$ELSE}
      //ZeroMemory( res, len );
  {$ENDIF}

  ResTmp := res;
  while( inChr^ <> #0 ) do
  begin
    if( (inChr^ = '%') And ((inChr+1)^ <> #0) And ((inChr+2)^ <> #0) )then
    begin
      i := BYTE((inChr+1)^) - BYTE('0');
      i := i - IfThen( i>9, 7, 0 );

      j := BYTE((inChr+2)^) - BYTE('0');
      j := j - IfThen( j>9, 7, 0 );

      ResTmp^ := Char(( i shl 4 ) + j);
      Inc( ResTmp );
      Inc( inChr, 3 );
    end else begin
      ResTmp^ := inChr^;
      Inc( ResTmp );
      Inc( inChr );
    end;
  end;

  Result := UTF8Encode(res);
  FreeMem( res );

end;

procedure ErrorToCSVLog(APath, AFileName, msg: String);
Var
  aHandle : TextFile;
  bHandle : File of Byte;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS:=TCriticalSection.create;
  Try
    MCS.Acquire;
    AFilePath := APath;
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath+AFileName+'_'+formatdatetime('yyyymm',Now) + '.csv';

    If FileExists(AFileName) Then Begin
      AssignFile(aHandle, AFileName);
      Append(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
      szTmp := '수집시간,하우스_ID,하우스_NO,타입,내용';
      WriteLn(aHandle, szTmp);
    End;

    szTmp := msg;
    WriteLn(aHandle, szTmp);

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;

procedure ToCSVFile(APath, AFileName, headline, msg: String);
Var
  aHandle : TextFile;
  bHandle : File of Byte;
  szTmp, AFilePath : String;
  MCS : TCriticalSection;
begin
  MCS:=TCriticalSection.create;
  Try
    MCS.Acquire;
    AFilePath := APath;
    if not DirectoryExists(AFilePath) then
    if not CreateDir(AFilePath) then
    raise Exception.Create('Cannot create'+AFilePath);

    AFileName:=AFilePath+AFileName + '.csv';

    If FileExists(AFileName) Then Begin
      AssignFile(aHandle, AFileName);
      Append(aHandle);
    End
    Else
    Begin
      AssignFile(aHandle, AFileName);
      ReWrite(aHandle);
      szTmp := headline;
      WriteLn(aHandle, szTmp);
    End;

    szTmp := msg;
    WriteLn(aHandle, szTmp);

    CloseFile(aHandle);
  Except
  On E : EInOutError Do
    begin
      MCS.Release;
      exit;
    end;
  End;
  MCS.Release;
end;


procedure RestartTimer(Timer: TTimer);
begin
  Timer.Enabled := false;
  Timer.Enabled := true;
end;

function setWindCase(wind: double): String;
begin
  if wind < 4 then begin
      result := '실바람';
  end
  else if wind < 9 then begin
      result := '산들바람';
  end
  else if wind < 14 then begin
      result := '강한바람';
  end
  else begin
    result := '태풍';
  end;
end;

function chkInterNet(): Boolean;
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

procedure TickTock();
begin
  DecodeDateTime(now(), gYear, gMonth, gDay, gHour, gMin, gSec, gMsec);

  gStrDate := formatDateTime('yyyymmdd', now());
  gStrtime := formatDateTime('hhnnss', now());
  gStrFDate := formatDateTime('yyyy/mm/dd', now());
  gStrFTime := formatDateTime('hh:nn:ss', now());
  gStrDateTime := formatDateTime('yyyymmddhhnnss', now());
  gStrKrDate   := formatDateTime('m월 d일', now());
end;

function getDayToday(ADate: TDateTime): String;
 const days: array[1..7] of string = ('일','월','화','수','목','금','토');
begin
  result := days[DayOfWeek(ADate)];
end;

end.
      
