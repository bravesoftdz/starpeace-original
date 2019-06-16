unit mr_StrUtils;

// Copyright (c) 1996 Jorge Romero Gomez, Merchise.
//
// Notes:
//
//    Ported from the UtStr unit.
//
// Old functions:             Use instead:
//
// - UpCaseStr:               UpperCase or AnsiUpperCase ( SysUtils )
// - LoCaseStr:               LowerCase or AnsiLowerCase ( SysUtils )
// - CleanSpaces, CleanStr:   Trim                       ( SysUtils )
// - SkipSpaces:              TrimLeft                   ( SysUtils )
// - CleanTrailingSpaces:     TrimRight                  ( SysUtils )
// - TrimSpaces               PackSpaces                 ( new name )

interface

  uses
    SysUtils, Windows, Classes, AnsiStrings;

  const
    chBEEP  = ^G;
    chBS    = ^H;
    chTAB   = ^I;
    chLF    = ^J;
    chNP    = ^L;
    chCR    = ^M;
    chSPACE = ' ';

  const
    DefaultTabStop = 8;

  type
    TCharSet = set of ansichar;

  function CleanTabs( const Str : string; TabStop : integer ) : string;         // Converts TABs to Spaces

  function StripHiBit( const Str : string ) : string;                           // Converts 8bit ASCII to 7 bits

  function KillSpaces( const Str : string ) : string;                           // Delete all spaces
  function PackSpaces( const Str : string ) : string;                           // Replaces contiguous spaces by one space

  function LeftAlign( const Str : string; Width : integer ) : string;           // Align left to a field of specified width
  function RightAlign( const Str : string; Width : integer ) : string;          // Align right to a field of specified width
  function CenterAlign( const Str : string; Width : integer ) : string;         // Center in a field of specified width
  function AdjustStr( const Str : string; Width : integer ) : string;           // Trims control characters leading spaces and aligns to left
  function CapitalizeStr( const Str : string ) : string;                        // Guess what: First letter in upper case and the rest in lower case

  function ReplaceChar( const Str : string; Old, New : ansichar ) : string;         // Replaces all "Old" characters by "New"
  function ReplaceStr(  const Str : string; const Old, New : string ) : string; // Replaces all "Old" substrings by "New"

  function Spaces( Count : integer ) : string;                                  // Returns "Count" spaces
  function Dupchar( Ch : ansichar; Count : integer ) : string;                      // ( "a",   3 ) => "aaa"
  function DupStr( const Str : string; Count : integer ) : string;              // ( "abc", 3 ) => "abcabcabc"

  function StrEqual( Str1, Str2 : pansichar; Len : integer ) : boolean;             // Check for equality between "Str1" & "Str2", ignores #0
  function CharPos( Str : pansichar; Ch : ansichar; Len : integer ) : integer;

  function RightStr( const Str : string; Count : integer ) : string;            // Get last "Count" characters
  function LeftStr( const Str : string; Count : integer ) : string;             // Get first "Count" characters

  function FirstNot( const Str : string; Ch : char; At : integer ) : integer;   // First character that is not "Ch", starting at "At"           // Same as System cousin
  function BackPos( const SubStr, Str : string; At : integer ) : integer;       // Backwards version

  function EndsWith( const SubStr, Str : string ) : boolean;
  function StartsWith( const SubStr, Str : string ) : boolean;

  function BeforeStr( const SubStr, Str : string ) : string;                    // Portion of "Str" before "SubStr"
  function AfterStr ( const SubStr, Str : string ) : string;                    // Portion of "Str" after "SubStr"

  function JoinStrings( Strings : array of string ) : pansichar;                    // Return a NUL terminated list of ASCIIZ strings from an array of strings
  function JoinStringList( List : TStrings ) : pansichar;                           // Same, but from a string list
  function SplitStringList( StringList : pchar ) : TStrings;                    // Obtain a list of strings from a NUL terminated list

  function SplitStrings( const Strings, Separator : string ) : TStrings;

  function AnsiToAscii( const Str : string ) : string;
  function AsciiToAnsi( const Str : string ) : string;

  // --- Number to string ---

  const
    HexDigits : array[0..15] of ansichar = '0123456789ABCDEF';

  function NumToStr( Num : integer; Base, Width : integer ) : string;  // NumToStr( 8, 9, 2 ) = '10'
  function Hex( Num, Width : integer ) : string;                       // Hex( 31, 4 ) = '001F'

  function IndxOf( const IndxStr, Prefix : string ) : integer;         // IndxOf( 'Foobar01', 'Foobar' ) = 1

  // Internal structure of AnsiString

  type
    StrInternalStruct =
      record
        AllocSize : longint;
        RefCount  : longint;
        Length    : longint;
      end;

  const
    StrSkew     = sizeof( StrInternalStruct );
    StrOverhead = sizeof( StrInternalStruct ) + 1;

  function GetNextString(const str : string; var pos : integer; sep : TCharSet) : string;
  function GetNextWord(const str : string; var pos : integer; sep : TCharSet) : string;

implementation

  function IndxOf( const IndxStr, Prefix : string ) : integer; // IndxOf( 'Foobar01', 'Foobar' ) = 1
    begin
      if Prefix = copy( IndxStr, 1, length( Prefix ) )
        then
          try
            Result := StrToInt( copy( IndxStr, length( Prefix ) + 1, MaxInt ) );
          except
            Result := -1;
          end
        else
          Result := -1;
    end;

  // --- Number to string ---

  function Hex( Num, Width : integer ) : string;
    begin
      Result := NumToStr( Num, 16, Width );
    end;

  function NumToStr( Num : integer; Base, Width : integer ) : string;
    begin
      SetLength( Result, Width );
      repeat
        dec( Width );
        pansichar(Result)[Width] := HexDigits[Num mod Base];
        Num := Num div Base;
      until Width <= 0;
    end;

  function SplitStrings( const Strings, Separator : string ) : TStrings;
    var
      ChPos  : integer;
      OldPos : integer;
      Len    : integer;
    begin
      OldPos := 0;
      Len    := length( Strings );
      Result := TStringList.Create;
      repeat
        ChPos := Pos( Separator, Strings, OldPos + Len );
        if ChPos <> 0
          then Result.Add( copy( Strings, OldPos + Len, ChPos - OldPos - 1 ) )
          else Result.Add( copy( Strings, OldPos + Len, MaxInt ) );
        OldPos := ChPos;  
      until ChPos = 0;
    end;

  function SplitStringList( StringList : pchar ) : TStrings;
    var
      s : string;
      len: integer;
    begin
      Result := TStringList.Create;
      len := StrLen(StringList);
      while len <> 0 do
        begin
          s := StringList;
          Result.Add( s );
          Inc( StringList, length( s ) + 1 );
        end;
    end;

  function JoinStrings( Strings : array of string ) : pansichar;
    var
      i         : integer;
      ListSize  : integer;
      StrPtr    : pansichar;
      CurrStr   : string;
    begin
      ListSize  := 1;
      for i := low( Strings ) to high( Strings ) do
        Inc( ListSize, length( Strings[i] ) + 1 );

      GetMem( Result, ListSize );

      StrPtr := Result;
      for i := low( Strings ) to high( Strings ) do
        begin
          CurrStr := Strings[i];
          System.Move( pansichar(CurrStr)[0], StrPtr[0], length( CurrStr ) + 1 );
          Inc( StrPtr, length( CurrStr ) + 1 );
        end;
      StrPtr[0] := #0;
    end;

  function JoinStringList( List : TStrings ) : pansichar;
    var
      i         : integer;
      LastIndx  : integer;
      ListSize  : integer;
      StrPtr    : pansichar;
      CurrStr   : string;
    begin
      ListSize  := 1;
      with List do
        begin
          LastIndx := List.Count - 1;

          for i := 0 to LastIndx do
            Inc( ListSize, length( Strings[i] ) + 1 );

          GetMem( Result, ListSize );

          StrPtr := Result;
          for i := 0 to LastIndx do
            begin
              CurrStr := Strings[i];
              System.Move( pansichar(CurrStr)[0], StrPtr[0], length( CurrStr ) + 1 );
              Inc( StrPtr, length( CurrStr ) + 1 );
            end;
          StrPtr[0] := #0;
        end;
    end;

  function AnsiToAscii( const Str : string ) : string;
    begin
      SetLength( Result, length( Str ) );
      CharToOemA( pansichar( Str ), pansichar( Result ) );
    end;

  function AsciiToAnsi( const Str : string ) : string;
    begin
      SetLength( Result, length( Str ) );
      OemToCharA( pansichar( Str ), pansichar( Result ) );
    end;

  function CapitalizeStr( const Str : string ) : string;
    begin
      Result    := LowerCase( Str );
      Result[1] := UpCase( Result[1] );
    end;

  function ReplaceChar( const Str : string; Old, New : ansichar ) : string;
    var
      i : integer;
    begin
      SetString( Result, pansichar(Str), length( Str ) );
      for i := 0 to length( Str ) - 1 do
        if pansichar( Result )[i] = Old
          then pansichar( Result )[i] := New;
    end;

  function ReplaceStr(  const Str : string; const Old, New : string ) : string;
    var
      Indx     : integer;
      LastIndx : integer;
      ResLen   : integer;
      Delta    : integer;
    begin
      // Reserve space for max new length
      if New = ''
        then SetLength( Result, length( Str ) )
        else
          if length( New ) > length( Old ) // Reserve space for max new length
            then SetLength( Result, length(Str) * length( New ) div length( Old ) )
            else SetLength( Result, length(Str) * length( Old ) div length( New ) );

      ResLen := 0;
      Indx   := 1;

      repeat
        LastIndx := Indx;
        Indx := Pos( Old, Str, LastIndx );
        if Indx <> 0
          then
            begin
              Delta := Indx - LastIndx;
              Move( pansichar(Str)[LastIndx - 1], pansichar(Result)[ResLen], Delta );      // Copy original piece
              Move( pansichar(New)[0], pansichar(Result)[ResLen + Delta], length( New ) ); // Copy New
              Inc( ResLen, Delta + length( New ) );
              Inc( Indx, length( Old ) );
            end;
      until Indx = 0;
      Move( pansichar(Str)[LastIndx - 1], pansichar(Result)[ResLen], length(Str) - LastIndx + 1 );  // Copy last piece
      SetLength( Result, ResLen + length(Str) - LastIndx + 1 );
    end;

  function KillSpaces( const Str : string ) : string;
    var
      i, j : integer;
      s    : string;
      Len  : integer;
    begin
      Len := Length( Str );
      SetLength( s, Len );

      j := 0;
      for i := 0 to Len - 1 do
        if pansichar( Str )[i] > ' '
          then
            begin
              pansichar( s )[j] := pansichar( Str )[i];
              Inc( j );
            end;
      SetString( Result, pansichar( s ), j );
    end;

  function PackSpaces( const Str : string ) : string;
    var
      i, j : integer;
      Len  : integer;
    begin
      Len := Length( Str );
      SetLength( Result, Len );

      j := 0;
      pansichar( Result )[0] := pansichar( Str )[0];
      for i := 1 to Len - 1 do
        if ( pansichar( Str )[ i - 1 ] > ' ' ) or ( pansichar( Str )[i] > ' ' )
          then
            begin
              Inc( j );
              pansichar( Result )[j] := pansichar( Str )[i];
            end;
      SetLength( Result, j + 1 );
    end;

  function DupStr( const Str : string; Count : integer ) : string;
    var
      i   : integer;
      Len : integer;
    begin
      Len := Length( Str );
      SetLength( Result, Count * length( Str ) );
      for i := 0 to Count - 1 do
        Move( pansichar( Str )[0], pansichar( Result )[i * Len], Len );
    end;

  function Dupchar( Ch : ansichar; Count : integer ) : string;
    begin
      SetLength( Result, Count );
      FillChar( pansichar( Result )[0], Count, Ch );
    end;

  function Spaces( Count : integer ) : string;
    begin
      SetLength( Result, Count );
      FillChar( pansichar( Result )[0], Count, ' ' );
    end;

  function CleanTabs( const Str : string; TabStop : integer ) : string;   // Converts TABs to Spaces
    var
      ResStr   : pansichar;
      CurrLine : pansichar;
      i        : integer;
      SpcCount : integer;
    begin
      if TabStop = 0
        then TabStop := DefaultTabStop;

      SetLength( Result, length( Str ) * 8 );              // Worst case!
      CurrLine := pansichar(Result);                           // For multi-line strings, see later
      ResStr   := CurrLine;

      for i := 1 to length( Str ) do
        case Str[i] of
          chTAB :
            begin
              SpcCount := ( ResStr - CurrLine ) mod TabStop;
              FillChar( ResStr, SpcCount, ' ' );
              Inc( ResStr, SpcCount );
            end;
          chCR :
            begin
              CurrLine := pansichar( Result ) + i; // This function can format a multi-line string: here
                                               // we update CurrLine if we found a new line
              ResStr := pansichar(Str) + i - 1;
              Inc( ResStr );
            end;
          else
            begin
              ResStr := pansichar(Str) + i - 1;
              Inc( ResStr );
            end;
        end;
      SetLength( Result, ResStr - pansichar(Result) );
    end;

  function AdjustStr( const Str : string; Width : integer ) : string;
    begin
      AdjustStr := LeftAlign( TrimLeft( CleanTabs( Str, 0 ) ), Width );
    end;

  function FirstNot( const Str : string; Ch : char; At : integer ) : integer;
    begin
      Result := LastDelimiter(Ch, Str) + 1;
    end;

  function BackPos( const SubStr, Str : string; At : integer ) : integer;
    var
      StartPos: integer;
      Len    : integer;
    begin
      StartPos := AnsiPos(SubStr, Str);
      Len := Length(SubStr);
      Result := (StartPos + Len) - 1
    end;

  function StripHiBit( const Str : string ) : string;
    var
      i : integer;
    begin
      Result := Str;
      for i := 0 to length( Result ) - 1 do
        byte( pansichar( Result )[i] ) := byte( pansichar( Result )[i] ) and 127;
    end;

  function RightAlign( const Str : string; Width : integer ) : string;
    begin
      if length( Str ) < Width
        then Result := Spaces( Width - length( Str ) ) + Str
        else SetString( Result, pansichar( Str ), Width );
    end;

  function LeftAlign( const Str : string; Width : integer ) : string;
    begin
      if length( Str ) < Width
        then Result := Str + Spaces( Width - length( Str ) )
        else SetString( Result, pansichar( Str ), Width );
    end;

  function CenterAlign( const Str : string; Width : integer ) : string;
    var
      n : integer;
      s : string;
    begin
      n := ( Width - length( Str ) ) div 2;
      if n > 0
        then
          begin
            s := Spaces( n );
            Result := s + Str + s;
          end
        else Result := Str
    end;

  function CharPos( Str : pansichar; Ch : ansichar; Len : integer ) : integer;
    begin
      Result := ansipos(Ch, Str);
    end;

  function StrEqual( Str1, Str2 : pansichar; Len : integer ) : boolean;
  begin
     Result := SameText(Str1, Str2);
  end;

  function StartsWith( const SubStr, Str : string ) : boolean;
    begin
      Result := Str.StartsWith(Str);
    end;

  function EndsWith( const SubStr, Str : string ) : boolean;
    begin
      Result := Str.EndsWith(SubStr);
    end;

  function RightStr( const Str : string; Count : integer ) : string;
    begin
      if Length( Str ) > Count
        then Result := copy( Str, length( Str ) - Count + 1, Count )
        else Result := Str;
    end;

  function LeftStr( const Str : string; Count : integer ) : string;
    begin
      SetString( Result, pansichar( Str ), Count );
    end;

  function BeforeStr( const SubStr, Str : string ) : string;
    begin
      SetString( Result, pansichar( Str ), System.Pos( SubStr, Str ) - 1 );
    end;

  function AfterStr( const SubStr, Str : string ) : string;
    var
      pos : integer;
    begin
      pos := System.Pos( SubStr, Str );
      SetString( Result, pansichar( Str ) + pos, Length( Str ) - pos );
    end;

function GetNextString(const str : string; var pos : integer; sep : TCharSet) : string;
  var
    OldPos : integer;
    count  : integer;
    len    : integer;
  begin
    len := length(str);

    OldPos := pos;
    while (pos <= len) and not (str[pos] in sep) do
      inc(pos);

    count := pos - OldPos;
    if count > 0
      then
        begin
          SetLength(result, count);
          Move(str[OldPos], result[1], count);
        end
      else result := '';
  end;

function GetNextWord(const str : string; var pos : integer; sep : TCharSet) : string;
  var
    p, q, r : pansichar;
  begin
    r := pansichar(str);
    p := r+pos-1;
    while (p[0] in sep) and (p[0]<>#0) do
      inc(p);

    if p[0]<>#0
      then
        begin
          q := p;
          while not(p[0] in sep) and (p[0]<>#0) do
            inc(p);
          result := copy(str, q-r+1, p-q);
          pos := p-r+1;
        end
      else result := '';
  end;



end.
