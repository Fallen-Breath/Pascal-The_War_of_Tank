Unit Leftist_Tree;

{$InLine On}                       
{$Mode objfpc}
{$M 1000000000,0,Maxlongint}

Interface

Uses Math;

Const maxsize=100000;

Type Theap=class         
  public
    tr:array[0..maxsize] of record
      lc,rc,val,key,dis:longint;
    end;
    rt,tot:longint;
    procedure newnode(k,x,y:longint);
    function merge(x,y:longint):longint;
    
    procedure clear();
    procedure init();
    procedure push(x,y:longint); 
    procedure push(x:longint);
    procedure pop();
    function top():longint;
    function size():longint;
    function empty():boolean;
end;

Implementation

procedure swap(var x,y:longint);
var z:longint;
begin
  z:=x; x:=y; y:=z;
end;

procedure Theap.newnode(k,x,y:longint);
begin
  tr[k].lc:=0;
  tr[k].rc:=0;
  tr[k].val:=x;
  tr[k].key:=y;
  tr[k].dis:=0;
end;
function Theap.merge(x,y:longint):longint;
begin
  if (x=0) or (y=0) then exit(x+y);
  if (tr[x].key>tr[y].key) then swap(x,y);
  tr[x].rc:=merge(tr[x].rc,y);
  if (tr[tr[x].lc].dis<tr[tr[x].rc].dis) then swap(tr[x].lc,tr[x].rc);
  tr[x].dis:=tr[tr[x].rc].dis+1;
  exit(x);
end;
procedure Theap.clear();
begin
  tot:=0; rt:=0;
end;
procedure Theap.init();
begin
  clear();
  newnode(0,-maxlongint-1,0);
end; 
procedure Theap.push(x,y:longint);
begin
  inc(tot);
  newnode(tot,x,y);
  rt:=merge(rt,tot);
end;
procedure Theap.push(x:longint);
begin
  push(x,x);
end;
procedure Theap.pop();
begin
  rt:=merge(tr[rt].lc,tr[rt].rc);
end;            
function Theap.top():longint;
begin
  exit(tr[rt].key);
end;
function Theap.size():longint;
begin
  exit(tot);
end;
function Theap.empty():boolean;
begin
  exit(tot>0);
end;

BEGIN
End.