unit ChakraImg;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, ChakraImgUtils;

  function ImgGetImageFromFile(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aFileName: String;
    aHeight, aWidth: Integer;
  begin
    CheckParams('getImageFromFile', Args, ArgCount, [jsString, jsNumber, jsNumber], 3);

    aFileName := JsStringAsString(Args^); Inc(Args);

    aHeight := JsNumberAsInt(Args^); Inc(Args);
    aWidth  := JsNumberAsInt(Args^);

    Writeln('en el chakraimg todo bien');

    Result := GetImageFromFile(aFileName, aHeight, aWidth);
  end;

  function GetJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'getImageFromFile', ImgGetImageFromFile);
  end;

end.