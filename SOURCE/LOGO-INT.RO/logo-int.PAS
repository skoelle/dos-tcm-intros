{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$M 16384,0,655360}
uses crt,textgraf,WOWTPU,WOWCONST,amn;
type
  lpi = array[0..2] of byte;
  lp = array[0..255] of lpi;
var
  speed:integer;
  k,i,j,x,y,anz,h1,h2,texti : integer;
  l : lp;
  p : vgacolors;
  s : string;
  ch:char;
  textp:boolean;
  font : array[0..80, 0..7, 0..7] of byte;
  font2: array[0..80,0..15,0..15] of byte;
  SBPort: word;
  flag:integer;
  lint:longint;
const text:array[1..15] of string = ('''  TCM  PRESENTS   ''',
                                     '''   A NEW INTRO    ''',
                                     '''CODE/GFX/MUSIC BY ''',
                                     '''  STEFAN KOELLE   ''',
                                     '''  RELEASED 1993   ''',
                                     ''' IN TURBO PASCAL  ''',
                                     '''  AND ASSEMBLER   ''',
                                     '''   GREETINGS TO   ''',
                                     '''MATTHIAS AND MAJIC''',
                                     '''    AND MILKRUN   ''',
                                     '''  INTRO KEYS ARE: ''',
                                     '''  VOLUMECONTROL:  ''',
                                     '''  PLUS AND MINUS  ''',
                                     '''SPEEDCTRL: S AND A''',
                                     '''     BYE  BYE     ''');
procedure writeline(wlx,wly : integer; wls : string);
var i,x,y:integer;
begin
  for i:=1 to length(wls) do begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
        if ord(wls[i])<>32 then
        mem[$A000: (wly+y) * word(320) + wlx+x+(i-1)*8]:=font[ord(wls[i])-32,x,y]
      end;
    end;
  end;
end;
procedure writeline2(wlx,wly : integer; wls : string);
var i,x,y:integer;
begin
  for i:=1 to length(wls) do begin
    for x:=0 to 15 do begin
      for y:=0 to 15 do begin
        if ord(wls[i])=32 then wls[i]:='*';
        mem[$A000: (wly+y) * word(320) + wlx+x+(i-1)*16]:=font2[ord(wls[i])-32,x,y]
      end;
    end;
  end;
end;
procedure CLI; inline( $FA );                { Interrupts unterdrÅcken }
procedure STI; inline( $FB );             { Interrupts wieder erlauben }
begin
  CLI;
  case InitTextGraf of
     1: begin end;
  end;
  GrafikMode($13);
  for i:=0 to 31999 do begin
    mem[$A000:i]:=0;
  end;
  for i:=0 to 31999 do begin
    mem[$A000:i+32000]:=0;
  end;
  for i:=0 to 255 do begin
    for j:=0 to 2 do begin
      p[i,j]:=0;
    end;
  end;
  setvgacolors(p);
  for i:=0 to 31999 do
  begin
  mem[$A000: i]:= mem[seg(tcmamn): ofs(tcmamn)+i+3];
  end;
  for i:=0 to 31999 do
  begin
  mem[$A000: i+32000]:= mem[seg(tcmamn): ofs(tcmamn)+i+3+32000];
  end;
  for j:=0 to 1 do begin
  for i:=0 to 39 do begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
      font[i+j*40,x,y]:= mem[$A000: (y+j*8+81) * word(320) + x+i*8];
      end;
    end;
  end;
  end;
  for j:=0 to 2 do begin
  for i:=0 to 19 do begin
    for x:=0 to 15 do begin
      for y:=0 to 15 do begin
      font2[i+j*20,x,y]:= mem[$A000: (y+j*16+99) * word(320) + x+i*16];
      end;
    end;
  end;
  end;

  move(mem[seg(tcmpal): ofs(tcmpal)],l,sizeof(l));
  for i:=0 to 79 do begin
    move(mem[$A000:320*(80-i)],mem[$A000:320*(80-i+50)],320);
  end;
  for i:=0 to 50 do
  for j:=0 to 319 do
  mem[$A000:i*320+j]:=0;
  for i:=130 to 199 do
  for j:=0 to 319 do
  mem[$A000:i*320+j]:=0;
  for j:=0 to 2 do p[0,j]:=l[1,j];
  for x:=1 to 80 do begin
  for i:=1 to 255 do
  begin
    for j:=0 to 2 do
    begin
      if p[i,j]<l[i+1,j] then inc(p[i,j]);
    end;
  end;
  setvgacolors(p);
  end;
  STI;

  CLI;
  i:=51;j:=102;
  repeat
  dec(i);inc(j);
  move(mem[$A000:320*(i+1)],mem[$A000:320*i],320*52);
  move(mem[$A000:320*(j-1)],mem[$A000:320*j],320*30);
  until i<=0;
  STI;

  SBPort:=IdentifySB;
  if SBPort=0 then begin   (* bei IdentifySB=0 -> Keine Soundblaster *)
    SBPort:=$42;           (* Lautsprecherausgabe *)
  end;
  if SBPort=$42 then begin
  flag:=doit('logo-int.ovl',sbport,0,21000);
  end else begin
  flag:=doit('logo-int.ovl',sbport,0,12000);
  end;

  writeline(65,60,'   = TRANCEMISSION =    ');
  writeline(65,68,'  = PROUDLY PRESENTS =  ');
  writeline(65,76,' ---------------------- ');
  writeline(65,84,'     THE LOGO INTRO     ');
 writeline(65,100,'   CODE GFX MUSIC BY    ');
 writeline(65,108,'     STEFAN KOELLE      ');
 writeline(65,124,'     RELEASED 1993      ');
 writeline(65,132,'    ON PC 486 DX 50     ');

  writeline(65,52,'************************');
  writeline(65,140,'************************');
  for i:=1 to 11 do writeline(65,52+(8*i),'*                      *');

  writeline2(0,185,text[1]);
{    mem[$A000:round(sin(i*6)*90)+320*(50+i)+150]:=66;}
  x:=0;
  ch:='A';
  speed:=1;
  texti:=1;
  ledz:=10000;
  repeat
    inc(x,speed);
    if x>375 then x:=1;
    y:=round(sin(x*6.3)*30)+50;
    for i:=7 to 16 do begin
    h1:=(i+140-y)*320;
    h2:=(-i+155-y)*320;
    for j:=0 to 63 do begin
    if i=16 then begin
    mem[$A000:h1+j]:=0;
    mem[$A000:h2+j]:=0;
    end else begin
    mem[$A000:h1+j]:=i+31;
    mem[$A000:h2+j]:=i+31;
    end;
    end;
    for j:=319-60 to 319 do begin
    if i=16 then begin
    mem[$A000:h1+j]:=0;
    mem[$A000:h2+j]:=0;
    end else begin
    mem[$A000:h1+j]:=i+31;
    mem[$A000:h2+j]:=i+31;
    end;
    end;
    end;
    if textp and (ledz<10000) then begin
      inc(texti);
      writeline2(0,185,text[texti]);
      if texti>=15 then texti:=0;
      textp:=false;
    end;
    if (ledz>10000) and (not textp) then textp:=true;
  if keypressed then begin
   ch:=readkey;
   case ch of
    's','S':begin
        inc(speed);
        if speed>20 then speed:=20;
        end;
    'a','A':begin
        dec(speed);
        if speed<1 then speed:=1;
        end;
    '+':begin
        lint:=volume;
        inc(lint,5);
        if lint>256 then volume:=256 else volume:=lint;
        end;
    '-':begin
        lint:=volume;
        dec(lint,5);
        if lint<0 then volume:=0 else volume:=lint;
        end;
   end;
  end;
  until (ch=#27) or (ch=#13) or (ch=' ');
  endit;
  CLI;
  i:=0;j:=155;
  repeat
  inc(i);dec(j);
  move(mem[$A000:320*(i-1)],mem[$A000:320*i],320*50);
  move(mem[$A000:320*181],mem[$A000:320*(i-1)],320);
  move(mem[$A000:320*(j+1)],mem[$A000:320*j],320*30);
  for x:=1 to 3 do begin
  for y:=1 to 16 do begin
  mem[$A000:320*(200-y)+x+(i-1)*3]:=0;
  mem[$A000:320*(200-y)+319-(x+(i-1)*3)]:=0;
  end;end;
  until i>=53;
  STI;
  for x:=1 to 80 do begin
  for i:=0 to 255 do
  begin
    for j:=0 to 2 do
    begin
      if p[i,j]>0 then dec(p[i,j]);
    end;
  end;
  setvgacolors(p);
  end;
  for i:=0 to 31999 do begin
    mem[$A000:i]:=0;
  end;
  for i:=0 to 31999 do begin
    mem[$A000:i+32000]:=0;
  end;
  TEXTMODE(co80);
end.