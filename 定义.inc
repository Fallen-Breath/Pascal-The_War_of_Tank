/////////////////////////External Program & File Information/////////////////////////

      SettingFileNam           = 'Tank_Setting.ini';
      FindFilesResultFileNam   = 'FindFilesResult.res';
      musicplayerprogramnam    = 'MusicPlayer.exe';

/////////////////////////Main Constant/////////////////////////

      maxx                     = 38;
      maxy                     = 21;
      maxfx                    = 4;
      maxlevel                 = 100;
      maxlujing                = 1000;
      maxtanktype              = 2;
      {玩家、敌人}
      maxai                    = 1000;
      maxplayer                = 2;
      maxmob                   = 1000;
      maxmobtype               = 4;
      {1子弹 2激光 3炸弹 4燃烧的TNT}
      maxspawnpoint            = 2000;

/////////////////////////Harm Constant/////////////////////////

      maxharmtype              = 3;
      {0强制伤害 1物理伤害 2能量伤害 3爆炸伤害}
      maxexplodehard              = 20;
        explodeharm:array[0..maxexplodehard] of longint=(0,1,2,4,6,9,13,17,23,32,45,61,83,113,147,188,233,294,371,465,589);

      TNTexplodehard              = 7;
      TNTgenerateharmlimit        = 25;
      mob3explodehard             = 3;
      aioccup5explodehard         = 5;
      playeroccup5explodehard     = 6;
      block11explodehard          = 5;

/////////////////////////Occup Constant/////////////////////////

      maxoccup                 = 5;
        occupnam:array[0..maxtanktype-1,0..maxoccup] of string =(('零号','猎手', '重甲' , '轰鸣' , '射手' , '波动'),
                                                                 ('????','猎人','防御者','破坏者','攻击者','自爆者'));
        occupprice:array[0..maxoccup] of longint=(0,4000,10000,50000,100000,30000);
        occupskilltime:array[0..maxoccup,1..3] of longint  = ((0,maxlongint,0),
                                                              (750,200,3),
                                                              (70,maxlongint,20),
                                                              (500,150,5),
                                                              (1000,200,3),
                                                              (0,maxlongint,35));
//                                                            冷却，时长，间隔
        playerskillfiretype:array[0..maxoccup] of longint      = (0,2,3,4,2,0);
        killaiprize:array[0..maxoccup] of longint= (2000,500,300,200,200,100);
      canbfsoccup                 = [3,4,5];
      playeroccup1skillwait       = 45;
      playeroccup1skillcatchdis   = 3;
      playeroccup2skillusedelay   = 15;


/////////////////////////Block Constant/////////////////////////

      maxblock                 = maxx*maxy;
      maxblocktype             = 17;
      {0:空气    1:石头  2:砍手岩  3:河流      4:我方旗帜    5:敌方旗帜    6:坚硬的石头  7:超级无敌硬的石头 8:TNT 9:丛林
      10:发射器 11:地雷 12:黑又硬 13:能量防御 14:单向反射器 15:双向反射器 16:单向穿透 17:单向破坏}
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

/////////////////////////Ammo Constant/////////////////////////

      maxammo                  = 999;
      maxammotype              = 3;
      {1子弹 2激光 3炸弹}
        ammonam  :array[1..maxammotype] of string   = ('子弹','激光','炸弹');
        ammoprice:array[1..maxammotype] of longint  = (0,50,120);

/////////////////////////Prop Constant/////////////////////////

      maxprop                  = 999;
      maxproptype              = 1;
      {1地雷}
        propnam  :array[1..maxproptype] of string   = ('地雷');
        propprice:array[1..maxproptype] of longint  = (  175);

/////////////////////////Game Constant/////////////////////////

      maxgamehard              = 3;
      maxgamemode              = 2;
      {0战争 1上帝 2极限}
      maxassess                = 9;
      {0简单 1普通 2困难 3地狱}
      spawnadd:array[0..maxgamehard] of double                        = (0.7,1.0,1.7,2.9);
      assesschar:array[1..maxassess] of string                        = ('SSS','SS','S','A','B','C','D','E','F');
      assesscolor:array[1..maxassess] of longint                      = ( 14  , 14 , 15, 12, 7 , 7 , 7 , 8 , 8 );
      mainlevelnum=10;
        levelwinprize:array[1..mainlevelnum] of longint=                (1000,1500,1500,2200,2000,2500,5000,5000,2500,3000);
//                                                                        SSS    SS    S     A     B     C     D     E       F
        levelbesttime:array[1..mainlevelnum,1..maxassess] of longint=  (( 600 , 800 , 1200, 2500, 4500, 7000,15000,30000,maxlongint),
                                                                        ( 900 , 1100, 1500, 2800, 5000,10000,20000,35000,maxlongint),
                                                                        ( 500 , 800 , 1200, 5500, 8500,14000,25000,40000,maxlongint),
                                                                        ( 1200, 1600, 3000, 4500, 5800, 7000,19000,30000,maxlongint),
                                                                        ( 650 , 825 , 1030, 2790, 4400, 7500,16700,36000,maxlongint),
                                                                        ( 1700, 2000, 2300, 3900, 6900,10000,20000,50000,maxlongint),
                                                                        ( 3000, 3500, 5000, 9000,15000,25000,40000,70000,maxlongint),
                                                                        ( 7000,10000,15000,17000,20000,25000,40000,70000,maxlongint),
                                                                        ( 1500, 1800, 2100, 5000, 9000,15000,30000,70000,maxlongint),
                                                                        ( 5200, 6300, 7000,10000,15000,25000,50000,99999,maxlongint));

/////////////////////////Tip Constant/////////////////////////

      maxtip                   = 10000;
      maxtiplength             = 40;

/////////////////////////Time Last Constant/////////////////////////
VAR
      ticklast        :longint = 20{ms};
Const
      unbreakblelast           = 120;
      unbreakbleblinklast      = 10;
      dyinglast                = 60;
      dyingblinklast           = 20;
      TNTexplodelast           = 80;
      TNTblinklast             = 21;
      block11explodewait       = 3;
      spawnwait                = 150;
      tipbreak                 = 7;
      killaitipshowlast        = 30;
      changeoccuptipshowlast   = 50;
      gamefinishtipshowlast    = 300;
      {单位:tick}
      block10firebreak:array[1..maxmobtype] of longint=(10,15,30,TNTexplodelast*7 div 8);

/////////////////////////Entity Constant/////////////////////////

      playermaxlives           = 30;
      tankspeed:array[0..maxtanktype-1,0..maxoccup] of longint=((10,10,35,18,13,8),(15 ,15,maxlongint,30,20,12)); {tick/格}
      tankmaxhp:array[0..maxtanktype-1,0..maxoccup] of longint=((10,10,30,15,15,5),(100,10,    30    ,15,15, 5));
      firespeed:array[0..maxtanktype-1,0..maxoccup,1..maxammotype] of longint=(((    10    ,    12    ,    25    ),
                                                                                (    8     ,    12    ,maxlongint),
                                                                                (    10    ,maxlongint,    20    ),
                                                                                (    12    ,    23    ,    23    ),
                                                                                (    15    ,    5     ,maxlongint),
                                                                                (maxlongint,maxlongint,maxlongint)),

                                                                               ((maxlongint,    66    ,    33    ),
                                                                                (    29    ,maxlongint,maxlongint),
                                                                                (    17    ,maxlongint,    70    ),
                                                                                (    47    ,    199   ,    53    ),
                                                                                (    31    ,    97   ,maxlongint),
                                                                                (maxlongint,maxlongint,maxlongint))); {tick}
      mobspeed:array[1..maxmobtype] of longint=(3 ,1 , 5,10);{tick/格}
      mobharm :array[1..maxmobtype] of longint=(1 ,2 , 1,0 );
      mobmaxhp:array[1..maxmobtype] of longint=(1 ,30, 1,1 );

/////////////////////////Graph Constant/////////////////////////

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
      blockcolor     :array[0..maxblocktype] of longint=(15,15,0 ,9 ,15,15,15,15,15,8 ,15,8 ,0 ,11,8 ,8 ,0 ,12);

      tankchar:array[0..maxtanktype-1,0..maxoccup,0..maxfx-1] of string=((('∧','＞','∨','＜'),
                                                                          ('∧','＞','∨','＜'),
                                                                          ('∧','＞','∨','＜'),
                                                                          ('∧','＞','∨','＜'),
                                                                          ('∧','＞','∨','＜'),
                                                                          ('∧','＞','∨','＜')),
                                                                                         
                                                                         (('卐','卐','卐','卐'),
                                                                          ('◇','◇','◇','◇'),
                                                                          ('◎','◎','◎','◎'),
                                                                          ('¤','¤','¤','¤'),
                                                                          ('╋','╋','╋','╋'),
                                                                          ('●','●','●','●')));
      tankcolor     :array[0..maxtanktype-1] of longint= (15,15);
      tankbackground:array[0..maxtanktype-1] of longint= ( 4, 2);
      player2color             = 3;

      mobchar:array[1..maxmobtype,0..maxfx-1] of string=(('·','·','·','·'),
                                                         ('│','─','│','─'),
                                                         ('⊕','⊕','⊕','⊕'),
                                                         ('т','т','т','т'));
      mobbackground:array[1..maxmobtype] of longint=(-1,-1,-1,6 );
      mobcolor     :array[1..maxmobtype] of longint=(15,11,8,15);

/////////////////////////Other Constant/////////////////////////

      gox:array[0..maxfx-1] of longint=(0 ,1 ,0 ,-1);
      goy:array[0..maxfx-1] of longint=(-1,0 ,1 ,0 );
      bkbg                     = 0;
      bkcl                     = 7;
      minlengthofusernam       = 1;
      maxlengthofusernam       = 20;
      minlengthofpassword      = 6;
      maxlengthofpassword      = 30;
      maxfindfilesres          = 100;
      maxqueue                 = 1000;
      maxcmdmem                = 10000;

TYPE Ttime=record
             time,tick:int64;
           end;
     Tpos=record
           x,y:longint;
         end;
     Tblock=record
              id:longint;
              fx,fj:longint;
              hard,maxhard:longint;
              lrt:Ttime;
              unbreakble:boolean;
            end;
     Tlj=record
           tot:longint;
           zb:array[1..maxlujing] of Tpos;
         end;
     Tflag=record
            id:longint;
            hp,maxhp:longint;
            zb:Tpos;
            lthp:longint;
          end;
     Ttip=record
            twn:longint;
            tipwaiting:array[1..maxtip] of record
                                             st:string;
                                             color:longint;
                                             starttime:Ttime;
                                             lastfor:longint;
                                           end;
            lasttipendtime:Ttime;
          end;
     Tlevel=record
              nam,filenam:string;
              ismainlevel:boolean;
              map:array[1..maxx,1..maxy] of Tblock;
              playerspawnpointnum:longint;
              aispawnpointnum:array[0..maxoccup] of longint;
              aiflagmaxhp,playerflagmaxhp:longint;
              aispawnpoint:array[0..maxoccup,1..maxspawnpoint] of Tpos;
              playerspawnpoint:array[1..maxspawnpoint] of Tpos;
              startspawntick:longint;
              startspawnainum,spawnprobability:array[0..maxoccup] of longint;
           end;
     Tprop=record
             num:longint;{0..999}
             nam:string;{len:0..4}
           end;
     Tmob=record
            nam                                              : string;
            id                                               : longint;
            living,unbreakble,rfx                            : boolean;
            speed,whos                                       : longint;
            hp,maxhp                                         : longint;
            xu                                               : longint;
            fx                                               : longint;
            zb                                               : Tpos;
            lmt{last move tick},
            ldt{last die tick},
            lst{last spawn tick}                             : Ttime;
          end;
     Ttank=record
             nam                                             : string;
             occup                                           : longint;
             id                                              : longint;
             living,unbreakble,skillusing                    : boolean;
             speed,whos                                      : longint;
             hp,maxhp,lives,maxlives                         : longint;
             xu,mubiao,ammotype,ljn                          : longint;
             fx                                              : longint;
             zb                                              : Tpos;
             lmt{last move tick},
             ldt{last die tick},
             lst{last spawn tick}                            : Ttime;
             skill:record
                     start,stop,use:Ttime;
                   end;
             lft{last fire tick}                             : array[1..maxammotype] of Ttime;
             lj                                              : Tlj;
           end;
     Tscreen=record
               ch:string;
               col,bg:longint;
             end;
     Tsetting=record
                gamehard:longint;
                gamemode:longint;
                playernum:longint;
                musicon:longint;
                smaxx,smaxy:longint;
              end;
     Tsave=record
             filenam:string;
             usernam,password:string;
             money:longint;
             ammo:array[1..maxammotype] of longint;
             prop:array[1..maxproptype] of longint;
             levelunlock,levelfinish:array[1..mainlevelnum] of boolean;
             occupown:array[0..maxoccup] of boolean;
           end;
     findfilesres=record
                    filenum,maxlen:longint;
                    filenam:array[1..maxfindfilesres] of string;
                  end;

VAR nowlevel,maxlevelnamlen                  : longint;
    ltl{last tick lives},lthp{last tick hp}  : array[1..maxplayer] of longint;
    gof,firef,lamt                           : array[1..maxplayer] of longint;
    ltprop{last tick prop}                   : array[1..maxplayer,1..maxproptype] of longint;
    oammo                                    : array[1..maxplayer,1..maxammotype] of longint;
    Tick                                     : int64;

    bfscnt                                   : longint;
    mm                                       : Tlevel;
    ai                                       : array[1..maxai] of Ttank;
    player                                   : array[1..maxplayer] of Ttank;
    noai                                     : Ttank;
    mob                                      : array[1..maxmob] of Tmob;
    aiflag,playerflag                        : Tflag;

    killnum                                  : array[0..maxplayer,0..maxoccup] of longint;
    dietimes                                 : array[0..maxplayer] of longint;
    score,assess                             : longint;
    gameendtick                              : int64;

    level                                    : array[1..maxlevel] of Tlevel;
    levelnum,cmdmemcnt,musicaliascnt         : longint;
    oldsc,newsc                              : array[1..maxx,1..maxy] of Tscreen;
    hitbox                                   : array[1..maxx,1..maxy] of longint;
    cmdmem                                   : array[1..maxcmdmem+1] of string;
    gamewin,gamelose,gaming                  : boolean;

    gotowhere                                : array[1..maxblock] of Tpos;
    cannotgo                                 : array[0..maxoccup,1..maxx,1..maxy] of boolean;

    setting                                  : Tsetting;
    profile                                  : Tsave;
    tip                                      : Ttip;
    logged,ismainlevel,bosstime,cmdused      : boolean;
    musicthreadok,explodemusicplayed         : boolean;
    path,choosestr                           : ansistring;
    byt                                      : byte;
    f_usedtime                               : text;

    fpsb,fpsn                                : Ttime;
    tid                                      : dword;
    musicparameter                           : string;


procedure print(x,y,tbc,tcc:longint;st:string);                             forward;
procedure print(zb:Tpos;tbc,tcc:longint;st:string);                         forward;
procedure print_mob(who:Tmob);                                              forward;
procedure print_mob(n:longint);                                             forward;
procedure print_tank(who:Ttank);                                            forward;
procedure print_tank(n:longint);                                            forward;
procedure print_block(x,y:longint);                                         forward;
procedure print_block(x:Tpos);                                              forward;
procedure print_auto(x,y:longint);                                          forward;
procedure print_auto(zb:Tpos);                                              forward;
procedure print_game_info;                                                  forward;
procedure print_program_info;                                               forward;
procedure checkdie(var who:Ttank);                                          forward;
procedure checkdie;                                                         forward;
procedure hurt_mob(var who:Tmob;fromx,fromy,harm,ht,fromwho:longint);       forward;
procedure hurt_mob(n,fromx,fromy,harm,ht,fromwho:longint);                  forward;
procedure hurt_tank(var who:Ttank;harm,ht,fromwho:longint);                 forward;
procedure hurt_tank(n,harm,ht,fromwho:longint);                             forward;
procedure explode(mx,my,hard,fromwho,hurtfrom:longint);                     forward;
procedure explode(m:Tpos;hard,fromwho,hurtfrom:longint);                    forward;
procedure init_tip(s:string;c,lf:longint);                                  forward;

function can(x,y,typ:longint):boolean;                                      forward;
function can(zb:Tpos;typ:longint):boolean;                                  forward;
function getmobharmtype(id:longint):longint;                                forward;
function getmobharmtype(who:Ttank):longint;                                 forward;
function ju(x1,y1,x2,y2:longint):longint;                                   forward;
function ju(a,b:Tpos):longint;                                              forward;
function ju(a:Tpos;x,y:longint):longint;                                    forward;
function ju(x,y:longint;a:Tpos):longint;                                    forward;
function getfx(x1,y1,x2,y2:longint):longint;                                forward;
function getfx(x1,x2:Tpos):longint;                                         forward;
function getfx(x1:Tpos;x2,y2:longint):longint;                              forward;
function getfx(x1,y1:longint;x2:Tpos):longint;                              forward;
function new_mob(dx,dy,dfx,d_id,dwhos:longint):longint;                     forward;
function new_ai(d_id,docc:longint):longint;                                 forward;
function whichmob(x,y:longint):longint;                                     forward;{exit -1:no}
function whichmob(zb:Tpos):longint;                                         forward;{exit -1:no}
function whichtank(x,y:longint):longint;                                    forward;{exit -0:no}
function whichtank(zb:Tpos):longint;                                        forward;{exit -0:no}
function inmap(x,y:longint):boolean;                                        forward;
function inmap(zb:Tpos):boolean;                                            forward;

