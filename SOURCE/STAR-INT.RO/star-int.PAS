{$S-}
{$R-}
{$G+}
{$D-}
uses crt,textgraf,WOWTPU,WOWCONST;
type
  lpi = array[0..2] of byte;
  lp = array[0..255] of lpi;
var
  f : file;
  k,i,j,x,y,anz : integer;
  n : word;
  b : byte;
  l : lp;
  p : vgacolors;
  s : string;
  c : array[0..130] of byte;
  ch:char;
  sx : array[0..300] of integer;
  sy : array[0..300] of integer;
  sc : array[0..300] of integer;
  sc2: array[0..300] of integer;
  font : array[0..80, 0..7, 0..7] of byte;
  lauf : string;
  lx,li: integer;
   SBPort: word;
   flag:integer;
procedure writeline(wlx,wly : integer; wls : string);
begin
  for i:=1 to length(wls) do begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
        if ord(wls[i])<>32 then
        mem[$A000: (wly+y) * word(320) + wlx+x+(i-1)*8]:=font[ord(wls[i])-64,x,y]
      end;
    end;
  end;
end;
function Key : boolean;
var flag : boolean;
begin
  asm
    mov  Flag,0
    in   al,$60
    test al,128
    jne  @@KeineTaste
    mov  Flag,1
  @@KeineTaste:
  end;
  Key:=Flag;
end;
begin
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

  assign(f,'star-int.004');
  reset(f);
  blockread(f,c,1,n);
  for i:=0 to 130 do
  begin
  mem[$A000: i]:= c[3+i];
  end;
  blockread(f,mem[$A007:13],500,n);
  close(f);
  for j:=0 to 1 do begin
  for i:=0 to 39 do begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
      font[i+j*40,x,y]:= mem[$A000: (y+j*8) * word(320) + x+i*8];
      end;
    end;
  end;
  end;

  assign(f,'star-int.001');
  reset(f);
  blockread(f,l,sizeof(l),n);
  for i:=0 to 255 do
  begin
    for j:=0 to 2 do
    begin
      p[i,j]:=l[i+1,j];
    end;
  end;
  close(f);

  assign(f,'star-int.003');
  reset(f);
  blockread(f,l,sizeof(l),n);
  for i:=208 to 223 do
  begin
    for j:=0 to 2 do
    begin
      p[i,j]:=l[i+1-208,j];
    end;
  end;
  close(f);

  assign(f,'star-int.002');
  reset(f);
  blockread(f,c,1,n);
  for i:=0 to 130 do
  begin
  mem[$A000: i]:= c[3+i];
  end;
  blockread(f,mem[$A007:13],500,n);
  close(f);

  writeline(74,90, '      star intro');
  writeline(74,106,'    code gfx music');
  writeline(74,122,'   by stefan koelle');
  writeline(78,138,'    press any key');

  randomize;
  for x:=0 to 150 do
  begin
    sx[x] := random(319);
    repeat
    k:=0;
    sy[x] := random(199)+1;
    for i:=0 to x-1 do
    begin
      if sy[i]=sy[x] then k:=1;
    end;
    for i:=x+1 to 150 do
    begin
      if sy[i]=sy[x] then k:=1;
    end;
    until k=0;
    sc[x] := random(3)+1;
    sc2[x]:= mem[$A000: sy[x] * word(320) + sx[x]];
  end;

  setvgacolors(p);
  SBPort:=IdentifySB;
  if SBPort=0 then begin   (* bei IdentifySB=0 -> Keine Soundblaster *)
    SBPort:=$42;           (* Lautsprecherausgabe *)
  end;
  for i:=1 to paramcount do
  if paramstr(i)='-p' then SBPort:=$42;
  if sbport=$42 then begin
    flag:=doit('star-int.005',sbport,0,21000);
  end else begin
    flag:=doit('star-int.005',sbport,0,16000);
  end;
  repeat
    for x:=0 to 150 do begin
     mem[$A000: sy[x] * word(320) + sx[x]]:= sc2[x];
     sx[x]:=sx[x]+SC[X];
     if sx[x]>319 then
     begin
       sx[x]:=0;
       sc[x]:=random(3)+1;
     end;
     sc2[x]:=mem[$A000: sy[x] * word(320) + sx[x]];
     if mem[$A000: sy[x] * word(320) + sx[x]]=0 then
     begin
     mem[$A000: sy[x] * word(320) + sx[x]]:= (-sc[x]*3)+27;
     end;
    end;
  until key;
  ch:=readkey;
  endit;
  for i:=0 to 31999 do begin
    mem[$A000:i]:=0;
  end;
  for i:=0 to 31999 do begin
    mem[$A000:i+32000]:=0;
  end;
  TEXTMODE(co80);
end.