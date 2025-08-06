{The mlstr unit was written originally in 1986 for Turbo Pascal by me
Jem Miller @Missing Link Software.

This unit is licensed under the WTF license. Do WTF you want with it. Burn
it, give it away, make millions with it, or throw darts at it. I still use
this sucker in virtually all of my work.
jem@mlsoft.org
}
Unit mlstr;
{$mode objfpc}{$H+}

Interface

Uses SysUtils;

Const
    jnone   = 0;
    jleft   = 1;
    jright  = 2;
    jcenter = 3;

Type
    stype = String;
    sstr  = Shortstring;
    TRadixRange = 2..36;

Var
    tpferror:  Byte;
    remainder: String;

{ String routines }
Function wrap(Var line: String; wid: Integer): String;//word wrap text
Function B2Hex(numb: Byte): String; //byte to hex
Function N2Hex(numb: Longword): String; //number(integer/word to hex
Function L2Hex(L: Int64): String; //longint to hex
Function copies(s: Char; nm: Byte): String; //returns nm S's as a string
Function proper(Switch: String): String;
//returns a string with first letter of each word capitolized
Function words(St: String): Byte; //returns the number of words in St
Function wordn(St: String; nm: Byte): String; //returns word number nm in St
Function trim(St: String): String; //trims spaces from the end of St
Function tab(n: Integer): String; //inserts n spaces in a string
Function stripto(Var st: String; schar: Char): String;
//strips all chars up to and including schar from beginning of a string
Function strip(sline: stype; schar: Char): String;
//removes all occurences of schar from a string
Function stripit(St: String; src: String): String; //remove a string from a string
Function replace(sline: stype; schar, rchar: Shortstring): String;
//replaces rchar with schar in sline
Function escape(sline: stype; schar, rchar: Shortstring): String;
//escapes schar with \schar\
Function I2Str(Number: Longint): String; //converts integer to string
Function S2Rl(St: String): Real; //converts string to real
Function Rl2str(Number: Real; Decimals: Byte): String; //converts real to string
Function S2Int(St: String): Int64; //converts string to integer
Function S2Ln(St: String): Longint; //converts string to longint
Function OctToInt(Value: String): Longint;
Function StrBaseToInt(Const St: String; Const Base: Integer): Integer;
Function PadLeft(St: String; Size: Byte; Pad: Char): String;
//pads beginning of St with size pad chars
Function PadCenter(St: String; Size: Byte; Pad: Char): String;
//pads both ends of St with size pad chars
Function PadRight(St: String; Size: Byte; Pad: Char): String;
//pads the right end of St with size pad chars
Function First_Capital_Pos(St: String): Byte;
//returns position of first capital letter in St
Function First_capital(St: String): Char; //returns first capitol letter in St
Function Last(N: Byte; St: String): String; //returns last N chars from St
Function First(N: Byte; St: String): String; //returns first N chars from St
Function Upper(St: String): String; //converts St to all uppercase
Function Lower(St: String): String; //converts St to all lowercase
Function OverType(N: Byte; StrS, StrT: String): String;
Function NextPos(C: Shortstring; St: String; Startat: Word): Integer;
Function LastPos(C: Shortstring; St: String): Byte; //returns last position of C in St
Function LocWord(StartAT, Wordno: Byte; St: String): Byte;
//returns location of word wordno in St beginning at startat
Function PosWord(Wordno: Byte; St: String): Byte;
//returns position of word number wordno in St
Function WordCnt(St: String): Byte; //returns number of words in St
Function GetWords(StartWord, NoWords: Byte; St: String): String;
//returns nowords words starting at startword in St
Function unique: String;
//returns a unique string based on date, time, and milliseconds in hexadecimal
Function mirt(Name: String): String; //trims spaces from the beginning of a string
Function percent(num, prc: Double): Double;
Function UpPercent(num, prc: Double): Double;
Function Int2Base(Value: Cardinal; Radix: TRadixRange): String;
Function bin2dec(Value: String; Dec: String; hexadec: String): Integer;
Function timenow: Shortstring;
Function datenow: Shortstring;
Function YearNow: Shortstring;
Function MonthNow: Word;
Function ThisMonth: Shortstring;
Function justify(st: Shortstring; direction: Byte; len: Byte): Shortstring;

Implementation

Const
    Floating = 255;

    { ------------------------------------------------------------------------- }

  { Returns a string with length less than wid. Breaks at space, #10 or #13.
  Call this function until the length of the original string is < wid to
  break up long lines. }
Function wrap(Var line: String; wid: Integer): String;
Var
    txt2, txt:    String;
    num, gi, col: Integer;

Begin

    gi:= length(line);
    txt:= copy(line, 1, wid);

    If gi <= wid Then
    Begin
      Result:= line;
      line:= '';
      exit;
    End;

    For num:= wid Downto 1 Do
    Begin
      If txt[num] = ' ' Then
      Begin
        If txt[num] = #13 Then
          If txt[num + 1] = #10 Then
          Begin
            Delete(txt, num + 1, 1);
            break;
          End;

        txt2:= copy(txt, 1, num);
        Delete(line, 1, num);
        gi:= length(line);

        Result:= txt2;
        break;
      End;

    End;

End;

Function StrBaseToInt(Const St: String; Const Base: Integer): Integer;
Var
    i, iVal, iTest: Longword;

Begin
    If (Base > 36) or (Base < 2) Then
      Raise Exception.Create('Invalid Base');

    StrBaseToInt:= 0;
    iTest:= 0;

    For i:= 1 To Length(St) Do
    Begin
      Case St[i] Of
        '0'..'9': iVal:= (Ord(St[i]) - Ord('0'));
        'A'..'Z': iVal:= (Ord(St[i]) - Ord('A') + 10);
        'a'..'z': iVal:= (Ord(St[i]) - Ord('a') + 10);
        Else
          Raise Exception.Create('Illegal character found');
      End;

      If iVal < Base Then
      Begin
        StrBaseToInt:= StrBaseToInt * Base + iVal;

        If StrBaseToInt < iTest Then  // overflow test!
        Begin
          Raise Exception.Create('Overflow occurred');
        End
        Else
        Begin
          iTest:= StrBaseToInt;
        End;

      End
      Else
      Begin
        Raise Exception.Create('Illegal character found');
      End;

    End;

End;

Function OctToInt(Value: String): Longint;
Var
    i, int: Integer;

Begin
    int:= 0;

    For i:= 1 To Length(Value) Do
      int:= int * 8 + StrToInt(Copy(Value, i, 1));

    OctToInt:= int;
End;

Function Int2Base(Value: Cardinal; Radix: TRadixRange): String;
Const
    Digits: Array[0..35] Of Char = ('0', '1', '2', '3',
      '4', '5', '6', '7',
      '8', '9', 'A', 'B',
      'C', 'D', 'E', 'F',
      'G', 'H', 'I', 'J',
      'K', 'L', 'M', 'N',
      'O', 'P', 'Q', 'R',
      'S', 'T', 'U', 'V',
      'W', 'X', 'Y', 'Z');
Var
    nIndex: Integer;

Begin
    Result:= '';

    Repeat
      nIndex:= Value mod radix;
      Result:= Digits[nIndex] + Result;
      Value:= Value div radix;
    Until Value = 0;

End;

Function bin2dec(Value: String; Dec: String; hexadec: String): Integer;
Var             //dec and hexadec are the TEdits where I will put the result
    i, iValueSize: Integer;
    Edit2, f:      String;

Begin
    Result:= 0;
    iValueSize:= Length(Value);

    For i:= iValueSize Downto 1 Do
    Begin
      If Value[i] = '1' Then Result:= Result + (1 shl (iValueSize - i));
    End;

    Dec:= (IntToStr(Result));        //dec. number
    hexadec:= (IntToHex(Result, 8));  //hexadec. number
End;

Function B2Hex(numb: Byte): String;       { Converts byte to hex string }
Const
    HexChars: Array[0..15] Of Char = '0123456789ABCDEF';

Begin
    setlength(b2hex, 2);
    B2Hex[1]:= HexChars[numb shr 4];
    B2Hex[2]:= HexChars[numb and 15];
End; { Byte2Hex }

Function N2Hex(numb: Longword): String;        { Converts word to hex string.}
Begin
    N2Hex:= B2Hex(hi(numb)) + B2Hex(lo(numb));
End; { Numb2Hex }

Function L2Hex(L: Int64): String;     { Converts longint to hex string }
Begin
    L2Hex:= N2Hex(L shr 16) + N2Hex(L);
End; { Long2Hex }

Function Percent(num, prc: Double): Double;
Var
    p: Double;

Begin
    p:= (prc / 100) * num;
    Result:= p;
End;

Function UpPercent(num, prc: Double): Double;
Var
    p: Double;

Begin
    p:= (prc / 100) * num;
    Result:= num + p;
End;

Function unique: String;
Var
    h, m, s, ms: Word;
    yr, mo, da: Word;
    present: tdatetime;
    WrkStr: String;
    ll: Int64;

Begin
    WrkStr:= '';
    present:= now;
    decodetime(present, h, m, s, ms);

    decodedate(present, yr, mo, da);

    WrkStr:= i2str(mo) + i2str(da) + i2str(h) + i2str(m) + i2str(s) + i2str(ms);

    ll:= s2int(wrkstr);

    wrkstr:= inttohex(ll);

    While wrkstr[1] = '0' Do
      Delete(wrkstr, 1, 1);

    Result:= wrkstr;

End;

Function mirt(Name: String): String;
Begin

    If Name = '' Then
      exit;

    Result:= trimleft(Name);
End;

Function copies(s: Char; nm: Byte): String;
Var
    st: String;
    a:  Byte;

Begin

    st:= '';

    For a:= 1 To nm Do
      st:= st + s;

    copies:= st;
End;

Function PadLeft(St: String; Size: Byte; Pad: Char): String;
Var
    temp: String;

Begin
    temp:= '';
    Fillchar(Temp[1], Size, Pad);
    setlength(Temp, Size);

    If Length(St) <= Size Then
      Move(St[1], Temp[1], length(St))
    Else
      Move(St[1], Temp[1], size);

    PadLeft:= Temp;
End;

Function PadCenter(St: String; Size: Byte; Pad: Char): String;
Var
    temp: String;
    L:    Byte;

Begin
    temp:= '';
    Fillchar(Temp[1], Size, Pad);
    setlength(Temp, Size);
    L:= length(St);

    If L <= Size Then
      Move(St[1], Temp[((Size - L) div 2) + 1], L)
    Else
      Move(St[((L - Size) div 2) + 1], Temp[1], Size);

    PadCenter:= temp;
End; {center}

Function PadRight(St: String; Size: Byte; Pad: Char): String;
Var
    temp: String;
    L:    Integer;

Begin
    Temp:= copies(pad, Size);
    L:= length(St);

    If L <= Size Then
      Move(St[1], Temp[succ(Size - L)], L)
    Else
      Move(St[1], Temp[1], size);

    PadRight:= Temp;
End;

Function tab(n: Integer): String;
Begin
    tab:= copies(' ', n);
End;

Function stripto(Var st: String; schar: Char): String;
Var
    a: Byte;

Begin

    a:= pos(schar, st);

    If a <> 0 Then
    Begin
      stripto:= copy(st, 1, a - 1);
      Delete(st, 1, a);
      remainder:= st;
    End
    Else
    Begin
      stripto:= st;
      st:= '';
    End;

End;


Function proper(Switch: String): String;
Var
    NextUp: Boolean;
    n:      Integer;
Begin
    switch:= lowercase(switch);
    NextUp:= True;

    For N:= 1 To Length(switch) Do
    Begin
      If NextUp = True Then
        switch[N]:= UpCase(switch[N]);

      If Switch[N] in ['!', '@', '#', '$', '%', '^', '&', '*', '(',
        ')', '-', '_', '=', '+', '[', '{', ']', '}', ';', ':', '''',
        '"', '`', '~', '\', '|', ',', '<', '.', '>', '/', '?', ' '] Then
        NextUp:= True
      Else
        NextUp:= False;
    End;

    proper:= Switch;

End;

Function words(St: String): Byte;
Var
    wc, n:  Byte;
    nextup: Boolean;

Begin
    wc:= 0;

    NextUp:= True;

    For N:= 1 To Length(St) Do
    Begin
      If NextUp = True Then
        Inc(wc);

      If St[N] in ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
        '-', '_', '=', '+', '[', '{', ']', '}', ';', ':', '''', '"',
        '`', '~', '\', '|', ',', '<', '.', '>', '/', '?', ' '] Then
        NextUp:= True
      Else
        NextUp:= False;
    End;

    words:= wc;

End;

Function wordn(St: String; nm: Byte): String;
Var
    wc, a, b, n, r: Byte;

Begin
    wc:= 0;
    n:= 1;
    a:= 0;
    r:= 0;

    If St = '' Then
    Begin
      Result:= '';
      exit;
    End;

    While N <= Length(St) Do
    Begin

      If wc = nm Then
        break;

      If St[N] in ['0'..'9', 'A'..'Z', 'a'..'z'] Then
      Begin
        a:= n;

        For b:= n + 1 To length(St) Do
          If not (St[b] in ['0'..'9', 'A'..'Z', 'a'..'z']) Then
          Begin
            n:= b - 1;
            r:= b - a;
            Inc(wc);
            break;
          End;

        If b > length(St) Then
        Begin
          n:= b - 1;
          r:= b - a;
          Inc(wc);
        End;

      End;

      Inc(n);
    End;

    If wc < nm Then
    Begin
      Result:= '';
      exit;
    End;

    Result:= copy(St, a, r);

End;

Function strip(sline: stype; schar: Char): String;
Var
    a: Byte;

Begin

    a:= pos(schar, sline);

    While a <> 0 Do
    Begin
      Delete(sline, a, 1);
      a:= pos(schar, sline);
    End;

    strip:= sline;

End;

Function stripit(St: String; src: String): String;
Var
    a: Byte;

Begin

    a:= pos(src, St);

    While a <> 0 Do
    Begin
      Delete(St, a, length(src));
      a:= pos(src, St);
    End;

    Result:= St;

End;

Function replace(sline: stype; schar, rchar: Shortstring): String;
Var
    a: Byte;

Begin

    a:= pos(schar, sline);

    While a <> 0 Do
    Begin
      Delete(sline, a, 1);
      insert(rchar, sline, a);
      a:= pos(schar, sline);
    End;

    replace:= sline;

End;

Function escape(sline: stype; schar, rchar: Shortstring): String;
Var
    a:     Byte;
    oline: String;

Begin

    If sline = '' Then
      exit;

    oline:= sline;

    a:= pos(schar, sline);

    While a <> 0 Do
    Begin
      If a = length(sline) Then
      Begin
        sline:= sline + #39;
        //delete(sline,a,length(schar));
        a:= 0;
        continue;
      End;

      Delete(sline, a, length(schar));
      insert(rchar, sline, a);
      a:= nextpos(schar, sline, a + length(schar) + 1);
    End;

    escape:= sline;

End;

Function I2Str(Number: Longint): String;
Begin
    Result:= IntToStr(Number);
End;

Function S2Rl(St: String): Real;
Var
    code: Integer;
    Temp: Real;

Begin
    If length(St) = 0 Then
      S2Rl:= 0
    Else
    Begin
      If copy(St, 1, 1) = '$' Then
        Delete(St, 1, 1);

      If Copy(St, 1, 1) = '.' Then
        St:= '0' + St;

      If (Copy(St, 1, 1) = '-') and (Copy(St, 2, 1) = '.') Then
        Insert('0', St, 2);

      If St[length(St)] = '.' Then
        Delete(St, length(St), 1);

      val(St, temp, code);

      If code = 0 Then
        S2Rl:= temp
      Else
        S2Rl:= 0;
    End;

End;

Function Rl2str(Number: Real; Decimals: Byte): String;
Var
    Temp: String;

Begin
    Str(Number: 20: Decimals, Temp);

    Repeat
      If copy(Temp, 1, 1) = ' ' Then
        Delete(Temp, 1, 1);

    Until copy(temp, 1, 1) <> ' ';

    If Decimals = Floating Then
    Begin
      Temp:= Strip(temp, '0');

      If Temp[Length(temp)] = '.' Then
        Delete(temp, Length(temp), 1);
    End;

    Rl2Str:= Temp;
End;

Function S2Int(St: String): Int64;
Var
    temp, code: Int64;

Begin
    If length(St) = 0 Then
      S2Int:= 0
    Else
    Begin
      S2Int:= strtoint64(st);
    End;

End;

Function S2Ln(St: String): Longint;
Var
    code: Integer;
    Temp: Longint;

Begin
    If length(St) = 0 Then
      S2Ln:= 0
    Else
    Begin
      val(St, temp, code);
      If code = 0 Then
        S2Ln:= temp
      Else
        S2Ln:= 0;
    End;

End;


Function trim(St: String): String;
Var
    ln: Byte;

Begin

    st:= SysUtils.Trimright(st);

    trim:= St;

End;

Function First_Capital_Pos(St: String): Byte;
Var
    StrPos: Byte;

Begin
    StrPos:= 1;

    While (StrPos <= length(St)) and ((St[StrPos] in ['A'..'Z']) = False) Do
      StrPos:= Succ(StrPos);

    If StrPos > length(St) Then
      First_Capital_Pos:= 0
    Else
      First_Capital_Pos:= StrPos;

End; {of func First_Capital_Pos}

Function First_capital(St: String): Char;
Var
    B: Byte;

Begin
    B:= First_Capital_Pos(St);

    If B > 0 Then
      First_Capital:= St[B]
    Else
      First_Capital:= #0;

End; {of func First_capital}

Function Last(N: Byte; St: String): String;
Var
    Temp: String;

Begin
    If N > length(St) Then
      Temp:= St
    Else
      Temp:= copy(St, succ(length(St) - N), N);

    Last:= Temp;
End;  {Func Last}

Function First(N: Byte; St: String): String;
Var
    Temp: String;

Begin
    If N > length(St) Then
      Temp:= St
    Else
      Temp:= copy(St, 1, N);

    First:= Temp;
End;  {Func First}

Function Upper(St: String): String;
Begin
    If St = '' Then
      exit;

    Upper:= uppercase(St);
End;  {Func Upper}

Function Lower(St: String): String;
Begin
    If St = '' Then
      exit;

    Lower:= lowercase(St);
End;  {Func Lower}

Function OverType(N: Byte; StrS, StrT: String): String;
    {Overlays StrS onto StrT at Pos N}
Var
    L:    Byte;
    StrN: String;

Begin
    L:= N + pred(length(StrS));

    If L < length(StrT) Then
      L:= length(StrT);

    If L > 254 Then
      Overtype:= copy(StrT, 1, pred(N)) + copy(StrS, 1, 255 - N)
    Else
    Begin
      StrN:= '';
      Fillchar(StrN[1], L, ' ');
      setlength(StrN, L);

      Move(StrT[1], StrN[1], length(StrT));
      Move(StrS[1], StrN[N], length(StrS));
      OverType:= StrN;
    End;

End;  {Func OverType}

Function NextPos(C: Shortstring; St: String; Startat: Word): Integer;
Var
    slen, n: Word;

Begin
    Result:= pos(st, startat);
    If startat >= length(St) Then
    Begin
      Result:= 0;
      exit;
    End;

    Result:= pos(st, startat);

End;

Function LastPos(C: Shortstring; St: String): Byte;
Var
    I: Byte;

Begin
    I:= succ(Length(St));

    Repeat
      I:= Pred(I);
    Until (I = 0) or (St[I] = C);

    LastPos:= I;
End;  {Func LastPos}

Function LocWord(StartAT, Wordno: Byte; St: String): Byte;
    {local proc used by PosWord and Extract word}
Var
    W: Integer;
    Spacebefore: Boolean;

Begin
    If (St = '') or (wordno < 1) or (StartAT > length(St)) Then
    Begin
      LocWord:= 0;
      exit;
    End;

    SpaceBefore:= True;
    W:= 0;
    StartAT:= pred(StartAT);

    While (W < Wordno) and (StartAT <= length(St)) Do
    Begin
      StartAT:= succ(StartAT);

      If SpaceBefore and (St[StartAT] <> ' ') Then
      Begin
        W:= succ(W);
        SpaceBefore:= False;
      End
      Else
      If (SpaceBefore = False) and (St[StartAT] = ' ') Then
        SpaceBefore:= True;
    End;

    If W = Wordno Then
      LocWord:= StartAT
    Else
      LocWord:= 0;

End;

Function PosWord(Wordno: Byte; St: String): Byte;
Begin
    PosWord:= LocWord(1, wordno, St);
End;  {Func Word}

Function WordCnt(St: String): Byte;
Begin
    WordCnt:= Words(St);
End;

Function GetWords(StartWord, NoWords: Byte; St: String): String;
Var
    Start, finish: Integer;

Begin
    If St = '' Then
    Begin
      GetWords:= '';
      exit;
    End;

    Start:= LocWord(1, StartWord, St);

    If Start <> 0 Then
      finish:= LocWord(Start, succ(NoWords), St)
    Else
    Begin
      getwords:= '';
      exit;
    End;

    If finish = 0 Then {5.02A}
      finish:= succ(length(St));

    Repeat
      finish:= pred(finish);
    Until St[finish] <> ' ';

    getWords:= copy(St, Start, succ(finish - Start));
End;  {Func getwords}

Function DateNow: Shortstring;
Var
    yr, mn, dy: Word;

Begin
    decodedate(now, yr, mn, dy);

    Result:= i2str(mn) + '/' + i2str(dy) + '/' + i2str(yr);

End;

Function YearNow: Shortstring;
Var
    yr, mn, dy: Word;

Begin
    decodedate(now, yr, mn, dy);

    Result:= i2str(yr);

End;

Function MonthNow: Word;
Var
    yr, mn, dy: Word;

Begin
    decodedate(now, yr, mn, dy);

    Result:= mn;

End;

Function TimeNow: Shortstring;
Var
    hr, min, sec, ms: Word;

Begin
    decodetime(now, hr, min, sec, ms);

    Result:= i2str(hr) + ':' + i2str(min);

End;

Function ThisMonth: Shortstring;
Var
    yr, mn, dy: Word;
    mnth: Array[1..12] Of String = ('Jan', 'Feb', 'Mar', 'Apr', 'May',
      'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Mov', 'Dec');

Begin
    decodedate(now, yr, mn, dy);

    Result:= mnth[mn];

End;

{--------------------------------------------------------------
                        Justify
    Pads a string as needed to get the required results

    none - does nothing
    left - pads everything to the left of st with spaces to make it len length
    right - pads everything right of st to make len length
    center - centers st with spaces added to the left of st to fit in len length

    Output
    Returns the justified string padded with spaces as needed to len length
---------------------------------------------------------------}
Function justify(st: Shortstring; direction: Byte; len: Byte): Shortstring;
Var
    ln, hx: Smallint;
    tmp:    String;

Begin

    Case direction Of
      jnone:
      Begin
        ln:= length(st);

        If ln < len Then
          st:= st + copies(' ', len - ln);

        justify:= st;
        exit;
      End;

      jleft:
      Begin
        ln:= length(st);

        hx:= 1;

        If ln < len Then
          st:= st + copies(' ', len - ln);

        justify:= st;
        exit;
      End;

      jright:
      Begin
        tmp:= st;
        tmp:= strip(tmp, ' ');

        ln:= length(st);

        hx:= (len - ln) - 1;

        If hx < 1 Then
          hx:= 1;

        st:= copies(' ', hx) + tmp;
        justify:= st;
      End;

      jcenter:
      Begin
        tmp:= st;
        ln:= length(tmp);

        hx:= (len - ln) div 2;

        st:= copies(' ', hx) + st;
        ln:= length(st);

        st:= st + copies(' ', len - ln);

        justify:= st;
        exit;
      End;

    End;

End;

End.
