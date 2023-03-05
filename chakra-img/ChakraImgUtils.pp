unit ChakraImgUtils;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetImageFromFile(aFileName: String; aHeight, aWidth: Integer): TJsValue;

implementation

  uses
    Imaging, ImagingTypes, SysUtils, Classes, Chakra, ChakraUtils, StrUtils, Types;

  function ImageFromPpmFile(aFileName: String): TJsValue;
  var
    Height, Width: Integer;
    FileLines: TStringList;
    NumbersList: TStringList;
    I, DummyInt: Integer;
    LineIndex: Integer;
    Number: String;
    SplitLine: TStringDynArray;
    NumbersInImageLine: Integer;
    ImageLine: TJsValue;
    Pixel: TJsValue;
    PixelIndex: Integer;
  begin

    FileLines := TStringList.Create;
    FileLines.LoadFromFile(aFileName);

    Height := StrToInt(FileLines.Strings[1]);
    Width := StrToInt(FileLines.Strings[2]);

    Result := CreateArray(Height);

    NumbersList := TStringList.Create;

    for I := 4 to FileLines.Count - 1 do begin
      SplitLine := SplitString(FileLines.Strings[I], ' ');
      for Number in SplitLine do begin
        if TryStrToInt(Number, DummyInt)  then begin
          NumbersList.Add(Number);
        end;
      end;
    end;

    NumbersInImageLine := Width * 3;

    LineIndex := -1;
    PixelIndex := 0;

    for I := 0 to (NumbersList.Count - 1) do begin

      if (I mod 3) <> 0 then continue;

      if (I mod NumbersInImageLine) = 0 then begin
        Inc(LineIndex);
        ImageLine := CreateArray(Width);
        SetArrayItem(Result, LineIndex, ImageLine);
      end;

      if PixelIndex >= Width then begin
        PixelIndex := 0;
      end;

      Pixel := CreateObject;
      SetProperty(Pixel, 'r', IntAsJsNumber(StrToInt(NumbersList.Strings[I])));
      SetProperty(Pixel, 'g', IntAsJsNumber(StrToInt(NumbersList.Strings[I+1])));
      SetProperty(Pixel, 'b', IntAsJsNumber(StrToInt(NumbersList.Strings[I+2])));

      SetArrayItem(ImageLine, PixelIndex, Pixel);

      Inc(PixelIndex);
    end;

    FileLines.Free;
    NumbersList.Free;

  end;

  function GetImageFromFile;
  var
    Image: TImageData;
    TempFileName: String;
    AspectRatio: Single;
  begin

    InitImage(Image);

    if LoadImageFromFile(aFileName, Image) then begin

      Image.Format := ifR8G8B8;

      if aHeight <> -1 then begin

        AspectRatio := Image.Width / Image.Height;
        ResizeImage(Image, aWidth, Round(aWidth / AspectRatio), rfBicubic);

      end;

      TempFileName := Format('%s.ppm', [GetTempFileName]);

      SetOption(ImagingPPMSaveBinary, 0);
      SaveImageToFile(TempFileName, Image);
      FreeImage(Image);

      Result := ImageFromPpmFile(TempFileName);

      DeleteFile(TempFileName);

    end else begin
      Result := Undefined;
    end;
  end;

end.