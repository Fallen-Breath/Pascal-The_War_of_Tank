{$InLine On}
{$Mode objfpc}
{$M 1000000000,0,Maxlongint}

Uses Leftist_Tree;

var heap:Theap;
    i,n:longint;
BEGIN
  heap:=Theap.create();
  writeln('size=',heap.size());
  n:=100000;
  for i:=1 to n do heap.push(random(1000000000));
  for i:=1 to n do
  begin
    writeln(heap.top());
    heap.pop();
  end;
  readln;
End.
