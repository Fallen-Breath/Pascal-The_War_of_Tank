PROGRAM Map_Maker;

{$M 100000000,0,maxlongint}
{$inline on}

USES crt,dos{,mouse},betterinput;

CONST blinklast=40{tick};


      version='Beta 1.2.1';
      date='2014.7.5';

      maxx=38;
      maxy=21;
      maxfx=4;
      maxlevel=100;
      maxlujing=1000;
      maxtanktype=2;{玩家、敌人}
      maxai=1000;
      maxplayer=2;
      maxmob=1000;
      maxmobtype=4;{1子弹 2激光 3炸弹 4燃烧的TNT}

      maxharmtype=3;{1物理伤害 2能量伤害 3爆炸伤害}
      maxboomhard=15;
        boomharm:array[0..maxboomhard] of longint=(0,1,2,4,6,9,13,17,23,32,45,60,80,110,150,200);

      maxblock                 = maxx*maxy;
      maxblocktype             = 17;
      {0:空气    1:石头  2:砍手岩  3:河流      4:我方旗帜    5:敌方旗帜    6:坚硬的石头  7:超级无敌硬的石头 8:TNT 9:丛林
      10:发射器 11:地雷 12:黑又硬 13:能量防御 14:单向反射器 15:双向反射器 16:单向通行 17:单向破坏}
      blocknam         :array[0..maxblocktype] of string        = ('Air','Stone','Iron','Water','OurFlag','EnemyFlag','HardStone','HarderStone','TNT',
                                                                   'Forest','Launcher','Mine','ExplosionImmunityStone','EnergyImmunityStone',
                                                                   'SingleReflection','DoubleReflector','UnidirectionalThoughStone','UnidirectionalDestroyStone');
        blockmaxhard   :array[0..maxblocktype] of longint       = (0,1,-1,-1,-255,-255,3,8,1,-1,3,1,20,5,3,3,-1,1);
        cangoblock_tank                                         = [0,  9,11            ];
        cangoblock_mob                                          = [0,3,9,11,14,15,16,17];
        donotprintblock_tank                                    = [9            ];
        donotprintblock_mob                                     = [9,14,15,16,17];
        candestroyblock:array[1..maxharmtype] of set of 0..255  = ([1,4,5,6,7,8,10,   12,13,14,15,16,17],
                                                                   [1,4,5,6,7,8,10,   12   ,14,15,16,17],
                                                                   [1,4,5,6,7,8,10,      13,14,15      ]);
        cannotpierceblock                                       = [2,4,5,12,13];

      maxspawnpoint=2000;
      maxammo=999;
      maxammotype=3;{1子弹 2激光 3炸弹}
        ammonam:array[1..maxammotype] of string=('子弹','激光','炸弹');
        ammoprice:array[1..maxammotype] of longint=(0,10,50);

      maxprop=999;
      maxproptype=1;{1地雷}
        propnam:array[1..maxproptype] of string=('地雷');
        propprice:array[1..maxproptype] of longint=(70);

      maxoccup=5;{1:hunter猎手 2:defender防御者 3:destroyer破坏者 4:attacker攻击者 5:boomer自爆者}
        killaiprize:array[1..maxoccup] of longint=(500,300,200,200,100);

      maxgamehard=3{0简单 1普通 2困难 3地狱};
      mainlevelnum=6;
        mainlevelwinprize:array[1..mainlevelnum] of longint=(1000,1500,1500,2200,2000,2500);

      maxtip=1000;
      maxtiplength=40;

      ln=chr(13)+chr(10);
      bkbg=0;
      bkcl=7;

      ticklast=20{ms};
      {单位:tick}
      unbreakblelast=120;
      unbreakbleblinklast=10;
      dyinglast=60;
      dyingblinklast=20;
      TNTboomlast=80;
      TNTblinklast=21;
      block11boomwait=3;
      spawnwait=150;
      tipshowlast=40;

      TNTboomhard=7;
      mob3boomhard=3;
      occup5boomhard=5;
      block11boomhard=5;

      blockchar:array[0..maxblocktype,0..maxfx-1] of string=(('  ','  ','  ','  '),
                                                             ('□','□','□','□'),
                                                             ('▓','▓','▓','▓'),
                                                             ('≈','≈','≈','≈'),
                                                             ('★','★','★','★'),
                                                             ('▲','▲','▼','▼'),
                                                             ('〓','〓','〓','〓'),
                                                             ('■','■','■','■'),
                                                             ('т','т','т','т'),
                                                             ('※','※','※','※'),
                                                             ('┻','┣','┳','┫'),
                                                             ('∷','∷','∷','∷'),
                                                             ('□','□','□','□'),
                                                             ('□','□','□','□'),
                                                             ('◣','◤','◥','◢'),
                                                             ('━','┃','╲','╱'),
                                                             ('↑','→','↓','←'),
                                                             ('▔','▕','▁','▏'));{length=2}
//                                                          □ ▓ ≈ ★ ▲ 〓 ■ т ※ ┻ ∷ □ □◥ ┃ ↑ ▔
      blockbackground:array[0..maxblocktype] of longint=(0 ,5 ,7 ,1 ,4 ,2 ,5 ,5 ,6 ,2 ,7 ,0 ,7 ,7 ,7 ,7 ,7 ,7 );
      blockcolor     :array[0..maxblocktype] of longint=(15,15,0 ,9 ,15,15,15,15,15,8 ,15,8 ,0 ,11,8 ,8 ,0 ,4 );
      tankchar:array[0..maxtanktype-1,1..maxoccup,0..maxfx-1] of string=((('∧','＞','∨','＜'),
                                                                ('∧','＞','∨','＜'),
                                                                ('∧','＞','∨','＜'),
                                                                ('∧','＞','∨','＜'),
                                                                ('∧','＞','∨','＜')),

                                                               (('◇','◇','◇','◇'),
                                                                ('◎','◎','◎','◎'),
                                                                ('¤','¤','¤','¤'),
                                                                ('╋','╋','╋','╋'),
                                                                ('●','●','●','●')));
      tankcolor:array[0..maxtanktype-1] of longint=(4,2);
      tankspeed:array[0..maxtanktype-1,1..maxoccup] of longint=((10,10,10,10,10),(15,maxlongint,30,15,12)); {tick/格}
      tankmaxhp:array[0..maxtanktype-1,1..maxoccup] of longint=((10,10,10,10,10),(10,30,15,15,5));
      player2color=3;
      firespeed:array[0..maxtanktype-1,1..maxoccup,1..maxammotype] of longint=(((10,5,50),
                                                                             (10,5,50),
                                                                             (10,5,50),
                                                                             (10,5,50),
                                                                             (10,5,50)),
                                                                            ((25,maxlongint,maxlongint),
                                                                             (17,maxlongint,75),
                                                                             (25,200,150),
                                                                             (20,100,maxlongint),
                                                                             (maxlongint,maxlongint,maxlongint))); {tick}
      mobchar:array[1..maxmobtype,0..maxfx-1] of string=(('·','·','·','·'),
                                                   ('│','─','│','─'),
                                                   ('⊕','⊕','⊕','⊕'),
                                                   ('т','т','т','т'));
      mobcolor:array[1..maxmobtype] of longint=(-1,-1,-1,6);
      mobspeed:array[1..maxmobtype] of longint=(3,1,5,10); {tick/格}
      mobharm:array[1..maxmobtype] of longint=(1,1,1,0);
      mobmaxhp:array[1..maxmobtype] of longint=(1,30,1,1);

      minlengthofusernam=1;
      maxlengthofusernam=20;
      minlengthofpassword=6;
      maxlengthofpassword=30;
      maxfindfilesres=1000;
TYPE time_type=record
                 h,m,s,s100,od:word;
                 sum:longint;
                 tt:int64;
               end;
     zb_type=record
               x,y:longint;
             end;
     block_type=record
                  id:longint;
                  hard,maxhard:longint;
                  fx,fj:longint;
                  lrt:time_type;
                end;
     level_type=record
                nam,filenam:ansistring;
                map:array[1..maxy,1..maxx] of block_type;
                playerspawnpointnum:longint;
                aispawnpointnum:array[1..maxoccup] of longint;
                aiflagmaxhp,playerflagmaxhp:longint;
                aispawnpoint:array[1..maxoccup,1..maxspawnpoint] of zb_type;
                playerspawnpoint:array[1..maxspawnpoint] of zb_type;
                startspawntick:longint;
                startspawnainum,spawnprobability:array[1..maxoccup] of longint;
              end;

VAR i,n,j,k,t,mode,ct:longint;
    nx,ny:longint;
    nid:array[1..2] of longint;
    Tick:int64;
    mm:level_type;
    filename:ansistring;
    haif,hplf,isload:boolean;
    b,kp,setwithmouse,autoset,autodelete:boolean;
    path:ansistring;byt:byte;
    wjin,wjout:text;
    wj:file;


function random(x:longint):longint;
var i:longint;
    a:array[1..100] of longint;

   function rnd(n:longint):longint;
   begin
     exit(trunc(system.random*n));
   end;

begin
  for i:=1 to 100 do
    a[i]:=rnd(x);
  exit(a[rnd(100)+1]);
end;

procedure gt(var n:time_type);inline;
begin
  with n do
  begin
    getdate(h,m,od,s);
    gettime(h,m,s,s100);
    sum:=h*360000+m*6000+s*100+s100;
  end;
end;
function td(o,n:time_type):longint;
begin
  if o.od<>n.od then inc(n.sum,8640000);
  td:=n.sum-o.sum;
end;
procedure delay(n:longint);
var a,b,c,d,oldday,newday:word;
    i,t,now:longint;
begin
  n:=n div 10;
  gettime(a,b,c,d);
  t:=a*360000+b*6000+c*100+d;
  getdate(a,b,oldday,d);
  repeat
    if keypressed then readkey;
    getdate(a,b,newday,d);
    gettime(a,b,c,d);
    now:=a*360000+b*6000+c*100+d;
    if newday<>oldday then inc(now,8640000);
  until (now-t>=n);
end;
function strtoint(s:string):longint;
begin
  val(s,strtoint);
end;
function inttostr(n:longint):string;
begin
  str(n,inttostr);
end;
function max(a,b:longint):longint;
begin
  if a>b then exit(a)
   else exit(b);
end;
function min(a,b:longint):longint;
begin
  if a<b then exit(a)
   else exit(b);
end;
function color(now,max:longint):longint;
var i:longint;
begin
  if now<0 then exit(12);
  case trunc(now/max*100) of
    0..25:color:=12;
    26..50:color:=14;
    51..75:color:=11;
    76..100:color:=10;
  end;
end;

function inputint(s:ansistring;l,r,q:longint):longint;
var i,n:longint;
    st:string;
begin
  i:=0;
  repeat
    tc(7);
    inputint:=200;
    if i<>0 then clrscr;
    i:=1;
    writeln(s);
    cursoron;
    readln(st);
    tc(7);
    cursoroff;
    val(st,inputint,n);
    if q=2 then
    begin
      if st='-1' then exit(-1);
      if st='-2' then exit(-2);
    end;
    if q=1 then
      if st='-1' then exit(-1);
  until (n=0) and (inputint>=l) and (inputint<=r);
end;
function findblock(did,isrnd:longint):zb_type;//idrnd 1:random
var i,j,n:longint;
    a:array[0..maxblock] of zb_type;
begin
  n:=0;
  a[0].x:=-1;
  a[0].y:=-1;
  for i:=1 to maxx do
   for j:=1 to maxy do
    if mm.map[j,i].id=did then
    begin
      inc(n);
      a[n].x:=i;
      a[n].y:=j;
    end;
  if n=0 then exit(a[0]);
  if isrnd=0 then exit(a[1]);
  exit(a[random(n)+1]);
end;

procedure fillwindow(x,y,xl,yl,c:longint);
var i,j:longint;
begin
  windminx:=x;
  windmaxx:=x+xl-1;
  windminy:=y;
  windmaxy:=y+yl-1;
  tb(c);clrscr;
  windminx:=1;
  windmaxx:=80;
  windminy:=1;
  windmaxy:=25;
end;

procedure fileread(s:string);
var i,j:longint;
begin
  with mm do
  begin
    assign(wjin,s+'.leveldata');
    reset(wjin);
    readln(wjin,s);while s[1]<>'=' do delete(s,1,1);delete(s,1,1);nam:=s;
    for i:=1 to maxx do
    begin
      for j:=1 to maxy do
       with map[j,i] do
        begin
          read(wjin,id,hard,maxhard);
          if eoln(wjin)=false then read(wjin,fx,fj)
           else begin
             fx:=0;
             fj:=0;
           end;
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
readln(wjin);
    readln(wjin,startspawntick);
    for i:=1 to maxoccup do
      readln(wjin,startspawnainum[i]);
    for i:=1 to maxoccup do
      readln(wjin,spawnprobability[i]);
    close(wjin);
  end;//end with
end;

procedure filesave;
var i,j:longint;
    s:string;
begin
  tc(7);tb(0);
  if filename='' then
  repeat
    clrscr;
    writeln('请输入文件名');
    cursoron;
    readln(filename);
    cursoroff;
    if length(filename)=0 then continue;
    if fsearch(filename+'.leveldata','/')='' then break;
  until false;
  with mm do
  begin
    assign(wjout,filename+'.leveldata');
    rewrite(wjout);
    writeln(wjout,'Level Name=',nam);
    for i:=1 to maxx do
    begin
      for j:=1 to maxy do
       with map[j,i] do
        writeln(wjout,id,' ',hard,' ',maxhard,' ',fx,' ',fj);
    end;
writeln(wjout);
    writeln(wjout,playerflagmaxhp,' ',aiflagmaxhp);
    writeln(wjout,playerspawnpointnum);
    for i:=1 to playerspawnpointnum do
     with playerspawnpoint[i] do
      writeln(wjout,x,' ',y);

    for i:=1 to maxoccup do
      write(wjout,aispawnpointnum[i],' ');writeln(wjout);
    for i:=1 to maxoccup do
    begin
      for j:=1 to aispawnpointnum[i] do
       with aispawnpoint[i,j] do
        writeln(wjout,x,' ',y);
    end;
writeln(wjout);
    writeln(wjout,startspawntick);
    for i:=1 to maxoccup do
      writeln(wjout,startspawnainum[i]);
    for i:=1 to maxoccup do
      writeln(wjout,spawnprobability[i]);
    close(wjout);
  end;//end with
end;

function inmap(x,y:longint):boolean;
begin
  if (x<1) or (x>maxx) or (y<1) or (y>maxy) then exit(false);
  exit(true);
end;

procedure print(x,y,tbc,tcc:longint;st:string);
var i:longint;
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
  if tbc=-1 then tbc:=blockbackground[mm.map[y,x].id];
  gotoxy(x*2+1,y+1);
  tb(tbc);tc(tcc);
  write(st);
end;
procedure print(zb:zb_type;tbc,tcc:longint;st:string);
begin
  print(zb.x,zb.y,tbc,tcc,st);
end;

procedure print_block(x,y:longint);
begin
  with mm.map[y,x] do
    print(x,y,blockbackground[id],blockcolor[id],blockchar[id,fx]);
end;
procedure print_block(x:zb_type);
begin
  print_block(x.x,x.y);
end;

procedure print_map;
var i,j,t,n:longint;
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
    tb(bkbg);
    tc(bkcl);
    write('║');
    for j:=1 to maxx do
      print_block(j,i);
    tb(bkbg);
    tc(bkcl);
    writeln('║');
  end;
  write('╚');
  for i:=1 to maxx do write('═');
  write('╝');
  writeln;

      tc(12);tb(bkbg);
      gotoxy(nx*2+1,1);write('═');
      gotoxy(nx*2+1,maxy+2);write('═');
      gotoxy(1,ny+1);write('║');
      gotoxy(maxx*2+3,ny+1);write('║');

  gotoxy(30,1);
  tb(bkbg);tc(11);
  write(mm.nam);
end;

procedure print_logo;
var i,j,n,t:longint;
    s:array[1..200] of string;
    b,c:array[1..200] of longint;
begin
  n:=0;
  for i:=0 to maxblocktype do
   for j:=0 to maxfx-1 do
   begin
     inc(n);
     s[n]:=blockchar[i,j];
     b[n]:=blockbackground[i];
     c[n]:=blockcolor[i];
   end;
  for i:=0 to maxfx-1 do
  begin
    inc(n);
    s[n]:=tankchar[0,1,i];
    b[n]:=tankcolor[0];
    c[n]:=15;
    inc(n);
    s[n]:=tankchar[0,1,i];
    b[n]:=player2color;
    c[n]:=15;
  end;
  for i:=1 to  maxoccup do
   for j:=0 to maxfx-1 do
   begin
     inc(n);
     s[n]:=tankchar[1,i,j];
     b[n]:=tankcolor[1];
     c[n]:=15;
   end;

  for i:=1 to 4 do
   for j:=1 to 20 do
    if random(10)<>0 then
    begin
      gotoxy(j*2+19,i+2);
      t:=random(n)+1;
      tc(c[t]);
      tb(b[t]);
      write(s[t]);
    end;
end;

procedure init;
var i,n,t:longint;
    s:ansistring;
begin
  cursoroff;
  clrscr;
  randomize;
  nx:=1;ny:=1;mode:=1;
  haif:=false;hplf:=false;ct:=1;
  nid[1]:=1;nid[2]:=1;
  filename:='';
  tick:=0;
  with mm do
  begin
    nam:='';
    for i:=1 to maxx do
     for j:=1 to maxy do
      with map[j,i] do
      begin
        id:=0;
        hard:=0;
        maxhard:=0;
      end;//end with
    playerspawnpointnum:=0;
    fillchar(aispawnpointnum,sizeof(aispawnpointnum),0);
    aiflagmaxhp:=0;
    playerflagmaxhp:=0;
    for i:=1 to maxoccup do
     for j:=1 to maxspawnpoint do
      with aispawnpoint[i,j] do
      begin
        x:=-1;y:=-1;
      end;
    for i:=1 to maxspawnpoint do
     with playerspawnpoint[i] do
     begin
       x:=0;y:=0;
     end;
    startspawntick:=0;
    fillchar(startspawnainum,sizeof(startspawnainum),0);
    fillchar(spawnprobability,sizeof(spawnprobability),0);
  end;//end with
  filename:='';
  gotoxy(80-length('程序版本:'+version)+1,24);tc(7);tb(0);write('程序版本:',version);
  gotoxy(65,25);tc(8);tb(0);write('By ');tc(15);tb(0);write('Fallen_Breath');
  print_logo;
end;

procedure viewreadme;
begin
  exec('notepad',path+'\readme.txt');
end;

procedure load;
var i,n,t:longint;
    s:ansistring;
begin
  if paramcount<>0 then s:=paramstr(1);
  if (paramcount=0) or (copy(s,length(s)-9,10)<>'.leveldata') then
  begin
    repeat
      gotoxy(33,9);tb(0);
      n:=chooseone('读取地图'+ln+
                   '新建地图'+ln+
                   '帮助');
      isload:=false;
      if n=2 then exit;
      if n=3 then
      begin
        viewreadme;
        continue;
      end;
      break;
    until false;
    tc(7);tb(0);
    repeat
      clrscr;
      writeln('请输入文件名');
      cursoron;
      readln(s);
      cursoroff;
    until fsearch(s+'.leveldata','/')<>'';
    filename:=s;
    clrscr;
  end
   else begin
     s:=copy(paramstr(1),1,length(paramstr(1))-10);
     filename:=s;
   end;
  isload:=true;
  write('读取中。。。');
  fileread(s);
end;

   procedure setblock;
   begin
     with mm.map[ny,nx] do
     begin
       if (nid[1]=4) and hplf then exit;
       if (nid[1]=5) and haif then exit;
       if (nid[1]=id) and (autoset=false) then
       begin
         fx:=(fx+1) mod 4;
       end;
       id:=nid[1];
       maxhard:=blockmaxhard[id];
       case nid[1] of
         4:maxhard:=mm.playerflagmaxhp;
         5:maxhard:=mm.aiflagmaxhp;
       end;
       hard:=maxhard;
     end;//end with
   end;

   procedure deleteblock;
   begin
     with mm.map[ny,nx] do
     begin
       id:=0;
       if id=4 then hplf:=false;
       if id=5 then haif:=false;
       maxhard:=blockmaxhard[id];
       hard:=maxhard;
       fx:=0;
       fj:=0;
     end;
   end;

   procedure deletesp;
   var i,j:longint;
   begin
     with mm do
     begin
       n:=0;
       for i:=1 to maxspawnpoint do
        with playerspawnpoint[i] do
         if (x=nx) and (y=ny) then
         begin
           inc(n);
           for j:=i to maxspawnpoint-1 do
            playerspawnpoint[j]:=playerspawnpoint[j+1];
         end;
       dec(playerspawnpointnum,n);

       for j:=1 to maxoccup do
       begin
         n:=0;
         for i:=1 to aispawnpointnum[j] do
          with aispawnpoint[j,i] do
           if (x=nx) and (y=ny) then
           begin
             inc(n);
             for k:=i to maxspawnpoint-1 do
               aispawnpoint[j,k]:=aispawnpoint[j,k+1];
           end;
         dec(aispawnpointnum[j],n);
       end;//end for
     end;
   end;

   procedure setsp(m:longint);
   var i,j:longint;
   begin
     with mm do
     begin
       repeat
         if m=1 then break;
         for i:=1 to playerspawnpointnum do
          with playerspawnpoint[i] do
           if (x=nx) and (y=ny) then
             exit;
         for j:=1 to maxoccup do
          for i:=1 to aispawnpointnum[j] do
           with aispawnpoint[j,i] do
            if (x=nx) and (y=ny) then
              exit;
       until true;
       case nid[2] of
         1:begin
             inc(playerspawnpointnum);
             playerspawnpoint[playerspawnpointnum].x:=nx;
             playerspawnpoint[playerspawnpointnum].y:=ny;
           end;
         2..maxoccup+1:begin
                         t:=nid[2]-1;
                         inc(aispawnpointnum[t]);
                         aispawnpoint[t,aispawnpointnum[t]].x:=nx;
                         aispawnpoint[t,aispawnpointnum[t]].y:=ny;
                       end;
                    end;//end case
     end;
   end;

   procedure print_choose;
   var i,j,n,t,x,y:longint;
   begin
     tb(0);
     gotoxy(1,maxy+3);clreol;
     gotoxy(1,maxy+4);clreol;
     if ct=1 then
     begin
       for i:=1 to maxblocktype do
       begin
         gotoxy(7+(i-1)*4,maxy+3);
         tb(blockbackground[i]);tc(blockcolor[i]);
         write(blockchar[i,0]);

         gotoxy(7+(i-1)*4,maxy+4);
         tb(0);tc(15);
         if nid[1]=i then write('↑')
          else write('  ');
       end;
       exit;
     end;//end if ct=1

     for i:=1 to maxoccup+1 do
     begin
       gotoxy(7+(i-1)*5,maxy+3);
       if i>=11 then gotoxy(wherex+(i-11+1),wherey);
       tb(0);tc(15);write(i);
       tc(8);if i=1 then write(tankchar[0,1,0]) else write(tankchar[1,i-1,0]);

       gotoxy(8+(i-1)*5,maxy+4);
       tb(0);tc(15);
       if nid[2]=i then write('↑')
        else write('  ');
     end;//end for
   end;


      procedure ip(x,y:longint;var s:string;l,dq:longint);//dq:0左对齐 1:右对齐 2:居中
      var i,j,n:longint;
          ws:string;
          ch:char;
          ot,nt:time_type;
      begin
        if s='0' then s:='';
        repeat
          case dq of
            0:gotoxy(x,y);
            1:gotoxy(x-length(s)+1,y);
            2:gotoxy(x+length(s) div 2,y);
          end;//end case
          tb(7);tc(0);write(s);
          case dq of
            0:gotoxy(x+length(s)+1,y);
            1:gotoxy(x,y);
            2:gotoxy(x+(length(s) div 2),y);
          end;//end case
          gt(ot);
          repeat
            if keypressed then
            begin
              ch:=readkey;
              case ch of
                '0'..'9':if length(s)<l then s:=s+ch;
                chr(8):if length(s)>=1 then
                       begin
                         case dq of
                           0,2:gotoxy(x,y);
                           1:gotoxy(x-l+1,y);
                         end;//end case
                         tc(0);tb(7);for i:=1 to l do write(' ');
                         delete(s,length(s),1);
                       end;
                chr(13):begin
                          if length(s)=0 then s:='0';
                          exit;
                        end;
              end;
            end;//end if
            gt(nt);
          until td(ot,nt)>=ticklast div 10;
          cursoroff;
        until false;
      end;

   procedure setmore;
   const max=5;
   var i,j,n,t,x,y:longint;
       c:string;
       s:string;
       ch:char;
       ot,nt:time_type;
       kp,exi:boolean;
   begin
     with mm do
     begin
       x:=25;y:=4;
       fillwindow(x,y,32,16,7);
       t:=1;
       exi:=false;
       gotoxy(x+10,y);tc(1);tb(7);write('生成几率设置');
       for i:=1 to maxoccup do
       begin
         gotoxy(x+4,y+i);tc(15);tb(2);
         write(tankchar[1,i,0]);
         tc(0);tb(7);write(':  1/',spawnprobability[i]);
         gotoxy(x+18,y+i);write('每Tick');
       end;
       gotoxy(x+10,y+maxoccup+1);tc(1);tb(7);write('初始生成设置');
       for i:=maxoccup+2 to maxoccup*2+1 do
       begin
         gotoxy(x+4,y+i);tc(15);tb(2);
         write(tankchar[1,i-(maxoccup+1),0]);
         tc(0);tb(7);write(':');
         gotoxy(x+18-length(inttostr(startspawnainum[i-(maxoccup+1)])),y+i);write(startspawnainum[i-(maxoccup+1)],'个');
       end;
       gotoxy(x+4,y+12);tc(1);tb(7);write('生成开始于');tc(0);tb(7);gotoxy(x+23-length(inttostr(startspawntick)),y+12);write(startspawntick,'Tick');
       gotoxy(x+11,y+13);tc(1);tb(7);write('旗帜血量设置');
       for i:=y+14 to y+15 do
       begin
         gotoxy(x+4,i);tc(15);tb(blockbackground[i-y-10]);
         write(blockchar[i-y-10,0]);
         tc(0);tb(7);write(':');
         gotoxy(x+7,i);write('HP=');
         if i-y-10=4 then write(playerflagmaxhp) else write(aiflagmaxhp);
       end;
       gotoxy(x+1,y+t);tc(0);tb(7);write('→');gotoxy(x+29,y+t);tc(0);tb(7);write('←');
       repeat
         kp:=false;
         gt(ot);
         repeat
           if keypressed then
           begin
             c:=readkey;
             case c[1] of
               chr(27):begin
                         exi:=true;
                         break;
                       end;
               chr(13):begin
                         gotoxy(x+1,y+t);tc(8);tb(7);write('→');gotoxy(x+29,y+t);tc(8);tb(7);write('←');
                         gotoxy(x+20,wherey);
                         case t of
                           1..maxoccup:begin s:=inttostr(spawnprobability[t]); ip(x+11,y+t,s,7,0);end;
                           maxoccup+2..maxoccup*2+1:begin s:=inttostr(startspawnainum[t-(maxoccup+1)]);ip(x+17,y+t,s,7,1);end;
                           maxoccup*2+2:begin s:=inttostr(startspawntick);ip(x+22,y+t,s,9,1);end;
                           maxoccup*2+4:begin s:=inttostr(playerflagmaxhp);ip(x+10,y+t,s,3,0);end;
                           maxoccup*2+5:begin s:=inttostr(aiflagmaxhp);ip(x+10,y+t,s,3,0);end;
                         end;//end case
                         case t of
                           1..maxoccup:val(s,spawnprobability[t]);
                           maxoccup+2..maxoccup*2+1:val(s,startspawnainum[t-(maxoccup+1)]);
                           maxoccup*2+2:val(s,startspawntick);
                           maxoccup*2+4:val(s,playerflagmaxhp);
                           maxoccup*2+5:val(s,aiflagmaxhp);
                         end;//end case
                         if (t=maxoccup*2+4) and (findblock(4,0).x<>-1) then
                          with mm.map[findblock(4,0).y,findblock(4,0).x] do
                          begin
                            maxhard:=playerflagmaxhp;
                            hard:=maxhard;
                          end;
                         if (t=maxoccup*2+5) and (findblock(5,0).x<>-1) then
                          with mm.map[findblock(5,0).y,findblock(5,0).x] do
                          begin
                            maxhard:=aiflagmaxhp;
                            hard:=maxhard;
                          end;
                         gotoxy(x+1,y+t);tc(0);tb(7);write('→');gotoxy(x+29,y+t);tc(0);tb(7);write('←');
                       end;
               chr(0):if keypressed then
                      begin
                        c:=readkey;
                        case c[1] of
                          chr(80):begin
                                    if t<maxoccup*2+5 then inc(t)
                                     else t:=1;
                                    for i:=1 to 3 do
                                     if t in [maxoccup+1,maxoccup*2+3] then inc(t);
                                  end;
                          chr(72):begin
                                    if t>1 then dec(t)
                                     else t:=maxoccup*2+5;
                                    for i:=1 to 3 do
                                     if t in [maxoccup+1,maxoccup*2+3] then dec(t);
                                  end;
                        end;//end case
                        if c[1] in [chr(80),chr(72)] then
                        begin
                          for i:=0 to 15 do
                          begin
                            gotoxy(x+1,y+i);tc(0);tb(7);write('  ');
                            gotoxy(x+30,y+i);tc(0);tb(7);write('  ');
                          end;
                          gotoxy(x+1,y+t);tc(0);tb(7);write('→');gotoxy(x+29,y+t);tc(0);tb(7);write('←');
                        end;//end if
                      end; //end if
             end;//end case
           end;//end if
           gt(nt);
         until td(ot,nt)>=ticklast div 10;

       until exi;
       print_map;
       print_choose;
       if mode=2 then
       begin
         for i:=1 to playerspawnpointnum do
          with playerspawnpoint[i] do
            print(x,y,0,8,tankchar[0,1,0]);
         for j:=1 to maxoccup do
          for i:=1 to aispawnpointnum[j] do
           with aispawnpoint[j,i] do
             print(x,y,0,8,tankchar[1,j,0]);
       end;
     end;//end with
   end;

procedure work;
const gox:array[0..3] of longint=(0,1,0,-1);
      goy:array[0..3] of longint=(-1,0,1,0);
var i,j,k,n,t,de,xx,yy:longint;
    ot,nt:time_type;
    c:string;
begin
  if mm.nam='' then
  repeat
    clrscr;
    tc(7);tb(0);
    writeln('请输入关卡的标题');
    cursoron;
    readln(mm.nam);
    cursoroff;
    if length(mm.nam)=0 then continue;
    break;
  until false;
  clrscr;
  print_map;
  print_choose;
  setwithmouse:=false;
  autoset:=false;
  autodelete:=false;
  with mm do
  repeat
    inc(tick);
    kp:=false;
    gt(ot);
    de:=-1;
    hplf:=false;haif:=false;
    if findblock(4,0).x<>-1 then hplf:=true;
    if findblock(5,0).x<>-1 then haif:=true;
    repeat
      if keypressed then
      repeat
        c:=upcase(readkey);
        if c[1] in ['W','A','S','D',' ','X',chr(27),chr(8),chr(0),'0'..'9','O','-']=false then break;
        kp:=true;
        case c[1] of
          'W':de:=0;
          'A':de:=3;
          'S':de:=2;
          'D':de:=1;
          'X':setmore;
          'O':begin
                mode:=mode mod 3+1;
                case mode of
                  1:begin
                      for i:=1 to maxy do
                       for j:=1 to maxx do
                        with mm.map[i,j] do
                         if fj<>0 then print_block(j,i);
                    end;
                  2:begin
                      for i:=1 to playerspawnpointnum do
                       with playerspawnpoint[i] do
                         print(x,y,0,8,tankchar[0,1,0]);
                      for j:=1 to maxoccup do
                       for i:=1 to aispawnpointnum[j] do
                        with aispawnpoint[j,i] do
                          print(x,y,0,8,tankchar[1,j,0]);
                    end;
                  3:begin
                      for i:=1 to playerspawnpointnum do
                       with playerspawnpoint[i] do
                         print_block(x,y);
                      for j:=1 to maxoccup do
                       for i:=1 to aispawnpointnum[j] do
                        with aispawnpoint[j,i] do
                          print_block(x,y);
                      for i:=1 to maxy do
                       for j:=1 to maxx do
                        with mm.map[i,j] do
                         if fj<>0 then print(j,i,blockbackground[id],15,inttostr(fj));
                    end;
                end;//end case
              end;
          '0'..'9':begin
                     case ct of
                       1:val(c,map[ny,nx].fj);
                       2:if c[1] in ['1'..chr(ord('0')+maxoccup+1)] then
                         begin
                           val(c,nid[ct]);
                           print_choose;
                         end;
                     end;
                   end;
          ' ':with map[ny,nx] do
              case ct of
                1:repeat
                    setblock;
                  until true;
                2:repeat
                    setsp(1);
                  until true;
              end;//end case
          '-':with mm.map[ny,nx] do
              repeat
                if ct<>1 then break;
                fj:=-fj;
                if mode=3 then
                 if fj<>0 then
                  print(nx,ny,blockbackground[id],15,inttostr(fj));
              until true;
          chr(8):begin
                   case ct of
                     1:deleteblock;
                     2:begin
                         deletesp;
                       end;
                   end;//end case
                 end;
          chr(27):begin
                    exit;
                  end;
          chr(0):begin
                   if keypressed then
                   begin
                     c:=readkey;
                     case c[1] of
                       chr(80):begin
                                 if ct<2 then inc(ct)
                                  else ct:=1;
                               end;
                       chr(72):begin
                                 if ct>1 then dec(ct)
                                  else ct:=2;
                               end;
                       chr(77):begin
                                 case ct of
                                   1:begin
                                       if nid[1]<maxblocktype then inc(nid[1])
                                        else nid[1]:=1;
                                     end;
                                   2:begin
                                       if nid[2]<maxoccup+1 then inc(nid[2])
                                        else nid[2]:=1;
                                     end;
                                 end;//end case
                               end;
                       chr(75):begin
                                 case ct of
                                   1:begin
                                       if nid[1]>1 then dec(nid[1])
                                        else nid[1]:=maxblocktype;
                                     end;
                                   2:begin
                                       if nid[2]>1 then dec(nid[2])
                                        else nid[2]:=maxoccup+1;
                                     end;
                                 end;//end case
                               end;
                       chr(59):begin
                                 t:=0;
                                 if filename='' then t:=1;
                                 filesave;
                                 if t=1 then
                                 begin
                                   print_map;
                                   print_choose;
                                 end;
                               end;
                       chr(60):begin
                                 autoset:=not autoset;
                               end;
                       chr(61):begin
                                 autodelete:=not autodelete;
                               end;
                     end;
                     if c[1] in [chr(80),chr(72),chr(77),chr(75)] then print_choose;
                   end;//end if
                 end;
        end;
      until true;//end if
      gt(nt);
    until td(ot,nt)>=ticklast div 10;
   { if setwithmouse then
    begin
      nx:=getmousex;
      ny:=getmousey;
      nx:=nx div 2-2;
      ny:=ny-1;
    end;      }
    if autoset then
    case ct of
      1:setblock;
      2:setsp(0);
    end;
    if autodelete then
    case ct of
      1:deleteblock;
      2:deletesp;
    end;
    if de<>-1 then
    repeat
      xx:=nx+gox[de];
      yy:=ny+goy[de];
      if inmap(xx,yy)=false then break;
      tc(bkcl);tb(bkbg);
      gotoxy(nx*2+1,1);write('═');
      gotoxy(nx*2+1,maxy+2);write('═');
      gotoxy(1,ny+1);write('║');
      gotoxy(maxx*2+3,ny+1);write('║');
      print_block(nx,ny);
      if mode=2 then
      begin
        for i:=1 to playerspawnpointnum do
         with playerspawnpoint[i] do
          if (x=nx) and (y=ny) then
            print(x,y,0,8,tankchar[0,1,0]);
        for j:=1 to maxoccup do
         for i:=1 to aispawnpointnum[j] do
          with aispawnpoint[j,i] do
           if (x=nx) and (y=ny) then
             print(x,y,0,8,tankchar[1,j,0]);
      end;//end if
      if mode=3 then with mm.map[ny,nx] do if fj<>0 then
      begin
        print(nx,ny,blockbackground[id],15,inttostr(fj));
        if length(inttostr(fj))=1 then
        begin
          gotoxy(nx*2+2,ny+1);
          tc(7);tb(blockbackground[id]);write(' ');
        end;
      end; //end if
      nx:=xx;ny:=yy;

      tc(12);tb(bkbg);
      gotoxy(nx*2+1,1);write('═');
      gotoxy(nx*2+1,maxy+2);write('═');
      gotoxy(1,ny+1);write('║');
      gotoxy(maxx*2+3,ny+1);write('║');
    until true;
    if tick mod blinklast<=blinklast div 2 then
    begin
      gotoxy(nx*2+1,ny+1);
      tb(3);tc(7);
      write('  ');
    end
     else begin
       case mode of
         1:print_block(nx,ny);
         2:begin
             print_block(nx,ny);
             for i:=1 to playerspawnpointnum do
              with playerspawnpoint[i] do
               if (x=nx) and (y=ny) then
                 print(x,y,0,8,tankchar[0,1,0]);
             for j:=1 to maxoccup do
              for i:=1 to aispawnpointnum[j] do
               with aispawnpoint[j,i] do
                if (x=nx) and (y=ny) then
                  print(x,y,0,8,tankchar[1,j,0]);
           end;
         3:with mm.map[ny,nx] do
            if fj=0 then print_block(nx,ny)
             else begin
                    print(nx,ny,blockbackground[id],7,inttostr(fj));
                    if length(inttostr(fj))=1 then
                    begin
                      gotoxy(nx*2+2,ny+1);
                      tc(7);tb(blockbackground[id]);write(' ');
                    end; //end else
                  end;
       end;   //end case
     end; //end else
   //  write(nid[1],' ',nid[2]);
  until false;//end with
end;

BEGIN
 // initmouse;
  getdir(byt,path);
  init;
  load;
  work;
  filesave;
  //donemouse;
END.
