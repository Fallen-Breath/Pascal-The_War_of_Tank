uses crt,dos;
type jxs=record
           k,b:double;
         end;
const maxx=30;
      maxy=15;
var map:array[1..maxx,1..maxy] of longint;
    x1,x2,y1,y2,cx,cy,i,j,a,b:longint;
procedure print_map;
var i,j:longint;
begin
  gotoxy(1,1);
  textbackground(0);
  for i:=1 to maxy do
  begin
    for j:=1 to maxx do
    begin
      case map[j,i] of
        0:textbackground(7);
        1:textbackground(2);
        2:textbackground(6);
      end;
      write('  ');
    end;
    writeln;
  end;
end;
function js(x1,y1,x2,y2:double):jxs;
var a,b:double;
begin
  //y1-y2=(x1-x2)k
  a:=(x1-x2);b:=(y1-y2);
  //a=bk;k=a/b
  js.k:=a/b;
  //y1=kx1+b
  //b=y1-kx1
  js.b:=y1-js.k*x1;

end;
begin
  cursoroff;
  x1:=2;y1:=3;
  x2:=20;y2:=12;
  print_map;
  cx:=abs(x1-x2);cy:=abs(y1-y2);
  for i:=x1 to x2 do
   for j:=y1 to y2 do
   begin
     a:=abs(x1-i);b:=abs(y1-j);
     if b=0 then continue;
     if a*cy=b*cx then map[i,j]:=2;
   end;
  map[x1,y1]:=1;map[x2,y2]:=1;
  print_map;
  readkey;
end.
