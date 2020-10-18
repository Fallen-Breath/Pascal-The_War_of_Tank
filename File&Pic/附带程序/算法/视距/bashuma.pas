const
  fac:array[0..8]of longint=(1,1,2,6,24,120,720,5040,40320);
  dire:array[1..4,1..2]of longint=((-1,0),(0,-1),(0,1),(1,0));
type
  arr=array[1..3,1..3]of longint;
  node=record
        now:arr;
        HashValue,zero_x,zero_y:longint;
  end;
  queue=record
        data:array[1..20000]of node;
        front,rear:longint;
  end;

var
  start,goal:node;
  q:array[0..1]of queue;
  flag:array[0..1,0..362879]of boolean;
  step:array[0..1,0..362879]of longint;
  IsGoal:boolean;

procedure hash(var a:node);
var
  i,j,k,value:longint;
  table:array[1..9]of longint;
begin
  for i:=1 to 3 do
    for j:=1 to 3 do
      table[(i-1)*3+j]:=a.now[i][j];
  value:=0;
  for i:=1 to 8 do
    begin
      k:=0;
      for j:=i+1 to 9 do
        if table[j]<table[i] then inc(k);
      inc(value,k*fac[9-i]);
    end;
  a.HashValue:=value;
end;

procedure swap(var x,y:longint);
var tmp:longint;
begin
  tmp:=x;x:=y;y:=tmp;
end;


function can:boolean;
var
  i,j,s,g:longint;
  ss,gg:array[1..9]of longint;
begin
  for i:=1 to 3 do
    for j:=1 to 3 do
      ss[(i-1)*3+j]:=start.now[i][j];
  s:=0;
  for i:=1 to 8 do
    for j:=i+1 to 9 do
      if (ss[j]<>0)and(ss[i]>ss[j]) then inc(s);
  for i:=1 to 3 do
    for j:=1 to 3 do
      gg[(i-1)*3+j]:=goal.now[i][j];
  g:=0;
  for i:=1 to 8 do
    for j:=i+1 to 9 do
      if (gg[j]<>0)and(gg[i]>gg[j]) then inc(g);
  can:=odd(s)=odd(g);
end;

procedure init;
var
  i,j:longint;
  ch:char;
begin
  IsGoal:=false;
  fillchar(q,sizeof(q),0);
  fillchar(flag,sizeof(flag),true);
  fillchar(step,sizeof(step),0);
  for i:=1 to 3 do
    for j:=1 to 3 do
      begin
        read(ch);
        with start do
          begin
            now[i][j]:=ord(ch)-48;
            if ch='0' then
              begin
                zero_x:=i;
                zero_y:=j;
              end;
          end;
      end;
  readln;
  hash(start);
  flag[0][start.HashValue]:=false;
  for i:=1 to 3 do
    for j:=1 to 3 do
      begin
        read(ch);
        with goal do
          begin
            now[i][j]:=ord(ch)-48;
            if ch='0' then
              begin
                zero_x:=i;
                zero_y:=j;
              end;
          end;
      end;
  readln;
  hash(goal);
  flag[1][goal.HashValue]:=false;
  for i:=0 to 1 do
    with q[i] do
      begin
        front:=1;
        rear:=1;
        if i=0 then data[front]:=start else data[front]:=goal;
      end;
end;

function SearchGoal:longint;
var i,j,k,sum,ans:longint;
begin
  ans:=maxlongint;
  for i:=0 to 1 do
    with q[i] do
      for j:=1 to rear do
        begin
          if not(flag[1-i][data[j].HashValue]) then
            begin
              sum:=0;
              for k:=0 to 1 do
                inc(sum,step[k][data[j].HashValue]);
              if sum<ans then ans:=sum;
            end;
        end;
  exit(ans);
end;

procedure expand(num:longint);
var
  i,line,column:longint;
  tmp:node;
begin
  for i:=1 to 4 do
    begin
      with q[num] do
        begin
          line:=data[front].zero_x+dire[i][1];
          column:=data[front].zero_y+dire[i][2];
          if (line<1)or(line>3)or(column<1)or(column>3) then continue;
          tmp:=data[front];
          with tmp do
            begin
              swap(now[line][column],now[zero_x][zero_y]);
              zero_x:=line;
              zero_y:=column;
            end;
          hash(tmp);
          if flag[num][tmp.HashValue] then
            begin
              inc(rear);
              data[rear]:=tmp;
              step[num][tmp.HashValue]:=step[num][data[front].HashValue]+1;
              flag[num][tmp.HashValue]:=false;
              if not(flag[1-num][tmp.HashValue]) then IsGoal:=true;
            end;
        end;
    end;
  inc(q[num].front);
  if IsGoal then
    writeln(SearchGoal);
end;

begin
  while not eof do
    begin
      init;
      if not(can) then
        begin
          writeln(-1);
          continue;
        end;
      repeat
        if q[0].rear<q[1].rear then expand(0) else expand(1);
      until IsGoal;
    end;
end.
