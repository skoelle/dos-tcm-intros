uses WOWCONST, WOWTPU,crt,textgraf,amn;
type
  lpi = array[0..2] of byte;
  lp = array[0..256] of lpi;
const col=30;
var
  f : file;
  k,i,j,x,y,men,mm : integer;
  n,m : word;
  b : byte;
  l : lp;
  p : vgacolors;
  s : string;
  c : array[0..130] of byte;
  ch:char;
  logo:array[0..80,0..240] of char;
  SBPort: word;
  flag:integer;
  sinus:array[0..120] of integer;
  bo,ende:boolean;
  font : array[0..80, 0..7, 0..7] of byte;
  leer:array[1..8*320] of char;
CONST text:array[1..18] of string=('TRANCEMISSION PRESENTS','OUR NEW MENU INTRO',
                                  'CODE AND GFX BY STEFAN KOELLE',
                                  'RELEASE 1992 ON DOS PC',
                                  'THIS COULD BE USED BEFORE DEMOS',
                                  'TO CHANGE SETTINGS OF THE DEMO',
                                  'MENU WAS NEVER COMPLETED',
                                  'CODED IN TURBO PASCAL',
                                  'AND INLINE ASSEMBLER',
                                  'BY STEFAN KOELLE',
                                  'LOGO AND FONT ALSO DESIGNED',
                                  'BY STEFAN KOELLE',
                                  'GREETINGS TO THE FOLLOWING',
                                  'MATTHIAS, MILKRUN, MAJIC',
                                  'MANY THANKS FOR READING THIS FAR',
                                  'STILL READING, YEAH',
                                  'REALLY PROUD OF IT',
                                  '... TAKE CARE AND ENJOY ...');
      menu:array[1..3] of string=('        TOGGLE: YES',
                                  '     OPTION MENU ITEM',
                                  '           EXIT');
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
procedure writeline(wlx,wly : integer; wls : string);
var i,x,y:integer;
begin
  for i:=1 to length(wls) do begin
    if ord(wls[i])<>32 then begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
        if font[ord(wls[i])-64+32,x,y]<>0 then
        mem[$A000: (wly+y) * word(320) + wlx+x+(i-1)*8]:=font[ord(wls[i])-64+32,x,y]
      end;
    end;
    end;
  end;
end;
begin
  DirectVideo:= false;
  case InitTextGraf of
    -1: begin
          writeln(' Dieses Programm l„uft auf Ihrer Grafikkarte leider nicht!');
          halt(1);
        end;
     1: begin
          writeln(' Zu wenig Speicher!');
          halt(2);
        end;
  end;
  GrafikMode($13);
  for i:=0 to 255 do
  begin
    for j:=0 to 2 do
    begin
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
  for i:=0 to 80 do
  move(mem[$A000:320*i+43],logo[i],240);
  for j:=0 to 1 do begin
  for i:=0 to 39 do begin
    for x:=0 to 7 do begin
      for y:=0 to 7 do begin
      font[i+j*40,x,y]:= mem[$A000: (y+j*8+98) * word(320) + x+i*8];
      end;
    end;
  end;
  end;
  SBPort:=IdentifySB;
  if SBPort=0 then begin   (* bei IdentifySB=0 -> Keine Soundblaster *)
    SBPort:=$42;           (* Lautsprecherausgabe *)
  end;
  for i:=1 to paramcount do if paramstr(i)='-p' then SBPort:=$42;
  for i:=0 to 31999 do
  mem[$A000:i]:=0;
  for i:=0 to 31999 do
  mem[$A000:i+32000]:=0;
  for i:=0 to 320 do
  sinus[i]:=round(sin(Pi/24*i+1)*5)+46;      (* round(sin(i*6.2)*5)+46 *)
  move(mem[$A000:191*320],leer,8*320);

  move(mem[seg(tcmpal): ofs(tcmpal)],l,sizeof(l));
  for i:=0 to 255 do
  begin
    for j:=0 to 2 do
    begin
      p[i,j]:=l[i,j];
    end;
  end;
  setvgacolors(p);
  for i:=0 to 8*320-1 do
  mem[$A000:i+320*164]:=col;

  writeline(125,114,'PRESENTS');
  writeline(55,124,'      THE MENU INTRO');
  for i:=1 to 3 do
  writeline(55,134+i*10,menu[i]);
  flag:=doit('menu-int.res',sbport,0,12000);
  bo:=true;
  n:=0;
  m:=0; (* wobble style *)
  mm:=0;
  writeline(159-length(text[1])*4,191,text[1]);
  k:=2;
  ende:=false;
  men:=3;

  ledz:=0;
  repeat
    if mm>2 then begin 
		mm:=0;
	  if bo then begin
		inc(n,1);
		if n>39 then begin
		bo:=false;
		end;
	  end else begin
		dec(n,1);
		if n<1 then begin
		bo:=true;
		end;
	  end;
  end else begin
	  inc(mm,1);
  end;
  if m>46 then begin
	  m:=0;
	end else begin
	  inc(m,1);
  end;
	  
  if ledz>20000 then begin
    ledz:=0;
    move(leer,mem[$A000:191*320],8*320);
    writeline(159-length(text[k])*4,191,text[k]);
    inc(k);
    if k>18 then k:=1;
  end;
  for i:=3 to 74 do
  move(logo[i],mem[$A000: 320*(n+i)+sinus[i+m]],226);
  if keypressed then begin
    ch:=readkey;
    if ch=#0 then begin
      ch:=readkey;
      if (ch=#80) and (men<3) then begin
        move(leer,mem[$A000:(134+men*10)*320],8*320);
        writeline(55,134+men*10,menu[men]);
        inc(men);
        for i:=0 to 8*320-1 do
        mem[$A000:i+320*(134+men*10)]:=col;
        writeline(55,134+men*10,menu[men]);
      end;
      if (ch=#72) and (men>1) then begin
        move(leer,mem[$A000:(134+men*10)*320],8*320);
        writeline(55,134+men*10,menu[men]);
        dec(men);
        for i:=0 to 8*320-1 do
        mem[$A000:i+320*(134+men*10)]:=col;
        writeline(55,134+men*10,menu[men]);
      end;
    end else begin
      if ch=#27 then ende:=true;
      if ch=#13 then begin
        case men of
        1:begin
            if menu[1,17]='Y' then begin
              menu[1,17]:=' ';
              menu[1,18]:='N';
              menu[1,19]:='O';
            end else begin
              menu[1,17]:='Y';
              menu[1,18]:='E';
              menu[1,19]:='S';
            end;
            for i:=0 to 8*320-1 do
            mem[$A000:i+320*(134+men*10)]:=col;
            writeline(55,134+men*10,menu[men]);
          end;
        2:begin
          end;
        3:ende:=true;
        end;
      end;
    end;
  end;
  until ende;
  endit;
  for i:=0 to 31999 do
  mem[$A000:i]:=0;
  for i:=0 to 31999 do
  mem[$A000:i+32000]:=0;
  textmode(CO80);
end.