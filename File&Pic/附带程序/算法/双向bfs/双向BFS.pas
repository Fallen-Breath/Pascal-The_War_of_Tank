{$M 10000000,0,maxlongint}
{$inline on}

uses crt,dos,betterinput;

const
      maxx=38;
      maxy=21;
      maxfx=4;
      maxlevel=100;
      maxlujing=1000;
      maxtanktype=2;{Íæ¼Ò¡¢µÐÈË}
      maxai=1000;
      maxplayer=2;
      maxmob=1000;
      maxmobtype=4;{1×Óµ¯ 2¼¤¹â 3Õ¨µ¯ 4È¼ÉÕµÄTNT}
      maxspawnpoint=2000;
      maxqueue=10000;

      gox:array[0..3] of longint=(0,1,0,-1);
      goy:array[0..3] of longint=(-1,0,1,0);

TYPE time_type=record
                 h,m,s,s100,oldday:word;
                 sum:longint;
                 tt:int64;
               end;
     zb_type=record
               x,y:longint;
             end;
     block_type=record
                  id:longint;
                  fx,fj:longint;
                  hard,maxhard:longint;
                  harmtype:longint;
                  lrt:time_type;
                  unbreakble:boolean;
                end;
     lj_type=record
               tot:longint;
               zb:array[1..maxlujing] of zb_type;
             end;
   dl=record
             x,y,pre:longint;
           end;

var map:array[1..maxx,1..maxy] of longint;
    gotowhere:array[1..1000] of zb_type;
       q:array[1..2,1..maxqueue] of dl;
    head,tail:array[1..2] of longint;
       went:array[1..maxx,1..maxy] of longint;
    lj:lj_type;
    i,j,gwn:longint;
    b:boolean;

   procedure fileread;
   var i,j:longint;
       wjin:text;
   begin

       assign(wjin,'bfs.leveldata');
       reset(wjin);
       readln(wjin);
       for i:=1 to maxx do
         for j:=1 to maxy do
         begin
           readln(wjin,map[i,j]) ;
           if map[i,j]=3 then
           begin
             inc(gwn);
             gotowhere[gwn].x:=i;
             gotowhere[gwn].y:=j;
           end;
         end;
       close(wjin);
   end;


procedure print;
var i,j:longint;
begin
  textbackground(1);clrscr;
  for i:=1 to maxy do
   for j:=1 to maxx do
   begin
     case map[j,i] of
       0:textbackground(0);
       1:textbackground(7);
       2:textbackground(3);
       3:textbackground(6);
       4:textbackground(5);
     end;
  //   gotoxy(j*2+1,i+1);
   //  write('  ');
  windminx:=j*2+1;windmaxx:=j*2+2;
  windminy:=i+1;windmaxy:=i+1;
  clrscr;
   end;
  windminx:=1;windmaxx:=80;
  windminy:=1;windmaxy:=25;
end;

function inmap(x,y:longint):boolean;
begin
  if (x<1) or (x>maxx) or (y<1) or (y>maxy) then exit(false);
  exit(true);
end;

function can(n,x,y:longint):boolean;
var i:longint;
begin
  if inmap(x,y)=false then exit(false);
  if map[x,y]=1 then exit(false);
  if n=1 then
   if went[x,y]>0 then exit(false);
  if n=2 then
   if went[x,y]<0 then exit(false);
  exit(true);
end;
function can(n:longint;zb:zb_type):boolean;
begin
  exit(can(n,zb.x,zb.y));
end;

   function bfs(x,y,ain:longint):boolean;
   var i,n:longint;

      procedure print(n,d:longint);
      begin
        if n=1 then
         if q[n,d].pre<>0 then print(n,q[n,d].pre);
        map[q[n,d].x,q[n,d].y]:=2;
        if n=2 then
         if q[n,d].pre<>0 then print(n,q[n,d].pre);
      end;

      function kz(n:longint;var head,tail:longint):longint;
      var i,j,ii,t,xx,yy:longint;
          b:array[0..3] of boolean;
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
         if can(n,xx,yy) then
         begin
           inc(tail);
           q[n,tail].x:=xx;q[n,tail].y:=yy;q[n,tail].pre:=head;
           t:=went[xx,yy];
           if ((n=1) and (t<0)) or ((n=2) and (t>0)) then
           begin
             print(n mod 2+1,abs(t));
             print(n,tail);
             lj.tot:=t;
             exit(1);
           end;
           if n=1 then went[xx,yy]:=tail;
           if n=2 then went[xx,yy]:=-tail;
         end;//end if can
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
          if (tail[1]=head[1]) or (tail[2]=head[2]) then exit(false);
          if tail[1]<tail[2] then n:=kz(1,head[1],tail[1])
           else                   n:=kz(2,head[2],tail[2]);
          if n=1 then break;
        end; //end while
        exit(true);
   end;//end bfs

begin
  cursoroff;randomize;
  textbackground(1);clrscr;
  fillchar(map,sizeof(map),0);
  fillchar(gotowhere,sizeof(gotowhere),0);
  fileread;
  print;

  for i:=1 to maxx do for j:=1 to maxy do if map[i,j]=4 then
  begin
    b:=bfs(i,j,0);
    break;
  end;
  print;
  if b=false then
  begin
    gotoxy(1,1);
    tc(15);tb(0);
    write('no way');
  end;
  readkey;
end.
