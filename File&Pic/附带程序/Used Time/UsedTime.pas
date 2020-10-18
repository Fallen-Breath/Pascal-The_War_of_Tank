uses crt,betterinput;
type arr=array[1..1000000] of longint;
const max=12;
      filename='UsedTime.log';
      s:array[1..max] of string=('Before Work'    ,'Before Tick Wait' ,'Print Screen'    ,
                                 'Work Tip'       ,'Work Block'       ,'Work OccupSkill' ,'Work Mob','Work AI',
                                 'Print Game Info','Wait For Keypress','After Tick Wait' ,'Tick Cost ');
var A:array[1..max] of arr;
    i,n:longint;
    Ave:array[1..max] of int64;
    f:text;
    c:char;
procedure sort(var aa:arr;l,r:longint);
var x,y,i,j:longint;
begin
  i:=l;
  j:=r;
  x:=aa[(l+r)div 2];
  repeat
    while aa[i]<x do inc(i);
    while aa[j]>x do dec(j);
    if i<=j then
    begin
      y:=aa[i];
      aa[i]:=aa[j];
      aa[j]:=y;
      inc(i);
      dec(j);
    end;
  until i>j;
  if i<r then sort(aa,i,r);
  if l<j then sort(aa,l,j);
end;
begin
writeln(chr(108),chr(122),chr(115),chr(98));readkey;
  clrscr;
  cursoroff;write('Loading...');
  GOTOXY(windmaxx-length('By Fallen_Breath')+1,windmaxy);tc(8);write('By ');tc(15);write('Fallen_Breath');dec(windmaxy);
  assign(f,filename);
  reset(f);
  n:=0;
  fillchar(ave,sizeof(ave),0);
  repeat
    i:=0;
    repeat
      read(f,c);
      inc(i);
    until (c=' ') or (i=100);
    if i=100 then break;
    inc(n);
    //gotoxy(1,1);write(n);
    for i:=1 to max do
    begin
      read(f,a[i,n]);
      a[i,n]:=a[i,n]*10;
      inc(ave[i],a[i,n]);
    end;
    readln(f);
  until eof(f);
  dec(n);
  close(f);clrscr;
  for i:=1 to max do
   sort(a[i],1,n);

  writeln('Tick=',n);
  writeln('Exit in Tick ',n);
  tc(15);
  WRITELN('MAIN SET:20');
  tc(7);
  for i:=1 to max do
   if s[i]<>'' then
   begin
     gotoxy(1,wherey+1);
     write(s[i]);

     gotoxy(20,wherey);
     tc(15);write('Max ');
     tc(7);write(': ',a[i,n]);

     gotoxy(40,wherey);
     tc(15);write('Min ');tc(7);
     write(': ',a[i,1]);

     gotoxy(60,wherey);
     tc(15);write('Average ');tc(7);
     write(': ',ave[i]/n:0:5);
   end;
  readkey;
end.
