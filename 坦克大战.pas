PROGRAM The_War_of_Tank_____By_Fallen_Breath;
                           
{$inline on}

USES Crt,Dos,SysUtils,Math,Windows,BetterInput,MmSystem;

CONST
/////////////////////////Program Information/////////////////////////

      AppName                  = '坦克大战';
      Version                  = 'V1.0.0_pre1';
      ApplicationVersion       = 'Beta 1.0.0+';
      Date                     = '2017.11.26';

{$I 定义.inc}

procedure F4;
begin
  write('Press F4 here!');
  explode(maxx div 2,maxy div 2,maxexplodehard,0,1);
end;

function random(x:longint):longint;
begin
  exit(system.random(x));
end;
function random(l,r:longint):longint;
begin
  exit(l+random(r-l+1));
end;

function gettick:int64;
var t:SYSTEMTIME;
    u:int64;
begin
  GetLocalTime(t);
  u:=1;
  with t do
  begin
    gettick:=u*wMilliseconds+u*1000*wSecond+u*1000*60*wMinute;
    gettick:=gettick+u*1000*60*60*wHour+u*1000*60*60*24*wDay;
  end;
end;

procedure gt(var n:Ttime);inline;
begin
  n.time:=gettick;
  if gaming then n.tick:=tick;
end;

function td(o,n:Ttime):int64;
begin
  exit(n.time-o.time);
end;

function color(now,max:longint):longint;
begin
  if (now<0) or (max=0) then exit(12);
  case trunc(now/max*100) of
    0..25:color:=12;
    26..50:color:=14;
    51..75:color:=11;
    76..100:color:=10;
  end;
end;

procedure delay(x:longint);
var st:longint;
begin
  st:=getmscount;
  while (getmscount-st<x) and (keypressed=false) do;
  if keypressed then readkey;
end;

function lenlimit(s:string;max:longint):string;
var l:longint;
begin
  if length(s)<=max then exit(s);
  l:=length(s);
  exit(copy(s,1,l-4-(l-max))+'..'+copy(s,l-1,2));
end;

function getastr(len:longint):string;
var i:longint;
begin
  getastr:='';
  for i:=1 to len do
    getastr:=getastr+chr(random(256));
end;

procedure runmusic;
var s,cmd,ali:string;
    ret,id:longint;
begin
  id:=0;
  while true do
  begin
    while musicthreadok do;
    s:=musicparameter;
    musicthreadok:=true;

    inc(id);
    str(id,ali);
    ali:='music'+ali;

    cmd:='open '+s+' alias '+ali+chr(0);      
    ret:=mciSendString(pchar(@cmd[1]),nil,0,0);

    if (ret<>0) then continue;
    cmd:='play '+ali+chr(0);
    ret:=mciSendString(pchar(@cmd[1]),nil,0,0);

    if (ret<>0) then
    repeat
      break;
      mciGetErrorString(ret,pchar(@s[1]),100);
      tb(0); tc(7); clrscr;
      write('cnt=',musicaliascnt,' error=',ret,' str=',pchar(@s[1]));
    until true;
    if (id>100) then
    begin
      str(id-50,s);
      cmd:='close music'+s+chr(0);
      mciSendString(pchar(@cmd[1]),nil,0,0);
    end
    else inc(musicaliascnt);
  end;
  exitthread(0);
end;

procedure playmusic(s:string);//inline;
begin
  if (setting.musicon=0) then exit;
  musicparameter:=s;
  musicthreadok:=false;
//  while (musicthreadok=false) do;
end;

function chooseone:longint;
begin
  chooseone:=betterinput.chooseone(choosestr);
  playmusic('music\click.wav');
end;

procedure findfiles(fn:string;var res:findfilesres);
var i:longint;
    r:tsearchrec;

   procedure qsort(l,r:longint);
   var i,j:longint;
       x,y:string;
   begin
     i:=l;
     j:=r;
     x:=res.filenam[(l+r)div 2];
     repeat
       while res.filenam[i]<x do inc(i);
       while res.filenam[j]>x do dec(j);
       if i<=j then
       begin
         y:=res.filenam[i];
         res.filenam[i]:=res.filenam[j];
         res.filenam[j]:=y;
         inc(i);
         dec(j);
       end;
     until i>j;
     if i<r then qsort(i,r);
     if l<j then qsort(l,j);
   end;

begin
  with res do
  begin
    filenum:=0;
    maxlen:=0;
    i:=sysutils.findfirst(fn,faanyfile,r);
    while I=0 do
    begin
      inc(filenum);
      filenam[filenum]:=r.name;
      maxlen:=max(maxlen,length(filenam[filenum]));
      i:=sysutils.findnext(r);
    end;
    sysutils.findclose(r);
  end;
  if res.filenum=0 then exit;
  qsort(1,res.filenum);
end;

function getfx(x1,y1,x2,y2:longint):longint; //(x1,y1)->(x2,y2)
begin
  if (x1=x2) and (y1=y2) then exit(random(0,3));
  if x2=x1 then
  begin
    if y2>y1 then exit(2)
     else exit(0);
  end
   else if y1=y2 then
   begin
     if x2>x1 then exit(1)
      else exit(3);
   end;

  if x1>x2 then
  begin
    if y1>y2 then
    begin
      if (y1-y2)>(x1-x2) then exit(0)
       else if (y1-y2)=(x1-x2) then exit(random(3,4) mod 3)
        else exit(3);
    end
     else begin
       if (y2-y1)>(x1-x2) then exit(2)
        else if (y1-y2)=(x1-x2) then exit(random(2,3))
         else exit(3);
     end;
  end
   else begin
     if y1>y2 then
     begin
       if (y1-y2)>(x2-x1) then exit(0)
        else if (y1-y2)=(x2-x1) then exit(random(0,1))
         else exit(1);
     end
      else begin
        if (y2-y1)>(x2-x1) then exit(2)
         else if (y1-y2)=(x2-x1) then exit(random(1,2))
          else exit(1);
      end;
   end;
end;
function getfx(x1,x2:Tpos):longint;
begin
  exit(getfx(x1.x,x1.y,x2.x,x2.y));
end;
function getfx(x1:Tpos;x2,y2:longint):longint;
begin
  exit(getfx(x1.x,x1.y,x2,y2));
end;
function getfx(x1,y1:longint;x2:Tpos):longint;
begin
  exit(getfx(x1,y1,x2.x,x2.y));
end;

function getmobharmtype(id:longint):longint;
begin
  case id of
    1,3:exit(1);
    2:exit(2);
    4:exit(3);
  end;
end;
function getmobharmtype(who:Ttank):longint;
begin
  exit(getmobharmtype(who.id));
end;

procedure print(x,y,tbc,tcc:longint;st:string);
begin
  if inmap(x,y)=false then
  begin
    clrscr;tc(15);tb(0);
    writeln('Error!');
    writeln('Wrong x or y in procedure print');
    writeln('x=',x,'  y=',y);
    delay(2000);
    halt;
  end;
  if tbc=-1 then tbc:=blockbackground[mm.map[x,y].id];

   with newsc[x,y] do
   begin
    // gotoxy(x*2+1,y+1);
     bg:=tbc;col:=tcc;
     ch:=st;
   end;//end with
end;
procedure print(zb:Tpos;tbc,tcc:longint;st:string);
begin
  print(zb.x,zb.y,tbc,tcc,st);
end;

function inmap(x,y:longint):boolean;
begin
  if (x<1) or (x>maxx) or (y<1) or (y>maxy) then exit(false);
  exit(true);
end;
function inmap(zb:Tpos):boolean;
begin
  exit(inmap(zb.x,zb.y));
end;

function can(x,y,typ:longint):boolean; //typ:1:坦克 2:mob
var i:longint;
begin
  if inmap(x,y)=false then exit(false);
  with mm.map[x,y] do
  begin
    if typ=2 then exit(id in cangoblock_mob);
    if (hitbox[x][y]>=tick*2) and (tick>0) then
    begin
      if (hitbox[x][y]=tick*2) then exit(false);
      exit(true);
    end;
    hitbox[x][y]:=tick*2;
    for i:=1 to maxai do
     with ai[i] do
      if (zb.x=x)and (zb.y=y) then
      begin
        if living then exit(false)
      //   else if tick-ldt.tick<dyinglast then exit(false);
      end;
    for i:=1 to setting.playernum do
     with player[i] do
      if (zb.x=x)and (zb.y=y) then
      begin
        if living then exit(false)
       //  else if tick-ldt.tick<dyinglast then exit(false);
      end;
    if id in cangoblock_tank=false then exit(false);
  end;
  if (tick>0) then hitbox[x][y]:=tick*2+1;
  exit(true);
end;
function can(zb:Tpos;typ:longint):boolean;
begin
  exit(can(zb.x,zb.y,typ));
end;

function whichmob(x,y:longint):longint;{exit -1:no}
var i,n:longint;
    a:array[1..maxmob] of integer;
begin
  n:=0;
  for i:=1 to maxmob do
   with mob[i] do
    if living then
      if (zb.x=x) and (zb.y=y) then
      begin
        inc(n);
        a[n]:=i;
      end;
  if n=0 then exit(-1);
  exit(a[random(1,n)]);
end;
function whichmob(zb:Tpos):longint;
begin
  exit(whichmob(zb.x,zb.y));
end;

function whichtank(x,y:longint):longint;{exit 0:no}
var i:longint;
begin
  for i:=1 to maxai do
   with ai[i] do
    if (zb.x=x) and (zb.y=y) then
     if living{ or (((tick-ldt.tick) mod dyingblinklast<=dyingblinklast div 2) and (tick<=ldt.tick+dyinglast)) }then exit(i);
  for i:=1 to maxplayer do
   with player[i] do
    if (zb.x=x) and (zb.y=y) then
     if living {or (((tick-ldt.tick) mod dyingblinklast<=dyingblinklast div 2) and (tick<=ldt.tick+dyinglast))} then exit(-i);
  exit(0);
end;
function whichtank(zb:Tpos):longint;
begin
  exit(whichtank(zb.x,zb.y));
end;

function ju(x1,y1,x2,y2:longint):longint;
begin
  exit(abs(x1-x2)+abs(y1-y2));
end;
function ju(a,b:Tpos):longint;
begin
  exit(ju(a.x,a.y,b.x,b.y));
end;
function ju(a:Tpos;x,y:longint):longint;
begin
  exit(ju(a.x,a.y,x,y));
end;
function ju(x,y:longint;a:Tpos):longint;
begin
  exit(ju(x,y,a.x,a.y));
end;

function findblock(did,isrnd:longint):Tpos;//idrnd 1:random
var i,j,n:longint;
    a:array[0..maxblock] of Tpos;
begin
  n:=0;
  a[0].x:=-1;
  a[0].y:=-1;
  for i:=1 to maxx do
   for j:=1 to maxy do
    if mm.map[i,j].id=did then
    begin
      inc(n);
      a[n].x:=i;
      a[n].y:=j;
    end;
  if n=0 then exit(a[0]);
  if isrnd=0 then exit(a[1]);
  exit(a[random(1,n)]);
end;

procedure destroy(x,y,fromx,fromy,harm,ht:longint);
var t:longint;
    zb:Tpos;
begin
  if inmap(x,y)=false then
  begin
    clrscr;tc(15);tb(0);
    writeln('Error!');
    writeln('Wrong x or y in procedure destroy');
    writeln('x=',x,'  y=',y);
    delay(2000);
    halt;
  end;
  with mm.map[x,y] do
  begin
    if unbreakble then exit;
    if ht<>0 then
     if id in candestroyblock[ht]=false then exit;
   { if id in [10] then
     if ht=3 then exit;}
    dec(hard,harm);
    if id=4 then
     with playerflag do
       dec(hp,harm);
    if id=5 then
     with aiflag do
       dec(hp,harm);
    if ht<>3 then
    case id of
      1,2,6,7:playmusic('music\stone'+chr(random(4)+1+ord('0'))+'.wav');
      4,5:playmusic('music\wood'+chr(random(4)+1+ord('0'))+'.wav');
      8:playmusic('music\fuse.wav');
    end;
    if hard<=0 then
    begin
      case id of
        4:repeat
            gamelose:=true;gameendtick:=tick;
            init_tip('游戏失败',10,gamefinishtipshowlast);
            zb:=findblock(5,0);
            if zb.x=-1 then break;
            mm.map[zb.x,zb.y].unbreakble:=true;
          until true;
        5:repeat
            gamewin:=true;gameendtick:=tick;
            init_tip('游戏胜利',12,gamefinishtipshowlast);
            zb:=findblock(4,0);
            if zb.x=-1 then break;
            mm.map[zb.x,zb.y].unbreakble:=true;
          until true;
        8:repeat
            if (harm>TNTgenerateharmlimit) then break;
            t:=new_mob(x,y,-1,4,0);
            if ht=3 then
            begin
              mob[t].lst.tick:=tick-(random(6)+1)*TNTblinklast div 2+random(3)-1;
              mob[t].fx:=getfx(fromx,fromy,x,y);
            end
             else mob[t].speed:=maxlongint;
          until true;
      end;//end case
     // if id in candestroyblock[ht] then
      begin
        id:=0;
        print(x,y,blockbackground[id],15,blockchar[id,fx]);
      end;
    end;//end if destroyed
  end;
end;

procedure explode(mx,my,hard,fromwho,hurtfrom,nomusic:longint); //hard:1~15
var tmp:longint;
    explodeed:array[1..maxx,1..maxy] of boolean;
    candes:boolean;

   procedure bfs(x,y,hard:longint);
   type dl=record
             x,y,pre,h:integer;
           end;
   var i,ii,xx,yy,head,tail:longint;
       q:array[1..maxqueue] of dl;
       b:array[0..3] of boolean;

      procedure work(x,y,harm:longint);
      begin
        explodeed[x,y]:=true;
        hurt_mob(whichmob(x,y),mx,my,harm,3,fromwho);
        if candes=true then
         if inmap(mx,my) then
          if mm.map[mx,my].id in [3]=false then
          begin
            tmp:=whichtank(x,y);
            if (fromwho<>tmp) or (hurtfrom=1) then hurt_tank(tmp,harm,3,fromwho);
            destroy(x,y,mx,my,harm,3);
          end;
      end;

   begin;

     head:=0;tail:=1;
     q[tail].x:=x;q[tail].y:=y;q[tail].pre:=0;q[tail].h:=hard;
     if inmap(x,y) then
     begin
       work(x,y,explodeharm[hard]);
     end;
     while head<>tail do
     begin
       inc(head);
       fillchar(b,sizeof(b),true);
       for ii:=0 to 3 do
       begin
      //   write(candes);
         repeat
           i:=random(4);
         until b[i];
         b[i]:=false;
         xx:=q[head].x+gox[i];
         yy:=q[head].y+goy[i];
         if inmap(xx,yy)=false then continue;
         if explodeed[xx,yy] then continue;
         if (mm.map[xx,yy].hard>explodeharm[q[head].h]) or (mm.map[xx,yy].id in [0]+candestroyblock[3]-[3]=false)
         or ((candes=false) and (mm.map[xx,yy].id in cangoblock_mob=false)) then
         begin
           work(xx,yy,explodeharm[q[tail].h]);
           continue;
         end;
         if (q[head].h>1) then
         begin
           inc(tail);
           q[tail].x:=xx;q[tail].y:=yy;q[tail].pre:=head;
           if (q[head].h>=10) then q[tail].h:=q[head].h-abs(random(2)*random(2))
           else q[tail].h:=q[head].h-1;
           work(xx,yy,explodeharm[q[tail].h]);
           if (mm.map[xx,yy].id in [0]=false) then q[tail].h:=q[head].h-mm.map[xx,yy].hard div 3-1;
         end;//end if can
       end;// end for
     end; //end while
   end;//end bfs

begin
  if (nomusic=0) then
  begin
    if (explodemusicplayed=false) then playmusic('music\boom'+chr(random(4)+1+ord('0'))+'.wav');
    explodemusicplayed:=true;
  end;
  hard:=min(hard,maxexplodehard);
  hard:=max(hard,0);
  fillchar(explodeed,sizeof(explodeed),false);
  candes:=true;
  if inmap(mx,my) then
   if mm.map[mx,my].id in [3] then candes:=false;
  bfs(mx,my,hard);
end;    
procedure explode(mx,my,hard,fromwho,hurtfrom:longint);
begin
  explode(mx,my,hard,fromwho,hurtfrom,0);
end;
procedure explode(m:Tpos;hard,fromwho,hurtfrom,nomusic:longint);
begin
  explode(m.x,m.y,hard,fromwho,hurtfrom,nomusic);
end;
procedure explode(m:Tpos;hard,fromwho,hurtfrom:longint);
begin
  explode(m.x,m.y,hard,fromwho,hurtfrom,0);
end;

procedure print_tip(s:string;color:longint);
begin
  gotoxy(maxtiplength div 2-(length(s) div 2)+3,maxy+2);
  tc(color);tb(8);write(s);
end;

procedure init_tip(s:string;c,lf:longint);
begin
  with tip do
  begin
    if twn=maxtip then exit;
    inc(twn);
    with tipwaiting[twn] do
    begin
      st:=s;
      color:=c;
      lastfor:=lf;
      if twn>1 then exit;
      gt(starttime);
      print_tip(st,color);
    end;//end with
  end;//end with
end;

procedure hurt_mob(var who:Tmob;fromx,fromy,harm,ht,fromwho:longint);
var gf:longint;
begin
  with who do
  begin
    if living=false then exit;
    if getmobharmtype(id) in [2] then exit;
    if (fromx=zb.x) and (fromy=zb.y) then exit;
    gf:=getfx(fromx,fromy,zb.x,zb.y);
    repeat
      if fx=-1 then break;
      if abs(gf-fx)=2 then
      begin
        speed:=max(speed,10-harm);
        if speed<0 then
        begin
          fx:=gf;
          speed:=-speed;
        end;
      end
       else if gf=fx then
       begin
         dec(speed,harm div 2+1);
       end;
    until true;
    if speed=maxlongint then speed:=10-harm;
   // speed:=max(speed,0);

    if harm>2 then fx:=gf;
    whos:=fromwho;
    print_mob(who);
  end;//end with
end;
procedure hurt_mob(n,fromx,fromy,harm,ht,fromwho:longint);
begin
  if n<1 then exit;
  hurt_mob(mob[n],fromx,fromy,harm,ht,fromwho);
end;

procedure hurt_tank(var who:Ttank;harm,ht,fromwho:longint);
begin
  with who do
  begin
    if living=false then exit;
    if (nam='Player') and (setting.gamemode=1) then exit;
    if unbreakble then exit;

    if (occup<>2) or (skillusing=false) then dec(hp,harm)
     else begin
       dec(hp,harm div 10);
       if system.random<=harm mod 10/10 then dec(hp,1);
       playmusic('music\hitiron'+chr(random(4)+1+ord('0'))+'.wav');
     end;
    print_tank(who);
    checkdie(who);

    if living=false then
    begin
      if nam='Ai' then
       if (fromwho<0) and ((setting.gamemode=1)=false) and (cmdused=false) then
       begin
         init_tip('金钱增加'+inttostr(killaiprize[occup]),14,killaitipshowlast);
         inc(profile.money,killaiprize[occup]);
         inc(killnum[-fromwho,occup]);
         if ((setting.gamehard<2) or (player[-fromwho].occup=0)) and (player[-fromwho].occup in [0,1,3,4]) and (player[-fromwho].living) and (random(setting.gamehard+1)=0) then player[-fromwho].hp:=min(player[-fromwho].hp+1,player[-fromwho].maxhp);
         playmusic('music\kill.wav');
       end;
      if nam='Player' then
      begin
        inc(dietimes[-xu]);
      end;
    end;//end if die
  end;//end with
end;
procedure hurt_tank(n,harm,ht,fromwho:longint);
begin
  if n>0 then hurt_tank(ai[n],harm,ht,fromwho)
   else if n=0 then exit
    else if n<0 then hurt_tank(player[-n],harm,ht,fromwho);
end;

procedure checkdie(var who:Ttank);
begin
  with who do
   if living and (hp<=0) then
   begin
     if (nam='Ai') and (occup=0) then bosstime:=false;
     if (nam='Player') then
       playmusic('music/player_death.wav');
     living:=false;
     dec(lives);
     gt(ldt);
     print_auto(zb);
   end;//end with
end;
procedure checkdie;
var i:longint;
begin
  //for i:=1 to maxmob do checkdie(mob[i]);
  for i:=1 to maxai do checkdie(ai[i]);
  for i:=1 to setting.playernum do checkdie(player[i]);
end;

procedure playfiremusic(x:longint);
begin                  
  case x of
    1:playmusic('music\fire_bullet'+chr(ord('0')+random(1,2))+'.wav');
    2:playmusic('music\fire_laser'+chr(ord('0')+random(1,3))+'.wav');
    3:playmusic('music\fire_bomb.wav');
    4:playmusic('music\fire_tnt.wav');
  end;
end;
function fire(var who:Ttank;fangxiang,amt:longint):longint;
var t:longint;
begin
  with who do
  begin
    fx:=fangxiang;
    print_tank(who);
    repeat
      gt(lft[amt]);
      t:=new_mob(zb.x{+gox[fx]},zb.y{+goy[fx]},fx,amt,xu);
    until true;
    gt(lft[amt]);
    if nam='Player' then
     if (amt<>1) and ((setting.gamemode=1)=false) then dec(profile.ammo[amt]);
    playfiremusic(amt);
  end;//end with
  exit(t);
end;

function canfire(who:Ttank;amt:longint):boolean;
begin
  with who do
  begin
    if occup=2 then
    begin
      if tick-lft[amt].tick<firespeed[id,occup,amt] div (2+random(2)) then exit(false);
    end
     else if tick-lft[amt].tick<firespeed[id,occup,amt] then exit(false);
    if (id=0) and (amt<>1) and ((setting.gamemode=1)=false) and (profile.ammo[amt]<=0) then exit(false);
  end;//end with
  exit(true);
end;

procedure move(var who:Ttank;dfx:longint);
var ox,oy:longint;
begin
  with who do
  begin
    ox:=zb.x;
    oy:=zb.y;
    inc(zb.x,gox[dfx]);
    inc(zb.y,goy[dfx]);
    fx:=dfx;
    gt(lmt);
    print_auto(ox,oy);
    print_tank(who);
    hitbox[ox][oy]:=0;
    hitbox[zb.x][zb.y]:=0;
  end;//end with
end;

function canmove(who:Ttank;dfx:longint):boolean;
var xx,yy:longint;
begin
  with who do
  begin
    if tick-lmt.tick<speed then exit(false);
    if (occup=2) and (skillusing) then exit(false);
    if fx=-1 then exit(false);
    xx:=zb.x+gox[dfx];
    yy:=zb.y+goy[dfx];
    if nam='Mob' then
      exit(can(xx,yy,2));
    exit(can(xx,yy,1));
  end;//end with
end;

procedure print_tank(who:Ttank);
var tcc,tbc:longint;
    s:string;
begin
  with who do
  begin
    if living=false then exit;
    if mm.map[zb.x,zb.y].id in donotprintblock_tank then exit;
    if unbreakble and (tick mod unbreakbleblinklast>=unbreakbleblinklast div 2) then exit;
    tbc:=tankbackground[id];
    tcc:=color(hp,maxhp);
    if nam='Player' then
    begin
      if xu=-2 then tbc:=player2color;
      tcc:=15;
      if skillusing then
       if xu=-1 then tcc:=13
        else tcc:=9;
      if tick-skill.stop.tick<occupskilltime[occup,1] then tcc:=8;
    end;
    s:=tankchar[id,occup,fx];

     with newsc[zb.x,zb.y] do
     begin
       bg:=tbc;
       col:=tcc;
       ch:=s;
     end;//end with
  {  gotoxy(zb.x*2+1,zb.y+1);
    tc();
    write(tankchar[id,occup,fx]);  }
  end;
end;
procedure print_tank(n:longint);
begin
  if (n>=1) and (n<=maxai) then
  begin
    print_tank(ai[n]);
  end
   else if (-n>=1) and (-n<=maxplayer) then
   begin
     print_tank(player[-n]);
   end;
end;

procedure print_mob(who:Tmob);
var tcc,tbc:longint;
    s:string;
begin
  with who do
  begin
    if living=false then exit;
  //  gotoxy(zb.x*2+1,zb.y+1);
    if mm.map[zb.x,zb.y].id in donotprintblock_mob then exit;
    tbc:=blockbackground[mm.map[zb.x,zb.y].id];
    tcc:=mobcolor[id];
    if id=4 then
    begin
      if (tick-lst.tick) mod TNTblinklast<TNTblinklast div 2 then tbc:=7
       else begin
         tbc:=6;
         tcc:=0;
       end;
    end;
    s:=mobchar[id,max(fx,0)];
     with newsc[zb.x,zb.y] do
     begin
       bg:=tbc;
       col:=tcc;
       ch:=s;
     end;//end with
  end;
end;
procedure print_mob(n:longint);
begin
  if (n<1) or (n>maxmob) then exit;
  print_mob(mob[n]);
end;

procedure print_block(x,y:longint);
begin
  if inmap(x,y)=false then
  begin
    clrscr;tc(15);tb(0);
    writeln('Error!');
    writeln('Wrong x or y in procedure print_block');
    writeln('x=',x,'  y=',y);
    delay(2000);
    halt;
  end;
  with mm.map[x,y] do
    print(x,y,blockbackground[id],blockcolor[id],blockchar[id,fx]);
end;
procedure print_block(x:Tpos);
begin
  print_block(x.x,x.y);
end;

procedure print_auto(x,y:longint);
var n:longint;
begin
  print_block(x,y);
  n:=whichmob(x,y);
  if n<>-1 then
  begin
    print_mob(mob[n]);
  end;
  n:=whichtank(x,y);
  if n>0 then
  begin
    print_tank(ai[n]);
  end
   else if n<0 then
   begin
     print_tank(player[-n]);
   end;
end;
procedure print_auto(zb:Tpos);
begin
  print_auto(zb.x,zb.y);
end;

procedure print_game_info;
var i,j:longint;
    playern,propn:longint;
    s:string;

   procedure printflagstatus(var what:Tflag);
   var i,x:longint;
   begin
     with what do
     begin
       if lthp=hp then exit;
       tb(blockbackground[id]);tc(15);
       write(blockchar[id,0]);
       tb(0);tc(15);write(':');
       x:=wherex;
       tc(color(hp,maxhp));
       tb(0);write(hp);
       x:=wherex-x;for i:=1 to 3-x do write(' ');
       tc(15);write('/',maxhp);
      // for i:=1 to 10-y do write(' ');
     end;//end with
   end;

begin
  for playern:=1 to setting.playernum do
   with player[playern] do
   begin
     if ltl[playern]<>lives then
     begin
       gotoxy(15,maxy+3);if playern=2 then gotoxy(wherex,wherey+1);
       tb(bkbg);tc(15);
       tc(color(lives,maxlives));
       write(lives);
       str(lives,s);
       for i:=1 to 4-length(s) do
       begin
         tb(bkbg);tc(bkcl);
         write(' ');
       end;
     end;
     if lthp[playern]<>hp then
     repeat
       gotoxy(22,maxy+3);if playern=2 then gotoxy(wherex,wherey+1);
       tb(bkbg);tc(color(hp,maxhp));
       write(hp);
       str(hp,s);
       for i:=1 to 4-length(s) do
       begin
         tb(bkbg);tc(bkcl);
         write(' ');
       end;
       if hp>lthp[playern] then break;
       playmusic('music\hit'+chr(random(1,3)+ord('0'))+'.wav');
      // write(s);
     until true;
     for propn:=1 to maxproptype do
      if ltprop[playern,propn]<>profile.prop[propn] then
      begin
        gotoxy(40+(propn-1)*10,maxy+3);if playern=2 then gotoxy(wherex,wherey+1);
        tb(bkbg);tc(15);
        write(profile.prop[propn]);
        str(profile.prop[propn],s);
        for i:=1 to 3-length(s) do
        begin
          tb(bkbg);tc(bkcl);
          write(' ');
        end;
      end;
   end;//end with

  gotoxy(maxx*2-6,maxy+3);
  printflagstatus(playerflag);
  gotoxy(maxx*2-6,maxy+4);
  printflagstatus(aiflag);

  tb(bkbg);tc(15);
  gotoxy(maxx*2-9,maxy+2);WRITE('Tick:',tick);

  gt(fpsn);
  if td(fpsb,fpsn)>=1000 then
  begin
    gotoxy(73,1);tb(bkbg);write('       ');
    gotoxy(80-length('Tps:'+inttostr(fpsn.tick-fpsb.tick))+1,1);tb(bkbg);tc(7);if fpsn.tick-fpsb.tick>=1000 div ticklast then tc(15);write('Tps:',fpsn.tick-fpsb.tick);
    fpsb:=fpsn;
  end;

  for i:=1 to setting.playernum do
   with player[i] do
   begin
     lthp[i]:=hp;
     for j:=1 to maxproptype do
       ltprop[i,j]:=profile.prop[j];
   end;
  playerflag.lthp:=playerflag.hp;aiflag.lthp:=aiflag.hp;
end;

procedure print_screen(j,i:longint);
var x1,x2,y1,y2:longint;
begin
  if (oldsc[j,i].ch<>newsc[j,i].ch) or (oldsc[j,i].bg<>newsc[j,i].bg) or (oldsc[j,i].col<>newsc[j,i].col) then
   with newsc[j,i] do
   begin
     gotoxy(j*2+1,i+1);
     tb(bg);tc(col);
     if ch<>'  ' then write(ch)
      else begin
        x1:=windminx;x2:=windmaxx;y1:=windminy;y2:=windmaxy;
        windminx:=j*2+x1;windmaxx:=j*2+length(ch)+x1-1;windminy:=i+y1;windmaxy:=i+y1;
        clrscr;
        windminx:=x1;windmaxx:=x2;windminy:=y1;windmaxy:=y2;
      end;
     oldsc[j,i]:=newsc[j,i];
   end;//end with
end;

procedure print_screen(opt:longint);
var i,j,x,y:longint;
    vst:array[1..maxx,1..maxy] of boolean;
begin
  fillchar(vst,sizeof(vst),false);
  if (opt=1) then
  begin
    case random(4) of
      0:for i:=1 to maxx do
         for j:=1 to maxy do
           print_screen(i,j);
      1:for i:=maxx downto 1do
         for j:=1 to maxy do
           print_screen(i,j);
      2:for i:=1 to maxy do
         for j:=1 to maxx do
           print_screen(j,i);
      3:for i:=maxy downto 1 do
         for j:=1 to maxx do
           print_screen(j,i);
    end;
    exit;
  end
  else if (opt=2) then
  begin
    for i:=1 to maxx*maxy do
    begin
      repeat
        x:=random(maxx)+1;
        y:=random(maxy)+1;
      until vst[x][y]=false;
      vst[x][y]:=true;
      print_screen(x,y);
    end;
    exit;
  end;
  for i:=-maxy to maxx+maxy do
  begin
    x:=i;
    y:=0;
    if (opt mod 2=1) then inc(x,maxy);
    for j:=1 to maxy do
    begin
      if opt mod 2=0 then inc(x)
      else dec(x);    
      inc(y);
      if (x>=1) and (x<=maxx) and (y>=1) and (y<=maxy) then
      begin
        if (vst[x][y]=false) then print_screen(x,y);
        vst[x][y]:=true;
      end;
    end;
    x:=maxx+maxy-i;
    if (opt mod 4>=2) then dec(x,maxy);
    y:=0;
    for j:=1 to maxy do
    begin
      if opt mod 4<2 then inc(x)
      else dec(x); 
      inc(y);
      if (x>=1) and (x<=maxx) and (y>=1) and (y<=maxy) then
      begin
        if (vst[x][y]=false) then print_screen(x,y);
        vst[x][y]:=true;
      end;
    end;
  end;
 // oldsc:=newsc;
end;
procedure print_screen;
begin
  print_screen(random(7));
//  flush(output);
end;

procedure print_map;
var i,j:longint;
begin
  tb(0);
  clrscr;
  tb(bkbg);
  tc(bkcl);
  write('╔');
  for i:=1 to maxx do write('═');
  write('╗');
  tb(bkbg);
  writeln;
  for i:=1 to maxy do
  begin
    gotoxy(1,i+1);
    tb(bkbg);
    tc(bkcl);
    write('║');
    for j:=1 to maxx do
     with mm.map[j,i] do
     begin
       print_auto(j,i);
     end;
    gotoxy(79,i+1);
    tb(bkbg);
    tc(bkcl);
    writeln('║');
  end;
  gotoxy(1,maxy+2);
  write('╚');
  for i:=1 to maxx do write('═');
  write('╝');
  writeln;

  gotoxy(20,1);
  tb(bkbg);tc(11);
  write(mm.nam);

  tb(bkbg);tc(7);
  gotoxy(maxx*2-25,1);
  write('关卡:');
  tc(15);
  write(lenlimit(mm.filenam,15));

  for i:=1 to setting.playernum do
  begin
    gotoxy(1,maxy+3+i-1);
    if i=1 then tb(tankbackground[0]) else tb(player2color);tc(15);write(tankchar[0,1,0]);    // gotoxy(wherex+4,wherey);
    tb(0);tc(7);write(' ',occupnam[0,player[i].occup],' ');
    tc(15);tb(0);{write(#3,'=');}write('Lives:');

    gotoxy(19,wherey);write('HP:');
    for j:=1 to maxproptype do
    begin
      gotoxy(35+(j-1)*10,wherey);
      write(propnam[j],':',profile.prop[j]);
    end;
  end;
  print_game_info;
  print_screen;
end;

procedure clear_tip;
var i:longint;
begin
  gotoxy(3,maxy+2);
  tc(bkcl);tb(bkbg);
  for i:=1 to maxtiplength div 2 do write('═');
end;

procedure clear_mob(var who:Tmob);
begin
  with who do
  begin
    maxhp:=0;hp:=0;
    fx:=0;
    living:=false;
    lmt.tick:=-1000;
    ldt.tick:=-1000;
    lst.tick:=-1000;
    zb.x:=-1;zb.y:=-1;
    id:=255;
  end;
end;

procedure clear_tank(var who:Ttank);
var i:longint;
begin
  with who do
  begin
    maxhp:=0;hp:=0;
    fx:=0;
    living:=false;
    lmt.tick:=-1000;
    for i:=1 to maxammotype do lft[i].tick:=-1000;
    ldt.tick:=-1000;
    lst.tick:=-1000;
    zb.x:=-1;zb.y:=-1;
    id:=255;
    ljn:=0;
    skillusing:=false;
  end;
end;

procedure clear_map;
var i,j:longint;
begin
  for i:=1 to maxx do
   for j:=1 to maxy do
    with mm.map[i,j] do
    begin
      id:=0;
      hard:=0;
      maxhard:=0;
      fj:=0;
      fx:=0;
      lrt.tick:=0;
      unbreakble:=false;
    end;
end;

procedure end_game;
var i,j,n,t:longint;
begin
  tb(0);clrscr;
  windminx:=1;windmaxx:=setting.smaxx;
  windminy:=1;windmaxy:=setting.smaxy;
  print_program_info;
  windmaxy:=setting.smaxy-3;
  gaming:=false;

  for i:=1 to setting.playernum do
  begin
    inc(dietimes[0],dietimes[i]);
    for j:=1 to maxoccup do
      inc(killnum[0,j],killnum[i,j]);
  end;
  for i:=1 to maxoccup do
    inc(killnum[0,0],killnum[0,i]);
  if ismainlevel then t:=levelwinprize[nowlevel] else t:=0;
  if ismainlevel then n:=nowlevel else n:=3;
  score:=(500*n+(t div 100+killnum[0,0])*(setting.gamehard*5+1)) div max(dietimes[0]+1-(nowlevel div 4),1);
  score:=round(score*(system.random/2+0.75));

  if ismainlevel and gamewin  then
  begin
    for assess:=1 to maxassess do
     if gameendtick<=levelbesttime[nowlevel,assess] then break;
  end
   else if gamelose then assess:=maxassess
    else assess:=round(maxassess*0.75);
end;

procedure print_program_info;
begin
  gotoxy(setting.smaxx-length('程序版本:'+Version)+1,setting.smaxy-2);                 tc(7);  write('程序版本:',Version);
  gotoxy(setting.smaxx-length('适用地图版本:'+ApplicationVersion)+1,setting.smaxy-1);  tc(7);  write('适用地图版本:',ApplicationVersion);
  gotoxy(setting.smaxx-15,setting.smaxy);                                              tc(8);  write('By ');  tc(15);  write('Fallen_Breath');
end;

procedure print_profile;
var i,x,y:longint;
begin
  clrscr;
  tb(0);
  with profile do
  begin
    tc(12);write('账号:');tc(15);writeln(usernam);
    tc(14);write('金钱:');tc(15);writeln(money);
    writeln;
    tc(11);writeln('弹药');
    for i:=1 to maxammotype do
    begin
      tc(7);write(ammonam[i],':');
      tc(15);
      if i=1 then writeln('∞')
       else writeln(ammo[i]);
    end;
    tc(11);writeln('道具');
    for i:=1 to maxproptype do
    begin
      tc(7);write(propnam[i],':');
      tc(15);writeln(prop[i]);
    end;
    writeln;
    tc(11);writeln('关卡状态');
    for i:=1 to mainlevelnum do
    begin
      tc(7);write('Level-',i,':');
      if levelunlock[i] then
      begin
        tc(15);write('已解锁');
      end
       else begin
        tc(8);write('未解锁');
       end;
      write(' ');
      if levelfinish[i] then
      begin
        tc(15);write('已通过');
      end
       else begin
        tc(8);write('未通过');
       end;
      if (i<>mainlevelnum) then writeln;
    end;
    writeln;
    gotoxy((windmaxx+windminx) div 2,windminy);
    x:=wherex; y:=wherey;
    tc(11);write('职业状态');
    for i:=0 to maxoccup do
    begin
      inc(y);
      gotoxy(x,y);
      tc(7);write(occupnam[0][i],':');
      if profile.occupown[i] then
      begin
        tc(15);write('已拥有');
      end
       else begin
        tc(8);write('未获得');
       end;
    end;
  end;//end with
  readkey;
end;

procedure save;
var i:longint;
    wj:text;
begin
  if logged=false then exit;
  assign(wj,'save/'+profile.filenam);
  rewrite(wj);
  writeln(wj,Version);
  with profile do
  begin
    writeln(wj,'PassWord=',password);
    writeln(wj,'Money=',money);
    for i:=1 to mainlevelnum do
    begin
      writeln(wj,'Level',i,'UnLock=',levelunlock[i]);
    end;
    for i:=1 to mainlevelnum do
    begin
      writeln(wj,'Level',i,'Finish=',levelfinish[i]);
    end;
    for i:=1 to maxammotype do
    begin
      writeln(wj,'Ammo',i,'=',ammo[i]);
    end;
    for i:=1 to maxproptype do
    begin
      writeln(wj,'Prop',i,'=',prop[i]);
    end;
    for i:=0 to maxoccup do
    begin
      writeln(wj,'Occup',i,'Own=',occupown[i]);
    end;
  end;//end with
  close(wj);
end;

function load(mode:longint):boolean;
var choose,i:longint;
    s:string;
    res:findfilesres;

   procedure fileread(fn:string);
   var wj:text;
       s,s1,s2,s3,e:string;
       i,n:longint;
       next:boolean;
      function fr(var s:string):string;
      begin
        if next then exit('');
        readln(wj,s);
        fr:=s;
        if pos('=',s)=0 then exit;
        while (length(s)>=1) and (s[1]<>'=') do delete(s,1,1);
        delete(s,1,1);
      end;
      function fr:string;
      var s:string;
      begin
        readln(wj,s);
        s1:='';s2:='';s3:='';
        if pos('=',s)=0 then exit(s);
        while (length(s)>1) and (s[1] in ['0'..'9','=']=false) do
        begin
          s1:=s1+s[1];
          delete(s,1,1);
        end;
        while (length(s)>1) and (s[1] in ['0'..'9']) do
        begin
          s2:=s2+s[1];
          delete(s,1,1);
        end;
        while (length(s)>1) and (s[1]<>'=') do
        begin
          s3:=s3+s[1];
          delete(s,1,1);
        end;
        if (length(s)>1) and (s[1]='=') then delete(s,1,1);
        exit(s);
      end;
   begin
     assign(wj,'save/'+fn);
     reset(wj);
     next:=false;
     with profile do
     begin
       fillchar(levelunlock,sizeof(levelunlock),false);levelunlock[1]:=true;levelunlock[2]:=true;
       fillchar(levelfinish,sizeof(levelfinish),false);
       fillchar(occupown,sizeof(occupown),false);occupown[0]:=true;
       fillchar(ammo,sizeof(ammo),0);
       fillchar(prop,sizeof(prop),0);

       filenam:=fn;
       usernam:=copy(fn,1,length(fn)-9);
       e:=fr(password);
       if e=password then fr(password);
       fr(s);val(s,money);
       while not eof(wj) do
       begin
         s:=fr;
         val(s2,n);
         if s1='Level' then
         begin
           if s3='UnLock' then
           begin
             if (n>=1) and (n<=mainlevelnum) then levelunlock[n]:=s='TRUE';
           end//end if s3='Unlock'
           else if s3='Finish' then
           begin
             if (n>=1) and (n<=mainlevelnum) then levelfinish[n]:=s='TRUE';
           end;//end if s3='Finish'
         end//end if s1='Level'

         else if s1='Ammo' then
         begin
           if (n>=1) and (n<=maxammotype) then val(s,ammo[n]);
         end//end if s1='Ammo'

         else if s1='Prop' then
         begin
           if (n>=1) and (n<=maxproptype) then val(s,prop[n]);
         end//end if s1='Prop'

         else if s1='Occup' then
         begin
           if (s3='Own') then
           begin
             if (n>=0) and (n<=maxoccup) then occupown[n]:=s='TRUE';
           end;
         end;//end if s1='Occup'
       end;//end while
       if (levelunlock[mainlevelnum]=false) and (levelfinish[mainlevelnum]=false) then
       begin
         levelunlock[mainlevelnum]:=true;
         for i:=1 to mainlevelnum-1 do
          if (levelfinish[i]=false) then levelunlock[mainlevelnum]:=false;
       end;//end if
     end;//end with
     close(wj);
   end;

begin
  load:=false;
  repeat//=============================================================
    if mode=0 then
    begin
      clrscr;
      gotoxy_mid(getastr(max(length('登录'),length('游客'))+6),1);
      choosestr:='登录'+ln+
                 '游客';
      choose:=chooseone();
      if choose=2 then exit(false);
    end;
    repeat
      clrscr;
      gotoxy_mid(getastr(max(length('载入存档'),max(length('新建存档'),length('返回')))+6),1);
      choosestr:='载入存档'+ln+
                 '新建存档'+ln+
                 '返回';
      choose:=chooseone();
      clrscr;
      if choose=3 then break;
      clrscr;
      case choose of
        1:begin
            gotoxy_mid('Loading...',1);tb(0);tc(7);write('Loading...');
            findfiles('save/*.savedata',res);
            choosestr:='';
            for i:=1 to res.filenum do
              choosestr:=choosestr+copy(res.filenam[i],1,length(res.filenam[i])-9)+ln;
            if length(choosestr)=0 then
            begin
              gotoxy_mid('无存档',2);tc(4);tb(0);write('无存档');
              delay(500);
              continue;
            end;
            choosestr:=choosestr+'返回';
            clrscr;
            gotoxy_mid('存档列表',1);tb(0);tc(15);write('存档列表');
            gotoxy_mid(getastr(max(res.maxlen-9,length('返回'))+6),2);choose:=chooseone();
            if choose=res.filenum+1 then continue;
            s:=res.filenam[choose];
            fileread(s);
            i:=0;
            repeat
              clrscr;
              gotoxy_mid('请输入密码',1);tb(0);tc(7);write('请输入密码');
              gotoxy_mid(getastr(maxlengthofpassword),2);inputpassword(s);
              if s=profile.password then break;
              gotoxy_mid('密码错误',3);tb(0);tc(4);write('密码错误');
              inc(i);
              delay(300);
            until i=5;
            if i=5 then continue;
            gotoxy_mid('登录成功',3);tb(0);tc(12);write('登录成功');
            delay(500);
          end;//end case 1
        2:begin
            i:=0;
            repeat
              clrscr;
              gotoxy_mid('账号名：',1);tb(0);tc(15);write('账号名：');
              cursoron;
              gotoxy_mid(getastr(maxlengthofusernam),2);tb(0);tc(7);readln(s);
              cursoroff;
              if length(s) in [minlengthofusernam..maxlengthofusernam]=false then continue;
              if fsearch('save\'+s+'.savedata','\')='' then break;
              gotoxy_mid('该账号已存在',3);    tb(0);tc(4); write('该账号已存在');
              delay(75);
              gotoxy_mid('是否覆盖该账号',4);  tb(0);tc(15);write('是否覆盖该账号');
              delay(75);
              gotoxy_mid(getastr(max(length('否'),length('是'))+6),5);tb(0);tc(7);choosestr:='否'+ln+'是';choose:=chooseone();
              if choose=2 then break;
              inc(i);
              delay(300);
            until i=5;
            if i=5 then continue;
            with profile do
            begin
              filenam:=s+'.savedata';
              usernam:=s;
              repeat
                i:=0;
                repeat
                  clrscr;
                  gotoxy_mid('请输入密码',1);  tc(15);tb(0);  write('请输入密码');
                  gotoxy_mid(getastr(maxlengthofpassword),2);tc(7);tb(0);inputpassword(s);
                  if length(s) in [minlengthofpassword..maxlengthofpassword] then break;
                  gotoxy_mid('密码过短',3);    tc(4);tb(0);   write('密码过短');delay(300);
                  inc(i);
                until i=5;
                if i=5 then break;
                clrscr;
                gotoxy_mid('请再次输入密码',1);  tc(15);tb(0);  write('请再次输入密码');
                gotoxy_mid(getastr(maxlengthofpassword),2);tc(7);tb(0);inputpassword(password);
                if password=s then break;
                gotoxy_mid('密码错误',3);        tc(4);tb(0);   write('密码错误');delay(500);
              until false;
              if i=5 then continue;

              money:=1000;
              ammo[2]:=100;
              ammo[3]:=10;
              prop[1]:=10;
            end;//end with
            logged:=true;
            clrscr;
            gotoxy_mid('Loading...',1);      tb(0);tc(7);   write('Loading...');
            save;
            clrscr;
            gotoxy_mid('创建新存档成功',1);  tb(0);tc(12);  write('创建新存档成功');
            delay(700);
          end;//end case 1
      end;//end case
      exit(true);
    until false;
    if mode=1 then exit(false);
  until false;//=============================================================
end;

procedure read_setting;
var wjin,wjout:text;
    s:string;
    t:longint;
begin
  with setting do
  begin
    if fsearch(SettingFileNam,'\')<>'' then
    begin
      assign(wjin,SettingFileNam);
      reset(wjin);
      readln(wjin,s);while (s[1]<>'=') and (length(s)<>0) do delete(s,1,1);delete(s,1,1);val(s,gamehard,t);if (t<>0) or (gamehard>maxgamehard) or (gamehard<0) then gamehard:=1;
      readln(wjin,s);while (s[1]<>'=') and (length(s)<>0) do delete(s,1,1);delete(s,1,1);val(s,gamemode,t);if (t<>0) or (gamemode>maxgamemode) or (gamehard<0) then gamemode:=0;
      if eof(wjin)=false then
      begin
        readln(wjin,s);while (s[1]<>'=') and (length(s)<>0) do delete(s,1,1);delete(s,1,1);val(s,playernum,t);if (t<>0) or (playernum>maxplayer) or (playernum<0) then playernum:=1;
        if (eof(wjin)=false) then
        begin
          readln(wjin,s);while (s[1]<>'=') and (length(s)<>0) do delete(s,1,1);delete(s,1,1);val(s,musicon,t);if (t<>0) or (musicon>1) or (musicon<0) then musicon:=1;
        end;
      end
       else begin
         playernum:=gamemode;
         musicon:=1;
         gamemode:=0;
       end;
      close(wjin)
    end//end if fsearch(SettingFileNam,'\')<>''
     else begin
       gamehard:=1;
       gamemode:=0;
       playernum:=1;
       musicon:=1;
     end;
    assign(wjout,SettingFileNam);
    rewrite(wjout);
    writeln(wjout,'GameHard=',gamehard);
    writeln(wjout,'GameMode=',gamemode);
    writeln(wjout,'Player=',playernum);
    writeln(wjout,'Music=',musicon);
    close(wjout);
  end;//end with
end;

procedure init_program;
var i:longint;

   procedure levelread(s:string;var mm:Tlevel);
   var i,j:longint;
       wjin:text;
   begin
     with mm do
     begin
       for i:=length(s)-10 downto 1 do
        if s[i]='\' then break;
       filenam:=copy(s,i+1,length(s)-i-10);
       ismainlevel:=false;
       if copy(s,1,i)='bin\' then ismainlevel:=true;

       assign(wjin,s);
       reset(wjin);
       readln(wjin,s);delete(s,1,pos('=',s));nam:=s;
       for i:=1 to maxx do
       begin
         for j:=1 to maxy do
          with mm.map[i,j] do
          begin
            read(wjin,id,hard,maxhard);
            if eoln(wjin)=false then read(wjin,fx,fj);
            readln(wjin);
          end;
       end;
readln(wjin);
       readln(wjin,playerflagmaxhp,aiflagmaxhp);
       readln(wjin,playerspawnpointnum);
       for i:=1 to playerspawnpointnum do
        with playerspawnpoint[i] do
         readln(wjin,x,y);

       for i:=1 to maxoccup do
         read(wjin,aispawnpointnum[i]);readln(wjin);
       for i:=1 to maxoccup do
       begin
         for j:=1 to aispawnpointnum[i] do
          with aispawnpoint[i,j] do
           readln(wjin,x,y);
       end;
       aispawnpointnum[0]:=playerspawnpointnum;
       for i:=1 to playerspawnpointnum do aispawnpoint[0][i]:=playerspawnpoint[i];
readln(wjin);
       readln(wjin,startspawntick);
       for i:=1 to maxoccup do
         readln(wjin,startspawnainum[i]);
       for i:=1 to maxoccup do
         readln(wjin,spawnprobability[i]);
       close(wjin);
     end;//end with
   end;

   procedure init_save;
   begin
     with profile do
     begin
       password:='';
       usernam:='';
       filenam:='';
       fillchar(ammo,sizeof(ammo),0);
       fillchar(prop,sizeof(prop),0);
       fillchar(levelunlock,sizeof(levelunlock),false);
       levelunlock[1]:=true;
       levelunlock[2]:=true;
       occupown[0]:=true;
       money:=1000;
       ammo[2]:=100;
       ammo[3]:=10;
       prop[1]:=10;
       fillchar(levelfinish,sizeof(levelfinish),false);
     end;
   end;

   procedure levelread(path:string);
   var r:findfilesres;
       i:longint;
   begin
     gotoxy(1,1);clreol;
     gotoxy_mid('Finding Level in Path "'+path+'"...',1);tc(7);write('Finding Level in Path "',path,'"...');
     findfiles(path+'*.leveldata',r);
     with r do
     begin
       for i:=1 to filenum do
       begin
         inc(levelnum);
         gotoxy(1,1);clreol;
         gotoxy_mid('Reading Level "'+filenam[i]+'"...',1);tc(7);write('Reading Level"',filenam[i],'"...');
         levelread(path+filenam[i],level[levelnum]);
       end;
       maxlevelnamlen:=max(maxlevelnamlen,r.maxlen-10);
       maxlevelnamlen:=min(maxlevelnamlen,setting.smaxx-6);
     end;//end with
   end;

begin
  //createwin(800,600);
  //settitle('坦克大战');
  cursoroff;
  randomize;
  checkbreak:=false;
  gaming:=false;
  logged:=false;
  setting.smaxx:=windmaxx;
  setting.smaxy:=windmaxy;
  print_program_info;
  dec(windmaxy,3);

  for i:=1 to maxplayer do
   with player[i] do
   begin
     xu:=-i;
     nam:='Player';
   end;//end with
  for i:=1 to maxai do
   with ai[i] do
   begin
     xu:=i;
     nam:='Ai';
   end;
  with noai do
  begin
    xu:=-1;
  end;//end with

  if directoryexists('bin')        =false then mkdir('bin');
  if directoryexists('save')       =false then mkdir('save');
  if directoryexists('level')      =false then mkdir('level');
  if directoryexists('screenshot') =false then mkdir('screenshot');

  levelnum:=0;
  maxlevelnamlen:=0;
  levelread('bin\');
  levelread('level\');  
  gotoxy(1,1);clreol;gotoxy_mid('Reading "+SettingFileNam+"...',1);tc(7);write('Reading "',SettingFileNam,'"...');
  read_setting;
  gotoxy(1,1);clreol;
 { for i:=1 to levelnum do
  begin
    n:=(maxlevelnamlen-length(level[i].filenam)) div 2;
    for j:=1 to n do
      level[i].filenam:=' '+level[i].filenam;
  end;           }
  init_save;
  musicthreadok:=true;
  createthread(nil,0,@runmusic,nil,0,tid);
end;

procedure init_prop(dx,dy,did,dwhos:longint);
begin
  case did of
    1:begin
        with mm.map[dx,dy] do
        begin
          id:=11;
          fj:=dwhos;
          fx:=0;
          maxhard:=blockmaxhard[id];
          hard:=maxhard;
        end;
        print_auto(dx,dy);
      end;
  end;//end case
end;

procedure init_tank(var who:Ttank;d_id,docc:longint; _pos:Tpos);
const didnotuse=-1000;
var i,j:longint;
    b:boolean;
    spawn:Tpos;
begin
  with who do
  begin
    case d_id of
      0:begin
          b:=false;
          for j:=1 to mm.playerspawnpointnum do
           if can(mm.playerspawnpoint[j],1) then b:=true;
          if b=false then exit;

          lmt.tick:=didnotuse;
          with skill do
          begin
            start.tick:=didnotuse;
            stop.tick:=didnotuse;
            use.tick:=didnotuse;
          end;

          repeat
            spawn:=mm.playerspawnpoint[random(mm.playerspawnpointnum)+1];
          until can(spawn.x,spawn.y,1);
          zb:=spawn;
          unbreakble:=true;
          for i:=1 to maxammotype do lft[i].tick:=0;
        end;
      1:begin

          maxlives:=1;
          lives:=maxlives;

          for i:=1 to maxammotype do
          begin
            gt(lft[i]);
            lft[i].tick:=tick+50-setting.gamehard*20;
          end;
          if docc in canbfsoccup then lmt.tick:=tick+50-setting.gamehard*20
           else lmt.tick:=didnotuse;
          ljn:=0;

          zb:=_pos;
        end;
    end;//end case
    living:=true;
    skillusing:=false;
    fx:=0;
    id:=d_id;
    occup:=docc;
    gt(lmt);
    gt(lst);
    speed:=tankspeed[d_id,docc];
    maxhp:=tankmaxhp[d_id,docc];
    hp:=maxhp;
    hitbox[zb.x][zb.y]:=tick*2;
    print_tank(who);
  end; //end with
end;
procedure init_tank(var who:Ttank;d_id,docc:longint);
var pos:Tpos;
begin
  pos.x:=-1;
  pos.y:=-1;
  init_tank(who,d_id,docc,pos);
end;

procedure init_mob(nn,dx,dy,dfx,d_id,dwhos:longint);
begin
  if (dx=-1) or (dy=-1) then exit;
  with mob[nn] do
  begin
    id:=d_id;fx:=dfx;whos:=dwhos;
    nam:='Mob';
    speed:=mobspeed[d_id];
    zb.x:=dx;zb.y:=dy;
    living:=true;
    rfx:=false;
    gt(lmt);//inc(lmt.tick);
    gt(lst);
    maxhp:=mobmaxhp[d_id];
    hp:=maxhp;
  //  work_mob;
    if living=false then exit;

    //print(zb.x,zb.y,-1,15,mobchar[id,fx]);
   { if nn>t then
    begin
      t:=nn;
      gotoxy(1,1);write(t);
    end;       }
  end;
end;

function new_mob(dx,dy,dfx,d_id,dwhos:longint):longint;
var i:longint;
begin
  if inmap(dx,dy)=false then exit(-1);
  if d_id=0 then exit;
  for i:=1 to maxmob do
   with mob[i] do
    if living=false then
    begin
   //   if (id in [0]) and (tick-ldt.tick<=TNTexplodelast) then continue;
      init_mob(i,dx,dy,dfx,d_id,dwhos);
      exit(i);
    end;
  exit(-1);
end;

function new_ai(d_id,docc:longint;spawn:Tpos):longint;
var i,j:longint;
    b:boolean;
begin
  if (spawn.x=-1) then
  begin
    b:=false;
    for j:=1 to mm.aispawnpointnum[docc] do
     if can(mm.aispawnpoint[docc,j],1) then b:=true;
    if b=false then exit(-1);
    repeat
      spawn:=mm.aispawnpoint[docc,random(mm.aispawnpointnum[docc])+1];
      for j:=1 to maxplayer do
       if player[j].living then
        if ju(spawn,player[j].zb)<=5 then exit;
    until can(spawn.x,spawn.y,1);
  end;
  for i:=1 to maxai do
   with ai[i] do
    if living=false then
    begin
      if tick-ldt.tick<=dyinglast then continue;
      init_tank(ai[i],d_id,docc,spawn);
      if (docc=0) and (ai[i].living) then bosstime:=true;
      exit(i);
    end;
  exit(-1);
end;  
function new_ai(d_id,docc:longint):longint;
var spawn:Tpos;
begin
  spawn.x:=-1;
  spawn.y:=-1;
  exit(new_ai(d_id,docc,spawn));
end;

procedure init_game;
var i,j,t:longint;

   procedure p1(var x:Tscreen);
   begin
     with x do
     begin
       ch:=chr(0);
       col:=0;bg:=0;
     end;
   end;

begin
  Tick:=0;
  gameendtick:=-1;
  clrscr;
  t:=(setting.smaxx-80) div 2;
  windminx:=t+1;windmaxx:=80+t;
  t:=(setting.smaxy-25) div 2;
  windminy:=t+1;windmaxy:=25+t;
  fillchar(hitbox,sizeof(hitbox),0);
///////////////Clear Tank///////////////
  for i:=1 to maxai do
    clear_tank(ai[i]);
  for i:=1 to setting.playernum do
    clear_tank(player[i]);
  for i:=1 to maxmob do
    clear_mob(mob[i]);

  for i:=1 to maxoccup do
   for j:=1 to mm.startspawnainum[i] do
     new_ai(1,i);
  if (mm.nam='What''s that?!') and ismainlevel then
  with mm do
  begin
    aispawnpointnum[0]:=4;
    aispawnpoint[0][1].x:=29; aispawnpoint[0][1].y:=4;
    aispawnpoint[0][2].x:=29; aispawnpoint[0][2].y:=5;
    aispawnpoint[0][3].x:=30; aispawnpoint[0][3].y:=4;
    aispawnpoint[0][4].x:=30; aispawnpoint[0][4].y:=5;
    new_ai(1,0);
    aispawnpointnum[0]:=playerspawnpointnum;
    for i:=1 to playerspawnpointnum do aispawnpoint[0][i]:=playerspawnpoint[i];
  end;
  for i:=1 to maxx do
   for j:=1 to maxy do
   begin
     p1(oldsc[i,j]);
     p1(newsc[i,j]);
   end;

  with playerflag do
  begin
    zb.x:=findblock(4,0).x;
    zb.y:=findblock(4,0).y;
    id:=4;
    maxhp:=mm.playerflagmaxhp;
    hp:=maxhp;
  end;
  with aiflag do
  begin
    zb.x:=findblock(5,0).x;
    zb.y:=findblock(5,0).y;
    id:=5;
    maxhp:=mm.aiflagmaxhp;
    hp:=maxhp;
  end;

  gaming:=true;
  gamewin:=false;
  gamelose:=false;
  bosstime:=false; 
  cmdused:=false;
  cmdmemcnt:=0;

  for i:=1 to setting.playernum do
    init_tank(player[i],0,player[i].occup);
  playerflag.lthp:=-1;aiflag.lthp:=-1;
  for i:=1 to maxplayer do
   with player[i] do
   begin
     lthp[i]:=-1;
     ammotype:=1;
     maxlives:=playermaxlives;
     lives:=maxlives;
   end;
  fillchar(ltl,sizeof(ltl),255);
///////////////Clear Tips///////////////
  with tip do
  begin
    twn:=0;
    for i:=1 to maxtip do
     with tipwaiting[i] do
     begin
       st:='';
       color:=7;
       gt(starttime);
       lastfor:=0;
     end;//end with&for
    gt(lasttipendtime);
  end;

  fillchar(killnum,sizeof(killnum),0);
  fillchar(dietimes,sizeof(dietimes),0);

end;

procedure work_mob(i:longint);
const block8harm:array[0..5] of longint=(15,9,6,4,2,1);
      number:array[0..9] of string=('０','１','２','３','４','５','６','７','８','９');
var t,xx,yy,ox,oy:longint;

   procedure workblock8(var who:Tmob);
   begin
     with who do
     begin
       if (rfx=false) then explode(zb.x,zb.y,TNTexplodehard,whos,0)
       else explode(zb.x,zb.y,TNTexplodehard,whos,1);
     end;
   end;

   procedure workmob3(var who:Tmob);
   begin
     with who do
     begin
       if (rfx=false) then explode(zb.x,zb.y,mob3explodehard,whos,0)
       else explode(zb.x,zb.y,mob3explodehard,whos,1);
     end;
   end;

   procedure hurttank(var mob:Tmob;mode:longint);
   var n,h:longint;
   begin
     with mob do
     begin
       h:=mobharm[id];
       n:=whichtank(zb.x,zb.y);
       if n=0 then exit;
       if (whos=n) and (rfx=false) then exit;
       if mode=1 then
       begin
         if n>0 then begin if ai[n].lmt.tick<>tick-1 then exit;end
          else if n<0 then if player[-n].lmt.tick<>tick-1 then exit;
       end;//end if
       if (rfx) or (whos<>n) then hurt_tank(n,h,getmobharmtype(id),whos);
       dec(hp);
       if (hp>10) and (random(random(10))=0) then inc(hp,random(3)-1);
       if n>0 then
        if ai[n].occup in [0,2] then hp:=0;
       if n<0 then
        if player[-n].occup in [2] then hp:=0;
     end;
   end;

   procedure checking(nn:longint);
   var n,h:longint;
   begin
     with mob[nn] do
     begin
       h:=mobharm[id];

       n:=mm.map[zb.x,zb.y].id;
       if n in cangoblock_mob then
       begin
         if n in donotprintblock_mob=false then print_mob(mob[nn])
          else print_block(zb);
       end
       else if n in candestroyblock[getmobharmtype(id)] then
       begin
         if (id<>2) or (mm.map[zb.x,zb.y].hard<=h) then dec(hp,mm.map[zb.x,zb.y].hard)
          else hp:=0;
         destroy(zb.x,zb.y,zb.x,zb.y,h,getmobharmtype(id));
       end
        else hp:=0;
       if n in cannotpierceblock then
       begin
         hp:=0;
       end;
       hurttank(mob[nn],0);
       if hp<=0 then living:=false;
     end;//end with
   end;

begin
  with mob[i] do
   if id=4 then
   begin
     if living=false then exit;
     if lst.tick=tick then exit;
     if tick-lst.tick<=TNTexplodelast then
     repeat
       if tick-lmt.tick<speed then break;
       if fx=-1 then break;
       gt(lmt);
       xx:=zb.x+gox[fx];yy:=zb.y+goy[fx];
       ox:=zb.x;oy:=zb.y;
       if inmap(xx,yy) then
        if (whichtank(xx,yy)=0) and ((mm.map[xx,yy].id in cangoblock_mob)) then
       begin
         zb.x:=xx;
         zb.y:=yy;
         print_auto(ox,oy);
         if ((tick-lst.tick) mod 3=0) and (random(2)=0) then speed:=round(speed*(system.random*1.5+0.5));
         if (speed<=0) and (random(7)<=1) then inc(speed);
       end
        else speed:=maxlongint;
     until true;
     if tick-lst.tick>TNTexplodelast then
     begin
       living:=false;
     end;
     print_auto(zb);
     if living=false then
      workblock8(mob[i]);
   end
   else if living then
   begin
     if inmap(zb)=false then living:=false;
     if living=false then exit;
     t:=tick-lmt.tick;
     if t>=speed then
     repeat
       hurttank(mob[i],1);
       if living=false then break;
       gt(lmt);
       ox:=zb.x;oy:=zb.y;
       inc(zb.x,gox[fx]);
       inc(zb.y,goy[fx]);
       print_auto(ox,oy);
       if inmap(zb)=false then
       begin
         living:=false;
         continue;
       end;
      until true;//end if t>=speed
     if inmap(zb) then
     begin
       checking(i);
       print_auto(zb);
     end;
     if (living=false) and (id=3) then workmob3(mob[i]);
   end; //end with
end;
procedure work_mob;
var i:longint;
begin
  for i:=1 to maxmob do work_mob(i);
  checkdie;
end;

procedure work_ai;
const occup5harm:array[0..3] of longint=(10,5,2,1);
      maxtrytime=50;
      maxdeep=50;
var i,j,k,t,xx,yy,trytime,safede,ain:longint;
    dosth,b,bfsok,playeralive:boolean;
    gwn:longint;
    bb:array[-1..3] of boolean;

   function firesafe(ain,x,y,de,ju:longint):boolean;
   var i,n,t:longint;
   begin
     i:=0;
     t:=1;
     repeat
       inc(i);
       dec(ju);
       inc(x,gox[de]);
       inc(y,goy[de]);
       if inmap(x,y)=false then break;
       if mm.map[x,y].id in [5,8] then exit(false);

       if mm.map[x,y].hard>=0 then dec(t,mm.map[x,y].hard);
       if (t<=0) and ((ju<0) or (ju>1000)) then break; // 子弹经过后，才被拦截
       if ju<=0 then
        if ai[ain].occup in [0,2,3,4] then exit(true);//无视玩家后面的状况

       if (ju>=0) and (mm.map[x,y].id in [2,14,15]) then exit(false);//与敌方之间有xxx
       if (mm.map[x,y].id=16) and (mm.map[x,y].fx<>de) then exit(false);
       if (mm.map[x,y].id=17) and (mm.map[x,y].fx<>(de+2) mod maxfx) then exit(false);

       n:=whichtank(x,y);
       if n>0 then
       repeat
         if (ai[n].id<>0) and (ai[n].occup in [2,3]) and (ai[ain].occup in [1]) then exit(false);//前方的自己人不会躲避
       //  if (ai[n].id<>0) and (i=1) and (ai[ain].id<>2) then exit(false);  //前面紧挨着自己人
       until true;
     until false;
     exit(true);
   end;

   function heresafe(x,y,de,view:longint):boolean;
   var n,t,xx,yy,ox,oy:longint;
       b:boolean;
   begin
     ox:=x;oy:=y;
     while inmap(x,y) and (mm.map[x,y].id<>2) do
     begin
       inc(x,gox[de]);
       inc(y,goy[de]);
       n:=whichmob(x,y);
       if n<>-1 then
       begin
         with mob[n] do
          if fx=(de+2) mod 4 then
          repeat
            b:=true;
            xx:=x;yy:=y;
            t:=1;//mob_id[1].maxhp
            repeat
              xx:=xx+gox[(de+2) mod 4];
              yy:=yy+goy[(de+2) mod 4];
              dec(t,mm.map[xx,yy].hard);
              if mm.map[xx,yy].hard=-1 then dec(t);
              if (t<=0) or (mm.map[xx,yy].id=2) then
              begin
                b:=false;
                break;
              end;
            until (xx=ox) and (yy=oy);
            if b then exit(false);
          until true;  //end if fx=(de+2) mod 4
       end;   //end if n<>-1
       dec(view);
       if (view=0) then break;;
     end;
     exit(true);
   end;

   procedure readyfire(ain,de,v:longint);
   var i:longint;
   begin
     with ai[ain] do
     begin
       for i:=1 to maxammotype do
        if (tick-lft[i].tick>=firespeed[id,occup,i]) and (firespeed[id,occup,i]<>maxlongint) then
        begin
          if firesafe(ain,zb.x,zb.y,de,v) then
          begin
            fire(ai[ain],de,i);
            dosth:=true;
          end;
        end;
     end;//end with
   end;

   procedure workoccup5(ain:longint);
   begin
     with ai[ain] do
       explode(zb,aioccup5explodehard,ain,1);
   end;

   function finishgoing(x,y:longint):boolean;
   var i:longint;
   begin
     for i:=1 to gwn do
      if (gotowhere[i].x=x) and (gotowhere[i].y=y) then exit(true);
     exit(false);
   end;

   function bfs(x,y,ain:longint):boolean;
   var i,n,xx,yy:longint;
       q:array[1..2,1..maxqueue] of record
                                      x,y,pre:integer;
                                    end;
       head,tail:array[1..2] of longint;
       went:array[1..maxx,1..maxy] of integer;

      function finish(n,x,y:longint):longint;
      var i:longint;
      begin
        if n=1 then n:=2
         else n:=1;
        for i:=1 to tail[n] do
         if (x=q[n,i].x) and (y=q[n,i].y) then exit(i);
        exit(0);
      end;

      function kz(n:longint;var head,tail:longint):longint;
      var i,ii,t,tot,xx,yy:longint;
          b:array[0..3] of boolean;

         procedure print(n,d:longint);
         begin
           if n=1 then
            if q[n,d].pre<>0 then print(n,q[n,d].pre);
           inc(tot);
           ai[ain].lj.zb[tot].x:=q[n,d].x;
           ai[ain].lj.zb[tot].y:=q[n,d].y;
           if n=2 then
            if q[n,d].pre<>0 then print(n,q[n,d].pre);
         end;

      begin
        inc(head);
        fillchar(b,sizeof(b),true);
        for ii:=0 to 3 do
        begin
          repeat
            i:=random(4);
          until b[i];
          b[i]:=false;
          xx:=q[n,head].x+gox[i];
          yy:=q[n,head].y+goy[i];
          if ai[ain].occup in [4,5] then if (ju(x,y,xx,yy)>(setting.gamehard+1)*16) then continue;
          if can(xx,yy,1)  and (cannotgo[ai[ain].occup,xx,yy]=false) then
          repeat
            if n=1 then if went[xx,yy]>0 then break;
            if n=2 then if went[xx,yy]<0 then break;
            inc(tail);
            q[n,tail].x:=xx;q[n,tail].y:=yy;q[n,tail].pre:=head;
            t:=went[xx,yy];
            if ((n=1) and (t<0)) or ((n=2) and (t>0)) then
            begin
              tot:=0;
              if n=2 then print(n mod 2+1,abs(t));
              print(n,tail);dec(tot);
              if n=1 then  print(n mod 2+1,abs(t));
              ai[ain].lj.tot:=tot;
              ai[ain].lj.zb[tot+1].x:=-1;
              exit(1);
            end;
            if n=1 then went[xx,yy]:=tail;
            if n=2 then went[xx,yy]:=-tail;
          until true;//end if can
        end;// end for
        exit(0);
      end;

   begin
     fillchar(went,sizeof(went),false);
     head[1]:=0;head[2]:=0;
     tail[1]:=1;tail[2]:=gwn;
     went[x,y]:=1;
     q[1,1].x:=x;q[1,1].y:=y;q[1,1].pre:=0;
     for i:=1 to gwn do
      with q[2,i] do
      begin
        x:=gotowhere[i].x;
        y:=gotowhere[i].y;
        went[x,y]:=-i;
        pre:=0;
      end;
     while true do
     begin
       inc(bfscnt);
       if (head[1]>=tail[1]) or (head[2]>=tail[2]) then
       begin
         for xx:=1 to maxx do
          for yy:=1 to maxy do
          begin
            if (head[1]>=tail[1]) and (went[xx,yy]>0) then cannotgo[ai[ain].occup,xx,yy]:=true;
            if (head[2]>=tail[2]) and (went[xx,yy]<0) then cannotgo[ai[ain].occup,xx,yy]:=true;
          end;
         exit(false);
       end;
       if tail[1]<tail[2] then n:=kz(1,head[1],tail[1])
        else n:=kz(2,head[2],tail[2]);
       if n=1 then exit(true);
     end; //end while
   end;//end bfs

begin
  fillchar(cannotgo,sizeof(cannotgo),false);
  bfscnt:=0;
  for i:=1 to maxai do
   with ai[i] do
   begin
     if living then
     begin
       repeat
         dosth:=false;
         ain:=i;

         //TRY GO
         if occup in [0,3,4,5] then
         repeat               
           gwn:=0;
           if bfscnt>100000 then break;
           playeralive:=false;for j:=1 to maxplayer do if player[j].living then playeralive:=true;  
           t:=maxlongint;mubiao:=0;
           for j:=1 to setting.playernum do
            with player[j] do
             if living then
              if (ju(zb,ai[ain].zb)<t) and (ju(zb,ai[ain].zb)<=(setting.gamehard+1)*16) then
              begin
                t:=ju(zb,ai[ain].zb);
                ai[ain].mubiao:=j;
              end;
           if (occup in [4,5]) and (mubiao=0) then break;

           fillchar(gotowhere,sizeof(gotowhere),0);
           if occup in [4,5] then
           begin
             if (tick-player[ai[ain].mubiao].lmt.tick<=5-setting.gamehard) then break;
           end;
          // gotoxy(1,1); tc(random(16)); write(playeralive,' ');
           if (occup=3) or ((occup=0) and ((playeralive=false) or (mubiao=0))) then
           begin
             for j:=0 to 3 do
             begin
               xx:=playerflag.zb.x;
               yy:=playerflag.zb.y;
               while inmap(xx,yy) do
               begin
                 if mm.map[xx,yy].id in [2,5,8,14,15] then break;
                 if (mm.map[xx,yy].id=16) and (mm.map[xx,yy].fx<>(j+2) mod maxfx) then break;
                 if (mm.map[xx,yy].id=17) and (mm.map[xx,yy].fx<>j) then break;
           {      t:=whichtank(xx,yy);
                 if (t>0) and (t<>ain) then
                  if ai[t].occup=3 then break;    }
                 inc(xx,gox[j]);
                 inc(yy,goy[j]);
                 if can(xx,yy,1) or ((ai[ain].zb.x=xx) and (ai[ain].zb.y=yy)) then
                 begin
                   inc(gwn);
                   gotowhere[gwn].x:=xx;
                   gotowhere[gwn].y:=yy;
                 end;
               end;//end while
             end;//end for
           end//end 3
         else if (occup=4) or (occup=0) then
         begin
           if playeralive=false then break;
           for j:=0 to 3 do
           begin
             xx:=player[mubiao].zb.x;
             yy:=player[mubiao].zb.y;
             while inmap(xx,yy) do
             begin
               if mm.map[xx,yy].id in [2,5,8,14,15] then break;
               if (mm.map[xx,yy].id=16) and (mm.map[xx,yy].fx<>(j+2) mod maxfx) then break;
               if (mm.map[xx,yy].id=17) and (mm.map[xx,yy].fx<>j) then break;
              { t:=whichtank(xx,yy);
               if (t<>-1) and (t<>ain) then
                if ai[t].occup=4 then break;  }
               inc(xx,gox[j]);
               inc(yy,goy[j]);
               if can(xx,yy,1) or ((ai[ain].zb.x=xx) and (ai[ain].zb.y=yy)) then
               begin
                 inc(gwn);
                 gotowhere[gwn].x:=xx;
                 gotowhere[gwn].y:=yy;
               end;
             end;//end while
           end;//end for
         end //end 4
         else if (occup=5) then
         begin
           if playeralive=false then break;

            for j:=player[mubiao].zb.x-1 to player[mubiao].zb.x+1 do
             for k:=player[mubiao].zb.y-1 to player[mubiao].zb.y+1 do
              if can(j,k,1) or ((j=zb.x) and (k=zb.y)) then
              repeat
                if setting.gamehard>=2 then
                 if ju(j,k,player[mubiao].zb)=2 then break;
                inc(gwn);
                gotowhere[gwn].x:=j;
                gotowhere[gwn].y:=k;
              until true;//end for
         end;  //end case 5
           if tick-lmt.tick<tankspeed[id,occup] then break;
           if finishgoing(zb.x,zb.y) then break;
           bfsok:=false;
           repeat
             if ai[15+random(3)].living then
              if (tick-lst.tick-ain) mod tankspeed[0,1]<>0 then break;
            // if (tick-lst.tick) mod 5<>0 then break;
             {if occup in [4,5] then
              if (player[mubiao].lmt.tick<>tick-1) and (ljn<>0) then break;      }
             bfsok:=bfs(zb.x,zb.y,ain);
             if bfsok=false then break;
             ljn:=1;
           until true;
           {if (tick-lst.tick-ain) mod tankspeed[0,1]<>0 then
            if ai[20+random(3)].living=false then break;}
           if ljn=0 then break;
           if can(lj.zb[ljn+1],1)=false then break;
           if ju(lj.zb[ljn+1],zb)<>1 then break;
           {if ljn=lj.tot+1 then
           begin
             ljn:=lj.tot;
             break;
           end;     }
           inc(ljn);
           move(ai[ain],getfx(zb,lj.zb[ljn]));
           dosth:=true;
         until true;//end TRY GO

         //CHECK SAFE               
         if occup in [0,1,3,4,5] then
         repeat
           case setting.gamehard of
             0:if occup in [0]=false then break;
             1:if occup in [0,1]=false then break;
             2:if occup in [0,1,4]=false then break;
             3:if occup in [0,1,3,4,5]=false then break;
           end;
           if (occup=1) and (system.random<=1/(setting.gamehard+1)) then break;
           trytime:=0;safede:=0;j:=-1;
           repeat //CHECK SAFE
              if tick-lmt.tick<tankspeed[id,occup] then break;
              inc(trytime);
              j:=(j+1) mod maxfx;
              if heresafe(zb.x,zb.y,j,4+setting.gamehard) then inc(safede)
               else safede:=0;
              if heresafe(zb.x,zb.y,j,4+setting.gamehard)=false then
              begin
                t:=0;
                if random(2)=0 then k:=(j+1) mod maxfx
                 else k:=(j+3) mod maxfx;
                repeat
                  inc(t);
                  xx:=zb.x+gox[k];
                  yy:=zb.y+goy[k];
                  if can(xx,yy,1) and (whichmob(xx,yy)=-1) then
                  begin
                    move(ai[ain],k);
                    dosth:=true;
                    break;
                  end;
                  k:=(k+2) mod maxfx;
                until t=2;
                t:=j;
              end;//end if heresafe(zb.x,zb.y,j,4+setting.gamehard*2)=false
           until (trytime=maxtrytime) or (safede=maxfx);
           if (trytime=maxtrytime) then
           repeat
             t:=(t+2) mod maxfx;
             if canmove(ai[ain],t) then move(ai[ain],t);
           until true;
         until true;//CHECK SAFE
         
         //RANDOM MOVE
         if occup in [0,1,3,4,5] then
         repeat
           if tick-lmt.tick<tankspeed[id,occup] then break;
           if (occup=0) and (dosth) then break;
           if (occup in [1]) then
           begin
             if (random(20)<>0) then break;
           end
            else if random(75)<>0 then break;
           if occup in [0,3,5] then
            if finishgoing(zb.x,zb.y) then break;
          b:=false;if occup in [4] then
            for j:=1 to maxplayer do
             if player[j].living then b:=true;if b then break;

           if occup in [1] then for j:=1 to maxplayer do
            if player[j].living then
             if (zb.x=player[j].zb.x) or (zb.y=player[j].zb.y) then
             begin
               b:=false;
               if player[j].zb.x=zb.x then
               begin
                 t:=abs(player[j].zb.y-zb.y);
                 if player[j].zb.y>zb.y then b:=firesafe(ain,zb.x,zb.y,2,t)
                  else b:=firesafe(ain,zb.x,zb.y,0,t);
               end
                else if player[j].zb.y=zb.y then
                begin
                  t:=abs(player[j].zb.x-zb.x);
                  if player[j].zb.x>zb.x then b:=firesafe(ain,zb.x,zb.y,1,t)
                   else b:=firesafe(ain,zb.x,zb.y,3,t);
                end;
               if b then break;
             end;//end for
           if b then break;
           k:=0;
           fillchar(bb,sizeof(bb),false);
           for k:=1 to maxfx do
           repeat
             repeat
               t:=random(4);
             until bb[t]=false;
             bb[t]:=true;
             xx:=zb.x+gox[t];yy:=zb.y+goy[t];
             if (heresafe(xx,yy,(t+1) mod 4,12)=false) or (heresafe(xx,yy,(t+3) mod 4,12)=false) then continue;
             if canmove(ai[ain],t) then
             begin
               move(ai[ain],t);
               dosth:=true;
               break;
             end;
           until true;
         until true;//end RANDOM MOVE

         //TRY ATTACK
         if occup in [0,1,2,3,4] then
          for t:=1 to 2 do
          repeat
            repeat
              j:=random(maxplayer)+1;
              if player[j].living=false then break;
              if (occup in [3]) and (t=1) then break;
              if (occup in [0]) and (random(2)=0) then break;
              if player[j].zb.x=zb.x then
              begin
                if player[j].zb.y>zb.y then readyfire(ain,2,abs(player[j].zb.y-zb.y))
                 else readyfire(ain,0,abs(player[j].zb.y-zb.y));
              end
               else if player[j].zb.y=zb.y then
               begin
                 if player[j].zb.x>zb.x then readyfire(ain,1,abs(player[j].zb.x-zb.x))
                  else readyfire(ain,3,abs(player[j].zb.x-zb.x));
               end;
            until true;
            if playerflag.zb.x=zb.x then
            begin
              if playerflag.zb.y>zb.y then readyfire(ain,2,abs(playerflag.zb.y-zb.y))
               else readyfire(ain,0,abs(playerflag.zb.y-zb.y));
            end
             else if playerflag.zb.y=zb.y then
             begin
               if playerflag.zb.x>zb.x then readyfire(ain,1,abs(playerflag.zb.x-zb.x))
                else readyfire(ain,3,abs(playerflag.zb.x-zb.x));
             end;
          until true;//end TRY ATTACK

         //RANDOM ATTACK
         if occup in [1] then
         repeat
           if random(200)<>0 then break;
           fillchar(bb,sizeof(bb),true);
           for j:=0 to 3 do
           begin
             repeat
               t:=random(4);
             until bb[t];
             bb[t]:=false;
             readyfire(ain,t,maxlongint);
             bb[-1]:=false;
             for t:=1 to maxammotype do
              if lft[t].tick=tick then bb[-1]:=true;
             if bb[-1] then break;
           end;
         until true;//end RANDOM ATTACK

         if occup in [5] then
         repeat
           if mubiao=0 then break;
           if tick-lmt.tick<trunc((1-setting.gamehard/maxgamehard)*tankspeed[id,occup]) then break;
           if finishgoing(zb.x,zb.y)=false then break;
           workoccup5(ain);
           dosth:=true;
         until true;
         if dosth then print_tank(ai[ain]);
       until true;//main
     end //end if living
      else if tick-ldt.tick<dyinglast then
      repeat
        if mm.map[zb.x,zb.y].id in [9] then break;
        if (tick-ldt.tick) mod dyingblinklast<=dyingblinklast div 2 then print_auto(zb)
         else print(zb,tankbackground[id],color(hp,maxhp),tankchar[id,occup,fx]);
      until true
       else if tick-ldt.tick=dyinglast then
       begin
         print_auto(zb);
         clear_tank(ai[i]);
       end;
   end;//end with
end;

procedure work_tip;
var i,t:longint;
begin
  with tip do
   if twn<>0 then
   repeat
     t:=tick-tipwaiting[1].starttime.tick;
     if t<tipwaiting[1].lastfor then break;

     if t=tipwaiting[1].lastfor then
     begin
       gt(lasttipendtime);
       for i:=1 to twn-1 do
         tipwaiting[i]:=tipwaiting[i+1];
       dec(twn);
     end;//end if
     if (twn=0) or (t=tipwaiting[1].lastfor) then
     begin
       clear_tip;
       break;
     end;//end if
     if tick-lasttipendtime.tick<tipbreak then break;

     with tipwaiting[1] do
       print_tip(st,color);
     gt(tipwaiting[1].starttime);
   until true; //end with
end;

procedure work_block;
const didnotuse=-1000;
var n,firebreak:longint;
    nx,ny:longint;
    changed:array[1..maxmob] of boolean;

    function getmob(x,y:longint):longint;
    var i,n:longint;
    begin
      n:=-1;
      for i:=1 to maxmob do
       if (mob[i].living) and (mob[i].zb.x=x) and (mob[i].zb.y=y) and (changed[i]=false) then
       begin
         n:=i;
         changed[i]:=true;
         break;
       end;
      exit(n);
    end;

    procedure wm(n:longint);
    begin
      with mob[n] do
      begin
        if id=4 then speed:=maxlongint
         else if (id<>2) or (mm.map[nx,ny].hard<=mobharm[id]) then dec(hp,mm.map[nx,ny].hard)
          else hp:=0;
        destroy(nx,ny,nx,ny,mobharm[id],getmobharmtype(id));
        work_mob(n);
      end;//end with
    end;

begin
  fillchar(changed,sizeof(changed),false);
  for nx:=1 to maxx do
   for ny:=1 to maxy do
    with mm.map[nx,ny] do
     case id of
       10:begin
         case fj of
           1..4:firebreak:=block10firebreak[fj];
           else firebreak:=maxlongint;
         end;
         if tick-lrt.tick>=firebreak then
         begin
           new_mob(nx+gox[fx],ny+goy[fx],fx,fj,0);
           playfiremusic(fj);
           gt(lrt);
           if fj in [4]=false then
            if random(2)=0 then inc(lrt.tick,random(3)-1);
         end;
       end;//end case 10
       11:repeat
         n:=whichtank(nx,ny);
         if n=0 then
         begin
           lrt.tick:=didnotuse;
           break;
         end;
         if lrt.tick=didnotuse then gt(lrt);
         if n=fj then break;
         if tick-lrt.tick<=block11explodewait then break;
         id:=0;
         print_block(nx,ny);
         explode(nx,ny,block11explodehard,fj,0);
       until true;//end case 11
        14:repeat
          repeat
            n:=getmob(nx,ny);
            if n=-1 then break;
            with mob[n] do
            begin
              rfx:=true;
              if (fx=(mm.map[nx,ny].fx+0) mod maxfx) or (fx=(mm.map[nx,ny].fx+1) mod maxfx) then
              begin
                wm(n);
                break;
              end;//end if
              if      fx=(mm.map[nx,ny].fx+2) mod maxfx then fx:=(mm.map[nx,ny].fx+1) mod maxfx
              else if fx=(mm.map[nx,ny].fx+3) mod maxfx then fx:=(mm.map[nx,ny].fx) mod maxfx;
              inc(zb.x,gox[fx]);
              inc(zb.y,goy[fx]);
              inc(lmt.tick);
            end;//end with
          until false;//end repeat
        until true;//end case 14
        15:repeat
          repeat
            n:=getmob(nx,ny);
            if n=-1 then break;
            with mob[n] do
            begin
              rfx:=true;
              if ((mm.map[nx,ny].fx=0) and (fx in [1,3]))
              or ((mm.map[nx,ny].fx=1) and (fx in [0,2])) then
              begin
                wm(n);
                break;
              end;//end if
              case mm.map[nx,ny].fx of
                0,1:fx:=(fx+2) mod maxfx;
                2:case fx of
                  0:fx:=3;1:fx:=2;2:fx:=1;3:fx:=0;
                end;
                3:case fx of
                  0:fx:=1;1:fx:=0;2:fx:=3;3:fx:=2;
                end;
              end;
              inc(zb.x,gox[fx]);
              inc(zb.y,goy[fx]);
              inc(lmt.tick);
            end;//end with
          until false;//end repeat
        until true;//end case 15
        16,17:repeat
          repeat
            n:=getmob(nx,ny);
            if n=-1 then break;
            with mob[n] do
            begin
              if id=4 then
               if (mm.map[nx,ny].id=17)
               or ((mm.map[nx,ny].id=16) and (fx<>mm.map[nx,ny].fx)) then
               begin
                 speed:=maxlongint;
                 inc(zb.x,gox[(fx+2) mod maxfx]);
                 inc(zb.y,goy[(fx+2) mod maxfx]);
                 if inmap(zb)=false then
                 begin
                   inc(zb.x,gox[fx]);
                   inc(zb.y,goy[fx]);
                 end;
                 continue;
               end;//end if id=4
              if ((mm.map[nx,ny].id=16) and (fx<>mm.map[nx,ny].fx))                        //是单向穿透且方向不对
              or ((mm.map[nx,ny].id=17) and (fx<>(mm.map[nx,ny].fx+2) mod maxfx)) then     //是单向破坏且方向不对
              begin
                hp:=0;
                work_mob(n);
                continue;
              end;
              if mm.map[nx,ny].id=16 then break;

              wm(n);
              destroy(nx,ny,nx,ny,mobharm[id],getmobharmtype(id));
              work_mob(n);
            end;//end with
          until false;//end repeat
        until true;//end case 16,17
     end;//end case
end;

procedure work_occupskill(var player:Ttank);
var i,j,n,x,t:longint;
    flg:boolean;

   function firesafe(x,y,de:longint):boolean;
   var n:longint;
   begin
     repeat
       inc(x,gox[de]);
       inc(y,goy[de]);
       if inmap(x,y)=false then break;
       if mm.map[x,y].id in [4,8] then exit(false);
       if mm.map[x,y].hard>0 then break;

       n:=whichtank(x,y);
       if n<0 then exit(false);
     until false;
     exit(true);
   end;

   procedure catchmob(x,y:longint);
   var head,tail:longint;
       fx,xx,yy,t:longint;
       q:Array[1..maxqueue] of record
                                 x,y,dis:integer;
                               end;
   begin
     head:=0;
     tail:=1;
     q[tail].x:=x;
     q[tail].y:=y;
     q[tail].dis:=0;
     repeat
       inc(head);
       with q[head] do
       repeat
         if dis>=playeroccup1skillcatchdis then break;
         for fx:=0 to maxfx-1 do
         begin
           xx:=x+gox[fx];
           yy:=y+goy[fx];
           if can(xx,yy,2)=false then continue;
           inc(tail);
           with q[tail] do
           repeat
             x:=xx;
             y:=yy;
             dis:=q[head].dis+1;
             t:=whichmob(xx,yy);
             if t=-1 then break;
             if mob[t].whos=player.xu then break;
             with mob[t] do
             begin
               whos:=player.xu;
               fx:=player.fx;
               xx:=zb.x;yy:=zb.y;
               zb:=player.zb;
               if inmap(zb.x,zb.y)=false then living:=false;
               print_auto(xx,yy);
             end;
           until true;//end with
         end;  //end for
       until true;//end with
     until head=tail;
   end;

begin
  with player do
  begin
    if living=false then exit;
    if skillusing=false then exit;
    if ((setting.gamemode=1)=false) and ((tick-skill.start.tick>=occupskilltime[occup,2]) or (tick-skill.stop.tick<occupskilltime[occup,1])) then
    begin
      if (tick-skill.start.tick>=occupskilltime[occup,2]) then
      begin
        gt(skill.stop);
        if (occup=2) then playmusic('music\skill2_end.wav');
      end;
      skillusing:=false;
      exit;
    end;
    if tick-skill.use.tick<occupskilltime[occup,3] then exit;
    if tick=skill.start.tick+1 then
    case occup of
      2:playmusic('music\skill2_start.wav');
    end;
    gt(skill.use);
    case occup of
      0:repeat
          for i:=1 to maxammotype do
            if canfire(player,i) then
              fire(player,fx,i);
        until true;
      1:repeat
         { for i:=1 to maxammotype do
           if canfire(player,i) then fire(player,fx,i);
          for i:=0 to maxfx-1 do
           if firesafe(zb.x,zb.y,i) then
             new_mob(zb.x,zb.y,i,playerskillfiretype[occup],xu);   }
          catchmob(zb.x,zb.y);
          if random(15)<>0 then break;
          i:=0;
          repeat
            inc(i);
            n:=random(maxai)+1;
          until ai[n].living or (i=maxai*3);
          if ai[n].living=false then break;
          if ((setting.gamemode=1)=false) and (profile.ammo[playerskillfiretype[occup]]<3) then break;
          if ((setting.gamemode=1)=false) then dec(profile.ammo[playerskillfiretype[occup]],3);
          for i:=0 to maxfx-1 do
           with ai[n].zb do
            for j:=1 to 2 do
            begin
              t:=new_mob(x+(random(2)+1)*gox[i],y+(random(2)+1)*goy[i],(i+2) mod maxfx,playerskillfiretype[occup],xu);
              if t<>-1 then
              begin
                inc(mob[t].lmt.tick,playeroccup1skillwait);
                mob[t].hp:=3;
              end;
            end;
        until true;
      2:begin
        end;
      3:repeat
          flg:=false;
          if tick=skill.start.tick+1 then
          begin
            if ((setting.gamemode=1)=false) and (profile.ammo[3]<5) then break;
            if ((setting.gamemode=1)=false) then dec(profile.ammo[3],5);
            for i:=10 to 30 do
            if (i>20) or (random(3)<>0) then
             begin
               t:=new_mob(zb.x,zb.y,fx,playerskillfiretype[occup],xu);
               if t=-1 then continue;
               mob[t].speed:=TNTexplodelast div i;
               flg:=true;
             end;
          end;
          if tick-skill.start.tick>=TNTexplodelast+1 then
          begin   
            if ((setting.gamemode=1)=false) and (profile.ammo[3]<5) then break;
            if ((setting.gamemode=1)=false) then dec(profile.ammo[3],1);
            t:=new_mob(zb.x,zb.y,fx,playerskillfiretype[occup],xu);
            if t=-1 then break;
            mob[t].speed:=random(3);
            mob[t].speed:=random(mob[t].speed);
            flg:=true;
          end;
          if (flg) then playfiremusic(playerskillfiretype[occup]);
        until true;
      4:repeat              
          if ((setting.gamemode=1)=false) and (profile.ammo[playerskillfiretype[occup]]<=0) then break;
          if ((setting.gamemode=1)=false) and ((tick mod 5)>1) then dec(profile.ammo[playerskillfiretype[occup]]);
          x:=random(maxfx)+1;
          playfiremusic(playerskillfiretype[occup]);
          for i:=1 to x do
          begin
            t:=random(maxfx);
            x:=new_mob(zb.x+gox[t],zb.y+goy[t],fx,playerskillfiretype[occup],xu);
            mob[x].hp:=2;
          end;
        until true;
      5:repeat
          if ((setting.gamemode=1)=false) and (profile.prop[1]<1) then break;
          if ((setting.gamemode=1)=false) then dec(profile.prop[1],1);
          explode(zb.x,zb.y,playeroccup5explodehard,xu,0);
          for i:=1 to maxfx do
          begin
            t:=random(maxfx);
            explode(zb.x+gox[t],zb.y+goy[t],playeroccup5explodehard,xu,0,1);
          end;
          if random(2)=0 then hurt_tank(player,1,1,0);
          if living=false then explode(zb,TNTexplodehard,xu,0,1);
        until true;
    end;//end case
  end;//end with
end;

procedure savescreenshot;
var wj:text;
    i,j:longint;
    s,c:string;
    year,month,day,wday,hour,minute,second,s100:word;
begin
  s:='screenshot\Screenshot ';
  dos.getdate(year,month,day,wday);
  dos.gettime(hour,minute,second,s100);
  s:=s+inttostr(year)+'_'+inttostr(month)+'_'+inttostr(day)+'_'+inttostr(hour)+'_'+inttostr(minute)+'_'+inttostr(second)+'_';
  if s100<10 then s:=s+'0';
  s:=s+inttostr(s100);
  i:=0; str(i,c);
  if fsearch(s+c+'.screenshotdata','\')<>'' then
  repeat
    if i=maxlongint then exit;
    inc(i);
    str(i,c);
  until fsearch(s+'('+c+').screenshotdata','\')='';
  if i<>0 then s:=s+'('+c+')';
  s:=s+'.screenshotdata';
  assign(wj,s);
  rewrite(wj);
  for i:=1 to maxx do
   for j:=1 to maxy do
    with newsc[i,j] do
    begin
      writeln(wj,col,' ',bg,' ',ord(ch[1]),' ',ord(ch[2]));
    end;//end with
  close(wj);
end;

procedure print_ammo;
var i,ii:longint;
begin
  tb(0);
  for ii:=1 to setting.playernum do
   with player[ii] do
   begin                                          
     i:=ammotype;
     if lamt[ii]<>ammotype then oammo[ii,i]:=-233;
     lamt[ii]:=i;
     with profile do
     begin
       if oammo[ii,i]=ammo[i] then continue;
       oammo[ii,i]:=ammo[i];
       tc(8);if i=ammotype then tc(15);gotoxy(26,maxy+3);if ii=2 then gotoxy(wherex,wherey+1);
       write(ammonam[i],':   ');
       gotoxy(wherex-3,wherey);
       if i=1 then write('∞ ') else write(ammo[i]);
      end;//end with&for
   end;
end;

procedure work_command;
const startx=41;
      starty=23;
      maxlen=24;
var i,l,n,t,x,y,z,id,typ,nowmem,a,b:longint;
    s:string;
    st:array[1..100] of string;
    c:char;
    p:Tpos;
    isend,reprt:boolean;
begin           
  isend:=false;
  repeat
    tb(0); tc(7);
    cursoroff;
    gotoxy(startx,starty);
    for i:=1 to maxlen do write(' ');
    l:=0; s:='';
    nowmem:=cmdmemcnt+1;
    gotoxy(startx,starty);
    cursoron;
    repeat //start read
      c:=readkey;
      case c of
        'a'..'z',' ','-','0'..'9','A'..'Z','_':
        begin
          if (l<maxlen-1) then
          begin
            inc(l);
            s:=s+c;
            write(c);
          end;
        end;
        #8:
        begin
          if (l>0) then
          begin
            dec(l);
            delete(s,length(s),1);
            gotoxy(wherex-1,wherey);
            write(' ');              
            gotoxy(wherex-1,wherey);
          end;
        end;
        #27:
        begin
          isend:=true;
          break;
        end;
        #13:
        begin
          isend:=l=0;
          break;
        end;
        #0:
        begin
          c:=readkey;
          reprt:=false;
          case c of
            #72: //up
            begin
              if (nowmem>1) then 
              begin
                dec(nowmem); 
                reprt:=true;
              end;
            end;
            #80: //down
            begin
              if (nowmem<=cmdmemcnt) then 
              begin
                inc(nowmem); 
                reprt:=true;
              end;
            end;
            #28:    
            begin
              isend:=l=0;
              break;
            end;
          end;
          if reprt then
          begin
            cursoroff;
            tb(0); tc(7);
            gotoxy(startx,starty);
            write(cmdmem[nowmem]);
            for i:=length(cmdmem[nowmem])+1 to maxlen do write(' ');
            gotoxy(wherex-maxlen+length(cmdmem[nowmem]),wherey);
            s:=cmdmem[nowmem];
            l:=length(s);
            cursoron;
          end;
        end;//end #0
      end;
    until false;//end read
    if (isend) then break;
    n:=0;
    if (cmdmemcnt<maxcmdmem) then
    begin
      inc(cmdmemcnt);
      cmdmem[cmdmemcnt]:=s;
    end;   
    s:=upcase(s);
    while (pos(' ',s)<>0) do
    begin
      t:=pos(' ',s);
      inc(n);
      st[n]:=copy(s,1,t-1);
      delete(s,1,t);
    end;
    inc(n);
    st[n]:=s;
    if (st[1]='SUMMON_ENEMY') or (st[1]='SUMMONENEMY') or (st[1]='SE') then
    repeat
      if (n<2) then break;
      val(st[2],z,t);if (t<>0) then break;
      if (z<0) or (z>maxoccup) then break;
      x:=-1;
      y:=-1;
      if (n=4) then
      begin
        val(st[3],x,t);if (t<>0) then break;
        val(st[4],y,t);if (t<>0) then break;
        if (x<1) or (x>maxx) or (y<1) or (y>maxy) then break;
      end;
      p.x:=x;
      p.y:=y;
      id:=new_ai(1,z,p);
      if (id<>-1) then
      begin
        print_tank(ai[id]);
        print_screen(ai[id].zb.x,ai[id].zb.y);
      end;
      cmdused:=true;
    until true
    else if (st[1]='SET_BLOCK') or (st[1]='SETBLOCK') or (st[1]='SB') then
    repeat
      if (n<4) then break;
      val(st[2],x,t);if (t<>0) then break;
      val(st[3],y,t);if (t<>0) then break;
      val(st[4],typ,t);if (t<>0) then break;                             
      if (x<1) or (x>maxx) or (y<1) or (y>maxy) then break;
      if (typ<0) or (typ>maxblocktype) or (typ in [4,5]) then break;
      a:=0; b:=0;
      if (n=6) then
      begin
        val(st[5],a,t);if (t<>0) then break;
        val(st[6],b,t);if (t<>0) then break;
      end;
      with mm.map[x,y] do
      begin
        if (id in [4,5]) then break;
        id:=typ;
        fx:=a; fj:=b;
        hard:=blockmaxhard[typ];
        maxhard:=blockmaxhard[typ];
        unbreakble:=false;
      end; //end with
      print_block(x,y);
      print_screen(x,y);
      cmdused:=true;
    until true
    else if (st[1]='HEAL') or (st[1]='HE') then
    begin               
      cmdused:=true;
      for i:=1 to setting.playernum do
        if player[i].living then
          player[i].hp:=player[i].maxhp;
    end
    else if (st[1]='CLEAR_CD') or (st[1]='CLEARCD') or (st[1]='CC') then
    begin          
      cmdused:=true;
      for i:=1 to setting.playernum do
        if player[i].living then
          with player[i].skill do
          begin
            start.tick:=-1000;
            stop.tick:=-1000;
            use.tick:=-1000;
          end;
    end
    else if (st[1]='KILL_ALL') or (st[1]='KILLALL') or (st[1]='KA') then
    begin               
      cmdused:=true;
      for i:=1 to maxai do
        if (ai[i].living) then
          hurt_tank(ai[i],ai[i].hp,1,0);
    end
    else if (st[1]='EXPLODE') or (st[1]='EX') then
    begin
      if (n<4) then break;
      val(st[2],x,t);if (t<>0) then break;
      val(st[3],y,t);if (t<>0) then break;
      val(st[4],z,t);if (t<>0) or (z<0) or (z>maxexplodehard) then break;
      a:=0;
      b:=0;
      if (n>=5) then
      begin
        val(st[5],a,t);if (t<>0) then break;
        if (n>=6) then
        begin           
          val(st[6],b,t);if (t<>0) or ((b<>0) and (b<>1)) then break;
        end;
      end;           
      cmdused:=true;
      explode(x,y,z,a,b,0);
    end
    else if (st[1]='GAMEHARD') or (st[1]='GH') then
    begin
      if (n<2) then break;
      val(st[2],x,t);if (t<>0) or (x<0) or (x>maxgamehard) then break;
      setting.gamehard:=x;
      cmdused:=true;
    end
    else if (st[1]='GAMEMODE') or (st[1]='GM') then
    begin
      if (n<2) then break;
      val(st[2],x,t);if (t<>0) or (x<0) or (x>maxgamemode) then break;
      setting.gamemode:=x;
      cmdused:=true;
    end
    else if (st[1]='SET') and (st[2]='PLAYER') then
    begin
      if (n<3) then break;
      val(st[3],x,t);if (t<>0) or (x<1) or (x>maxplayer) then break;
      setting.playernum:=x;
      cmdused:=true;
    end
    else if (st[1]='SET') and (st[2]='MUSIC') then
    begin
      if (n<3) then break;
      val(st[3],x,t);if (t<>0) or (x<0) or (x>1) then break;
      setting.musicon:=x;
    end
    else if (st[1]='TICK_LAST') or (st[1]='TICKLAST') or (st[1]='TL') then
    begin
      if (n<2) then break;
      val(st[2],x,t);if (t<>0) or (x<0) then break;
      ticklast:=x;
      cmdused:=true;
    end
    else if (st[1]='TICK_RATE') or (st[1]='TICKRATE') or (st[1]='TR') then
    begin
      if (n<2) then break;
      val(st[2],x,t);if (t<>0) or (x<=0) then break;
      ticklast:=round(1000/x);        
      cmdused:=true;
    end;
  until isend;
  gotoxy(41,23);
  tb(0); tc(7);
  for i:=1 to maxlen div 2 do write('═');
  cursoroff;
end;

function work_keypressed:longint;
var c:char;
    t:longint;
   procedure usingskill(var player:Ttank);
   begin
     with player do
     begin
       skillusing:=not skillusing;
       if skillusing then gt(skill.start)
        else gt(skill.stop);
       if occup=2 then
       begin
         if skillusing=false then playmusic('music\skill2_end.wav');
         gt(lmt);
         inc(lmt.tick,-tankspeed[0,2]+occupskilltime[2,3]);
       end;
     end;
   end;
begin
  if keypressed=false then exit(0);
  c:=upcase(readkey);
  case c of
    'W':gof[1]:=0;
    'A':gof[1]:=3;
    'S':gof[1]:=2;
    'D':gof[1]:=1;
    'I':if setting.playernum=1 then firef[1]:=0;
    'J':if setting.playernum=1 then firef[1]:=3;
    'K':if setting.playernum=1 then firef[1]:=2;
    'L':if setting.playernum=1 then firef[1]:=1
      else if setting.playernum=2 then gof[2]:=3;
    ' ':usingskill(player[1]);
    'T':if setting.playernum=2 then firef[1]:=0;
    'F':if setting.playernum=2 then firef[1]:=3;
    'G':if setting.playernum=2 then firef[1]:=2;
    'H':if setting.playernum=2 then firef[1]:=1;
    'P':if setting.playernum=2 then gof[2]:=0;
    ';':if setting.playernum=2 then gof[2]:=2;
    '''':if setting.playernum=2 then gof[2]:=1;
    #9:begin
         player[1].ammotype:=(player[1].ammotype mod maxammotype)+1;
         print_ammo;
       end;
    'O':if setting.playernum=2 then
        begin
          player[2].ammotype:=(player[2].ammotype mod maxammotype)+1;
          print_ammo;
        end;
    '`','1'..'5':with player[1] do
             begin
               if (c='`') then t:=0
               else val(c,t);
               if living then
               repeat
                 if t>maxproptype then break;
                 if mm.map[zb.x,zb.y].id<>0 then break;
                 if t>maxproptype then break;
                 if profile.prop[t]<=0 then break;
                 dec(profile.prop[t]);
                 init_prop(zb.x,zb.y,t,-1);
               until true
                else repeat
                  if (profile.occupown[t]=false) then break;
                  occup:=t;
                  init_tip('玩家1职业更改为:'+occupnam[0][t],7,changeoccuptipshowlast);
                until true;
             end;//end case
    '7','8','9','0','-','=':with player[2] do
                         if setting.playernum>1 then
                         begin
                           case c of
                             '7':t:=0;
                             '8':t:=1;
                             '9':t:=2;
                             '0':t:=3;
                             '-':t:=4;
                             '=':t:=5;
                           end;
                           if living then
                           repeat
                             if t>maxproptype then break;
                             if mm.map[zb.x,zb.y].id<>0 then break;
                             if t>maxproptype then break;
                             if profile.prop[t]=0 then break;
                             dec(profile.prop[t]);
                             init_prop(zb.x,zb.y,t,-2);
                           until true//end case
                            else repeat
                              if (profile.occupown[t]=false) then break;
                              occup:=t;
                              init_tip('玩家2职业更改为:'+occupnam[0][t],7,changeoccuptipshowlast);
                            until true;//end case
                         end;//end case
    #0:begin
         c:=readkey;
         case c of
           'H':if setting.playernum=2 then firef[2]:=0;
           'K':if setting.playernum=2 then firef[2]:=3;
           'P':if setting.playernum=2 then firef[2]:=2;
           'M':if setting.playernum=2 then firef[2]:=1;
           ']':if setting.playernum=2 then usingskill(player[2]);
           #83:if player[1].living then
               repeat
                 t:=new_mob(player[1].zb.x,player[1].zb.y,player[1].fx,4,-1);
                 if t=-1 then break;
                 mob[t].speed:=0;
               until true;
           #60:savescreenshot;
         end;//end case
       end;//end #0:
    #27:begin
          close(f_usedtime);
          if gamewin or gamelose then exit(1)
           else exit(2);
        end;
    #8:begin
         while readkey<>#13 do;
       end;
    '/':begin
          work_command;
        end;
  end;//end case
end;

function play:longint;
var oldtime,newtime,ov,nv,oz,nz:Ttime;
    i,t:longint;
    worked:boolean;

   procedure beforetickwait;
   var i,playern:longint;
   begin
     if ((tick mod 2)*random(2)=0) then explodemusicplayed:=false;
     if (gamewin=false) and (gamelose=false) then
     begin
       gamelose:=true;
       for i:=1 to setting.playernum do
        if player[i].lives>0 then gamelose:=false;
       if gamelose and (gameendtick=-1) then gameendtick:=tick;
     end;
     for playern:=1 to setting.playernum do
      with player[playern] do
      repeat
        if living=false then
        begin
          if tick>=ldt.tick+dyinglast then
          begin
            if tick=ldt.tick+dyinglast then print_auto(zb);
            if (tick>ldt.tick+dyinglast+spawnwait) and (lives>0) then
            begin
              init_tank(player[playern],0,player[playern].occup);
              gotoxy(4,maxy+2+playern);tb(0);tc(7);write(occupnam[0,occup]);
            end;
          end
           else repeat
             if mm.map[zb.x,zb.y].id in [9] then break;
             if (tick-ldt.tick) mod dyingblinklast<=dyingblinklast div 2 then print(zb,-1,15,'  ')
              else if playern=1 then print(zb,tankbackground[0],15,tankchar[0,occup,fx])
               else if playern=2 then print(zb,3,15,tankchar[0,occup,fx]);
           until true;
        end;//end if living=false
      until true;//end with
   end;

   procedure aftertickwait;
   var i,playern:longint;
   begin
     for playern:=1 to setting.playernum do
      with player[playern] do if living then
      begin
        if gof[playern]<>-1 then
         if canmove(player[playern],gof[playern]) then move(player[playern],gof[playern]);
        if unbreakble and (tick mod unbreakbleblinklast>=unbreakbleblinklast div 2) then
        begin
          print_block(zb);
          print_mob(whichmob(zb));
        end
         else print_tank(player[playern]);
        if tick-lst.tick=unbreakblelast+1 then unbreakble:=false;

        if (firef[playern]<>-1) and (firef[playern]<>fx) then
        begin
          fx:=firef[playern];
          print_tank(player[playern]);
        end;
        i:=0;
        if firef[playern]<>-1 then
        repeat
          inc(i);
          if canfire(player[playern],ammotype) then fire(player[playern],fx,ammotype);

        until true;
        print_ammo;
      end;//end for&with
   end;

begin
  gt(fpsb);
  print_map;
  print_ammo;     assign(f_usedtime,'UsedTime.log');rewrite(f_usedtime);
  fillchar(lamt,sizeof(lamt),255);
  if upcase(mm.nam)='LOGO' then delay(5000);

  repeat{******************************************************************}

    gt(oz);gt(ov);{-------}
    tick:=tick+1;write(f_usedtime,'Tick',tick,': ');    
    if ((profile.ammo[1]>999) or (profile.ammo[2]>999)) and (random(2)=0) and (tick mod 1000=0) and (tick>0) and (bosstime=false) then new_ai(1,0);
    if tick>=round(mm.startspawntick/spawnadd[setting.gamehard]) then
    begin
      for i:=1 to maxoccup do
       if mm.spawnprobability[i]<>maxlongint then
        if random(round(mm.spawnprobability[i]/spawnadd[setting.gamehard]))=0 then
          new_ai(1,i);
    end; //end if tick>=startspawntick

    gt(oldtime);{-------}
    fillchar(gof,sizeof(gof),255);
    fillchar(firef,sizeof(firef),255);
    worked:=false;
    repeat//================================================================================
      if worked=false then
      begin
                                                                      gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        beforetickwait;                                               gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        print_screen(1);                                              gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        work_tip;                                                     gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        work_block;                                                   gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        for i:=1 to setting.playernum do work_occupskill(player[i]);  gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        work_mob;                                                     gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        work_ai;                                                      gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        print_game_info;                                              gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
        worked:=true;
      end;
      t:=work_keypressed;
      case t of
        0:       ;
        1:exit(0);
        2:exit(1);
      end;
      gt(newtime);
      if setting.gamemode=2 then break;
    until td(oldtime,newtime)>=ticklast;//================================================================================
    gt(nv);write(f_usedtime,td(ov,nv),' ');gt(ov);{-------}
    aftertickwait;

    gt(nv);write(f_usedtime,td(ov,nv),' ');{-------}
    gt(nz);writeln(f_usedtime,td(oz,nz));{-------}
  until false;{******************************************************************}
  tc(7);tb(0);
end;

function chooseoccup:longint;
var playern,cnt:longint;
    n,i,maxlen:longint;
    a:array[1..maxoccup+1] of longint;
begin
  for playern:=1 to setting.playernum do
  begin
    clrscr;
    gotoxy_mid('选择职业',1);tb(0);tc(15);write('选择职业');
    gotoxy_mid('Player'+inttostr(playern),wherey+1);tb(0);tc(14);write('Player'+inttostr(playern));
    choosestr:='';
    maxlen:=4;
    cnt:=0;
    for i:=0 to maxoccup do
      if (profile.occupown[i]) then
      begin
        inc(cnt);
        a[cnt]:=i;
        choosestr:=choosestr+occupnam[0,i]+ln;
        maxlen:=max(maxlen,length(occupnam[0,i]));
      end;
    choosestr:=choosestr+'返回';
    gotoxy_mid(getastr(maxlen+6),wherey+1);
    n:=chooseone();
    if n=cnt+1 then exit(1);
    player[playern].occup:=a[n];
  end;
  exit(0);
end;

procedure work_game;
const interval:array[1..2] of longint=(0,13);
var i,playern,occup,n,x,y:longint;
    playexit:longint;
    ot,nt:Ttime;

   procedure print_score(x,y,n:longint);
   var i:longint;
   begin
     for i:=0 to n-1 do
     begin
       gotoxy(x,y);
       write(i);
       crt.delay(max(trunc(500/n),1));
       if keypressed then break;
     end;
     gotoxy(x,y);
     write(n);
     while keypressed do readkey;
   end;

   procedure print_assess(x,y,cl:longint;s:string);
   const maxc=2;
         maxa=255;
         wait=200;
         c:array[1..maxc] of longint=(8,7);
   var i,j,max:longint;
       a:array[1..maxa] of longint;
   begin
     max:=maxc+1;
     for i:=1 to maxc do
      if cl=c[i] then
      begin
        max:=i;
        break;
      end;
     for i:=1 to maxa do
       a[i]:=-i+1;
     repeat
       for j:=1 to maxa do a[j]:=min(max,a[j]+1);
       gotoxy(x,y);
       for j:=1 to length(s) do
       begin
         if a[j]<=0 then continue
          else if a[j]<max then tc(c[a[j]])
           else tc(cl);
         write(s[j]);
       end;//end for j
       crt.delay(wait);
       if a[length(s)]=max then break;
       if keypressed then break;
     until false;
     gotoxy(x,y);
     tc(cl);write(s);
     while keypressed do readkey;
   end;

begin
  clear_map;
  gotoxy(1,1);clreol;gotoxy_mid('Reading "+SettingFileNam+"...',1);tc(7);write('Reading "',SettingFileNam,'"...');
  read_setting;
  gotoxy(1,1);clreol;
  
  clrscr;
  choosestr:='';
  for i:=1 to levelnum do
    choosestr:=choosestr+level[i].filenam+ln;
  choosestr:=choosestr+'返回';
  maxlevelnamlen:=max(maxlevelnamlen,length('返回'));
  repeat
    clrscr;
    gotoxy_mid('选择关卡',1);tc(15);tb(0);write('选择关卡');
    gotoxy_mid(getastr(maxlevelnamlen+6),2);nowlevel:=chooseone();
    if nowlevel=levelnum+1 then exit;
    ismainlevel:=false;
    if level[nowlevel].ismainlevel then
    begin
      if profile.levelunlock[nowlevel]=false then
      begin
        //clrscr;
        gotoxy(1,1);clreol;
        gotoxy_mid('关卡未解锁',1);tb(0);tc(12);write('关卡未解锁');
        delay(500);
        gotoxy(1,nowlevel+1);clreol;
        gotoxy(1,levelnum+3);clreol;
        continue;
      end;
      ismainlevel:=true;
    end;
    break;
  until false;
  mm:=level[nowlevel];

  n:=chooseoccup;
  if n=1 then exit;
  {■■■■}
  init_game;
  playexit:=play;
  end_game;
  {■■■■}
  if playexit=1 then
  begin
    gotoxy_mid('Saving...',1);tb(0);tc(7);write('Saving...');
    save;
    exit;
  end;
  if gamewin then
  begin
    gotoxy_mid('胜利',windmaxy-3);tc(12);tb(0);write('胜利');
    playmusic('music\gamewin.wav');
    with profile do
    repeat
      if nowlevel>mainlevelnum then break;
      if levelfinish[nowlevel]=false then
       for i:=1 to mainlevelnum-1 do
        if levelunlock[i] and (levelunlock[i+1]=false) then
        begin
          levelunlock[i+1]:=true;
          delay(400);
          gotoxy_mid('关卡'+inttostr(i+1)+'解锁',wherey+1);tb(0);tc(14);write('关卡',i+1,'解锁');
          break;
        end;
      levelfinish[nowlevel]:=true;
      if ((setting.gamemode=1)=false) and (cmdused=false) then
      begin
        inc(money,levelwinprize[nowlevel]);
        gotoxy_mid('金钱增加'+inttostr(levelwinprize[nowlevel]),wherey+1); tb(0); tc(14); write('金钱增加',levelwinprize[nowlevel]);
      end;
    until true;//end with
  end
  else if gamelose then
  begin
    gotoxy_mid('失败',windmaxy-1);
    tc(10);tb(0);write('失败');
    playmusic('music\gameover.wav');
    with profile do
    begin
    end;//end with
  end
  else begin
    gotoxy_mid('和局',windmaxy-1);
    tc(7);tb(0);write('和局');
  end;
  
  gotoxy(1,1);
  gotoxy_mid('当前关卡 '+level[nowlevel].filenam); tb(0); tc(8); write('当前关卡 '); tc(15); writeln(level[nowlevel].filenam);
  gotoxy_mid('胜负决出于 Tick '+inttostr(gameendtick),wherey);tb(0);tc(8);write('胜负决出于 Tick ');tc(15);write(gameendtick);
  gotoxy_mid('杀敌数目',wherey+2);tc(11);tb(0);write('杀敌数目');
  x:=windmaxx div 2-2;y:=wherey+1;if setting.playernum=2 then x:=windmaxx div 2-8;
  for i:=1 to setting.playernum do
  begin
    tb(0);tc(15);gotoxy(x+interval[i]-1,y);write(player[i].nam,i);
  end;
  for occup:=1 to maxoccup do
  begin
    for playern:=1 to setting.playernum do
    begin
      gotoxy(x+interval[playern],y+occup);tb(tankbackground[1]);tc(color(random(101),100));write(tankchar[1,occup,0]);
      tb(0);tc(7);write(':');
      tb(0);tc(7);print_score(wherex,wherey,killnum[playern,occup]);
    end;//end for
  end;//end for occup

  gotoxy_mid('死亡次数',wherey+2);tb(0);tc(4);write('死亡次数');
  gotoxy(wherex,wherey+1);
  for playern:=1 to setting.playernum do
  begin
    gotoxy(x+interval[playern],wherey);tb(tankbackground[0]);if playern=2 then tb(player2color);tc(tankcolor[0]);write(tankchar[0,1,0]);
    tb(0);tc(7);write(':');
    tb(0);tc(7);print_score(wherex,wherey,dietimes[playern]);
  end;
  gotoxy_mid('得分',wherey+2); tb(0);tc(15);                  write('得分');
  gotoxy_mid(inttostr(score)+' ',wherey+1); tb(0);tc(7);          print_score(wherex,wherey,score);
  if ismainlevel then
  begin
    gotoxy_mid('评价',wherey+1);    tb(0);tc(15);   write('评价');
                                    tb(0);          print_assess((windmaxx-length(assesschar[assess])-1) div 2,wherey+1,assesscolor[assess],assesschar[assess]);
  end;

  gt(ot);
  save;
  repeat
    gt(nt);
  until td(ot,nt)>=100;
  readkey;
end;

procedure shop;
var i,n,choose,cnt,mxl:longint;
    a:array[1..maxoccup] of longint;
    ss:string;
begin
  clrscr;
  gotoxy_mid('商店',1);tb(0);tc(11);write('商店');
  windminy:=2;
  repeat
    clrscr;
    gotoxy_mid('弹药'+getastr(6),1);
    choosestr:='弹药'+ln+
               '道具'+ln+
               '职业'+ln+
               '返回';
    tb(0);tc(7);choose:=chooseone();
    if choose=4 then break;
    clrscr;
    case choose of
      1:begin
          choosestr:='';
          for i:=2 to maxammotype do
            choosestr:=choosestr+ammonam[i]+ln;
          choosestr:=choosestr+'返回';
          gotoxy_mid(getastr(10),1);tb(0);tc(7);choose:=chooseone()+1;
          if choose=maxammotype+1 then continue;
          clrscr;
          i:=0;
          repeat
            clrscr;
            gotoxy_mid('金钱:'+inttostr(profile.money),1);                                    tc(7);tb(0);  write('金钱:',profile.money);
            gotoxy_mid(ammonam[choose]+inttostr(ammoprice[choose])+'元/发',2);             tc(7);tb(0);  write(ammonam[choose],ammoprice[choose],'元/发');
            gotoxy_mid('请输入要购买的数量'+'(已有'+inttostr(profile.ammo[choose])+'发)',3);  tc(7);tb(0);  write('请输入要购买的数量'+'(已有'+inttostr(profile.ammo[choose])+'发)');

            n:=0;
            gotoxy(1,4);clreol;
            tb(7);tb(0);gotoxy(38,4);inputint(n,min(999-profile.ammo[choose],profile.money div ammoprice[choose]),0);
            if n=0 then
            begin
              i:=5;
              break;
            end;

            if (n+profile.ammo[choose]<=999) and (profile.money>=n*ammoprice[choose]) then break;
            if profile.money<n*ammoprice[choose] then
            begin
              gotoxy_mid('金钱不足',wherey+1);tc(4);tb(0);write('金钱不足');
            end;
            if n+profile.ammo[choose]>999 then
            begin
              gotoxy_mid('超出数量限制(999)',wherey+1);tc(4);tb(0);write('超出数量限制(999)');
            end;
            delay(500);
            inc(i);
          until i=5;
          if i=5 then continue;
          with profile do
          begin
            inc(ammo[choose],n);
            dec(money,n*ammoprice[choose]);
          end;
        end;//end case 1
      2:begin
          choosestr:='';
          for i:=1 to maxproptype do
            choosestr:=choosestr+propnam[i]+ln;
          choosestr:=choosestr+'返回';
          gotoxy_mid(getastr(10),1);tb(0);tc(7);choose:=chooseone();
          if choose=maxproptype+1 then continue;
          clrscr;
          i:=0;
          repeat
            clrscr;
            gotoxy_mid('金钱:'+inttostr(profile.money),1);                                    tc(7);tb(0);  write('金钱:',profile.money);
            gotoxy_mid(propnam[choose]+inttostr(propprice[choose])+'元/个',2);             tc(7);tb(0);  write(propnam[choose],propprice[choose],'元/个');
            gotoxy_mid('请输入要购买的数量'+'(已有'+inttostr(profile.prop[choose])+'个)',3);  tc(7);tb(0);  write('请输入要购买的数量'+'(已有'+inttostr(profile.prop[choose])+'个)');
                                                                                           tc(8);tb(0);  write('(已有',profile.prop[choose],'个)');
            n:=0;
            gotoxy(1,4);clreol;
            tb(7);tb(0);gotoxy(38,4);inputint(n,min(999-profile.prop[choose],profile.money div propprice[choose]),0);
            if n=0 then
            begin
              i:=5;
              break;
            end;

            if (n+profile.prop[choose]<=999) and (profile.money>=n*propprice[choose]) then break;
            if profile.money<n*propprice[choose] then
            begin
              gotoxy_mid('金钱不足',wherey+1);tc(4);tb(0);write('金钱不足');
            end;
            if n+profile.prop[choose]>999 then
            begin
              gotoxy_mid('超出数量限制(999)',wherey+1);tc(4);tb(0);write('超出数量限制(999)');
            end;
            delay(500);
            inc(i);
          until i=5;
          if i=5 then continue;
          with profile do
          begin
            inc(prop[choose],n);
            dec(money,n*propprice[choose]);
          end;
        end;
      3:begin
          choosestr:='';
          cnt:=0;
          mxl:=4;
          for i:=0 to maxoccup do
           if (profile.occupown[i]=false) then
           begin
             ss:=occupnam[0][i]+' (售价:'+inttostr(occupprice[i])+')';
             mxl:=max(mxl,length(ss));
             choosestr:=choosestr+ss+ln;
             inc(cnt);
             a[cnt]:=i;
           end;
          choosestr:=choosestr+'返回';
          gotoxy_mid(mxl+6,1);tb(0);tc(7);choose:=chooseone();
          if choose=cnt+1 then continue;
          choose:=a[choose];
          if (profile.money<occupprice[choose]) then
          begin                          
            clrscr;
            gotoxy_mid('金钱不足',wherey+1);tc(4);tb(0);write('金钱不足');    
            delay(500);
            continue;
          end;
          with profile do
          begin
            dec(money,occupprice[choose]);
            occupown[choose]:=true;
          end;
        end;
    end;//end case
    gotoxy_mid('购买成功',wherey+1);tc(12);tb(0);write('购买成功');
    gotoxy_mid('剩余金钱:'+inttostr(profile.money),wherey+1);tc(7);tb(0);write('剩余金钱:',profile.money);
    readkey;
  until false;
  save;
  windminy:=1;
end;

procedure setsetting;
var s:string;
begin
  clrscr;
  s:='当前设置';
  gotoxy_mid(s);tb(0);tc(7);writeln(s);
  writeln('游戏难度：',setting.gamehard);
  writeln('游戏模式：',setting.gamemode);
  writeln('玩家人数：',setting.playernum);
  writeln('开启音效：',setting.musicon);
  exec('notepad.exe',path+'\'+settingfilenam);       
  readkey;
  read_setting;
end;

procedure print_text(fn:string);
var f:text;
    s,ss:string;
    i,l:longint;
    fst:boolean;
   function trans(c:char):longint;
   begin
     c:=upcase(c);
     if (c in ['0'..'9']) then trans:=ord(c)-ord('0')
     else trans:=ord(c)-ord('A')+10;
   end;
begin
  clrscr;
  if (fsearch(fn,'\')='') then exit;
  assign(f,fn);
  reset(f);
  l:=0;
  fst:=true;
  while (eof(f)=false) do
  begin
    readln(f,s);
    if (length(s)>=2) and (s[1]='\') and (s[2]='\') then
    begin
      readkey;
      fst:=true;
      clrscr;
    end
    else begin       
      if fst then l:=length(s);
      if (length(s)>=2) and (s[1]='\') and (s[2]='l') then l:=length(s)-2;
      tb(0); tc(7);
      i:=1;
      ss:='';
      if fst=false then writeln;
      gotoxy_mid(l);
      fst:=false;
      while (i<=length(s)) do
      begin
        if (s[i]='\') then
        repeat
          if (s[i+1]='l') then
          begin
            inc(i);
            break;
          end;
          tb(trans(s[i+1]));
          tc(trans(s[i+2]));
          inc(i,2);
        until true
        else ss:=ss+s[i];
        if (length(ss)=2) or (ord(ss[1])<128) then
        begin
          write(ss);
          ss:='';
        end;
        inc(i);
      end; //end while i
    end;
    tb(0); tc(7);
  end;
  close(f);
  readkey;
end;

procedure help;
var choose:longint;
begin
  clrscr;
  gotoxy_mid('帮助＆图鉴',1);tb(0);tc(11);write('帮助＆图鉴');
  windminy:=2;
  repeat
    clrscr;
    gotoxy_mid('游戏目标'+getastr(6));
    choosestr:='游戏目标'+ln+
               '键位说明'+ln+
               '方块类型'+ln+
               '实体类型'+ln+
               '敌人种类'+ln+
               '职业介绍'+ln+
               '设置参数'+ln+
               '指令详情'+ln+
               '其他信息'+ln+
               '返回';
    choose:=chooseone();
    case choose of
      1:print_text('bin\help_gamegoal.txt');
      2:print_text('bin\help_keyboard.txt');
      3:print_text('bin\help_block.txt');
      4:print_text('bin\help_entity.txt');
      5:print_text('bin\help_enemy.txt');
      6:print_text('bin\help_occupation.txt');
      7:print_text('bin\help_setting.txt');
      8:print_text('bin\help_command.txt');
      9:print_text('bin\help_other.txt');
      10:break;
    end;
    clrscr;
  until false;
  windminy:=1;
end;

procedure work_main;
var choose:longint;
begin
  repeat
    clrscr;
    gotoxy_mid('帮助＆图鉴'+getastr(6),windminy);
    if logged then choosestr:='开始游戏'  +ln+
                              '商店'      +ln+
                              '账号信息'  +ln+
                              '帮助＆图鉴'+ln+
                              '设置'      +ln+
                              '退出'
              else choosestr:='开始游戏'  +ln+
                              '商店'      +ln+
                              '登录'      +ln+
                              '帮助＆图鉴'+ln+
                              '设置'      +ln+
                              '退出';
    choose:=chooseone();
    case choose of
      1:begin
          work_game;
        end;
      2:shop;
      3:if logged then print_profile
         else logged:=load(1);
      4:help;
      5:setsetting;
      6:begin
          tc(0); tb(0);
          break;
        end;
    end;//end case
  until false;
end;

procedure test;
var s:string;
    i:longint;
    a:array[1..100] of string;
begin
  a[1]:='music\click.wav';
  a[2]:='music\fire_bullet1.wav';
  a[3]:='music\fire_bullet2.wav';
  a[4]:='music\fire_tnt.wav';
  a[5]:='music\fire_laser1.wav';
  a[6]:='music\fire_laser2.wav';
  a[7]:='music\fire_laser3.wav';
  a[8]:='music\fire_bomb.wav';
  setting.musicon:=1;createthread(nil,0,@runmusic,nil,0,tid);
  for i:=1 to 233333 do
  begin
    writeln(i);
    playmusic(a[random(1,8)]);
    delay(30);
  end;
  for i:=1 to 233333 do
  begin
    str(i,s);
    s:='open '+a[random(1,8)]+' alias m'+s+chr(0);
    writeln(i,' ',s,' ',mcisendstring(pchar(@s[1]),nil,0,0));
    str(i,s);
    s:='play m'+s+chr(0);
    writeln(i,' ',s,' ',mcisendstring(pchar(@s[1]),nil,0,0));
    str(i-50,s);
    s:='close m'+s+chr(0);
    writeln(i,' ',s,' ',mcisendstring(pchar(@s[1]),nil,0,0));
    writeln;
  end;
end;
BEGIN
//  test;
 // createthread(nil,0,@test,nil,0,tid);
//  while true do;

  clrscr;gotoxy_mid('Loading...',1);tb(0);tc(7);write('Loading...');
  byt:=0; getdir(byt,path);
  init_program;
  logged:=load(0);
  work_main;
END.
