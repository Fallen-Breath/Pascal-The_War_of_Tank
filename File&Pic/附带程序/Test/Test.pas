uses crt,dos,betterinput,sysutils,math;
{$M 10000000,0,maxlongint}
{$inline on}
var i,j,k,n,t:longint;

   procedure print_assess(x,y,cl:longint;s:string);
   const maxc=2;
         maxa=255;
         wait=200;
         c:array[1..maxc] of longint=(8,7);
   var i,n,j,max:longint;
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
  clrscr;
  randomize;
  cursoroff;
  print_assess(2,2,13,'ABC');
  readkey;
end.
