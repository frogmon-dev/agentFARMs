unit ucommon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
  
const
{ 하우스 AGENT 설정 }
HOUSE_MANUAL                = 0;
HOUSE_TEMPER                = 1;
HOUSE_TIME                  = 2;
HOUSE_AUTO                  = 3;
HOUSE_REMOTE                = 4;

{Moter Mode}
MOTER_OPEN                  = 1;
MOTER_CLOSE                 = 2;
MOTER_STOP                  = 0;

{ 하우스 Error Code 설정 }
ERROR_NORMAL                = 0;
ERROR_HI_TEMPER             = 5;
ERROR_LOW_TEMPER            = 6;
ERROR_CONNECT               = 10;
ERROR_MANUAL                = 11;
ERROR_REMOTE                = 12;
ERROR_INIT                  = 99;

type

{House Info}
THouseInfo = record
    id           : String;
    alarm        : integer;
    mac          : String;
    firmware     : String;
    battery      : Integer;
    device_type  : Integer;
    humidity     : Integer;
    temperature  : double;
    cds          : Integer;
    auto         : Integer;
    conductivity : Integer;
    timestamp    : String;
    lastUpDt     : TDateTime;
end;

{Sensor Info}
TSensorInfo = record
    name         : String;
    mac          : String;
    firmware     : String;
    battery      : Integer;
    moisture     : Integer;
    temperature  : double;
    humidity     : Integer;
    light        : Integer;
    conductivity : Integer;
    timestamp    : String;
    out_temp     : double;
    out_humi     : Integer;
    out_wind     : Integer;
    out_batt     : Integer;
    out_rain     : Integer;
    lastUpDt     : TDateTime;
end;

{Weather Info}
TWeatherInfo = record
    temp         : double;
    humi         : integer;
    rain         : double;
    wind         : double;
    angle        : integer;
    sky          : integer;
    pty          : integer;
    timestamp    : String;
    lastUpDt     : TDateTime;
end;

{Plant Base Info}
TAutoPlant = record
    plantNM          : String;
    day_limit        : Integer;
    day_upto         : Integer;
    day_downto       : Integer;
    night_limit      : Integer;
    night_upto       : Integer;
    night_downto     : Integer;
    land_uplimit     : Integer;
    land_downlimit   : Integer;
    land_upto        : Integer;
    land_downto      : Integer;
end;

{Plant Control Info}
TControlInfo = record
      am_mode          : Integer;
      group1           : Integer;
      group2           : Integer;
      group1_pos       : Integer;
      group2_pos       : Integer;
    end;

var
     crc16tbl : array[0..255] of Word=(
         $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
         $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
         $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
         $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
         $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
         $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
         $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
         $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
         $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
         $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
         $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
         $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
         $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
         $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
         $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
         $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
         $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
         $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
         $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
         $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
         $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
         $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
         $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
         $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
         $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
         $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
         $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
         $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
         $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
         $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
         $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
         $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);


   ASC : Array[0..255] of String=(
           '00' , '01', '02', '03', '04', '05', '06', '07', '08', '09', '0A', '0B', '0C', '0D', '0E', '0F',
           '10' , '11', '12', '13', '14', '15', '16', '17', '18', '19', '1A', '1B', '1C', '1D', '1E', '1F',
           '20' , '21', '22', '23', '24', '25', '26', '27', '28', '29', '2A', '2B', '2C', '2D', '2E', '2F',
           '30' , '31', '32', '33', '34', '35', '36', '37', '38', '39', '3A', '3B', '3C', '3D', '3E', '3F',
           '40' , '41', '42', '43', '44', '45', '46', '47', '48', '49', '4A', '4B', '4C', '4D', '4E', '4F',
           '50' , '51', '52', '53', '54', '55', '56', '57', '58', '59', '5A', '5B', '5C', '5D', '5E', '5F',
           '60' , '61', '62', '63', '64', '65', '66', '67', '68', '69', '6A', '6B', '6C', '6D', '6E', '6F',
           '70' , '71', '72', '73', '74', '75', '76', '77', '78', '79', '7A', '7B', '7C', '7D', '7E', '7F',
           '80' , '81', '82', '83', '84', '85', '86', '87', '88', '89', '8A', '8B', '8C', '8D', '8E', '8F',
           '90' , '91', '92', '93', '94', '95', '96', '97', '98', '99', '9A', '9B', '9C', '9D', '9E', '9F',
           'A0' , 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF',
           'B0' , 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF',
           'C0' , 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'CA', 'CB', 'CC', 'CD', 'CE', 'CF',
           'D0' , 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'DA', 'DB', 'DC', 'DD', 'DE', 'DF',
           'E0' , 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'EA', 'EB', 'EC', 'ED', 'EE', 'EF',
           'F0' , 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'FA', 'FB', 'FC', 'FD', 'FE', 'FF'
   );

   {Global Time Value}
    gYear, gMonth, gDay, gHour, gMin, gSec, gMsec : Word;
    gStrDate     : String;    //< yyyymmdd
    gStrtime     : String;    //< hhnnss
    gStrFDate    : String;    //< yyyy/mm/dd
    gStrFTime    : String;    //< hh:nn:ss
    gStrDateTime : String;    //< yyyymmddhhnnss
    gStrKrDate   : String;    //< m월 d일

    {Global Path or FileName}
    gStartDir    : String;
    gLogDir      : String;
    gXMLDir      : String;
    gFileOverDir : String;
    gImageDir    : String;
    gConfDir     : String;
    gDataDir     : String;
    gConfFile    : String;
    gStatFile    : String;

    gGlobalIp    : String;
    gConnStatus  : Integer;

    gFont_size   : Integer;
    gFont_gap    : Integer;
    gFont_name   : String;

    giReconnectCnt: Integer;

    gPosScroll   : Integer;

    gIsSoonBusScroll: Boolean;
    gOnSoonBusLoc   : Integer;

    gLEDModuleType: Integer;
    gTimeTable_voice: array [0..23] of Integer;
    gTimeTable_Bright: array [0..23] of Integer;


implementation

end.

