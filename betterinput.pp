(****************************************************************************************************************************
Better Input
2014.7.2
By Fallen_Breath

这是一个用来优化输入的单元
有我做的几个挺实用的过程&函数

2017.5.30坦克大战微调：微调ansistring参数的传递方式

==============================常量===============================

Ln                     : 回车符

==============================变量===============================

Maxchoose              : 最大选项           （默认200）
MaxLengthOfPassword    : 最大密码长度       （默认30）
NumberOfDarkChoose     : 非高亮选项的数量
DarkChoose             : 非高亮选项
Tcolor                 : 上一次Tc的颜色     （不建议更改）
Tbackground            : 上一次Tb的颜色     （不建议更改）

============================过程&函数============================

Tb                     : 设置背景颜色
Tc                     : 设置文字颜色
GotoXY_Mid             : 将光标移动到一个地方使输出的字符串居中
SetWindowSize          : 设置当前窗口区域大小
DrawWindow             : 填充一块区域
InputInt               : 读入一个整数
InputPassword          : 读入一个密码(用指定字符显示)
Chooseone              : 在选项中选择一项


详细参数：
Tb≌textcolor
Tc≌textbackground

////////////////////////////////////////////////////////////////////////

GotoXY_Mid(最小宽度,最大宽度,行数,居中的字符串);
             MinX     MaxX    Y    AnsiString
GotoXY_Mid(行数,居中的字符串);
GotoXY_Mid(居中的字符串);

////////////////////////////////////////////////////////////////////////

SetWindowSize(x1 , y1 , x2 , y2 ,)
               左上角    右下角

////////////////////////////////////////////////////////////////////////

DrawWindow(x1 , y1 , x2 , y2 , 填充的背景颜色)
            左上角    右下角       0..7
DrawWindow(x1,y1,x2,y2)

////////////////////////////////////////////////////////////////////////

InputInt(  要读入的整形  ,最大值,        对齐方案        );
         integer&longint         0:左对齐 1:居中 2:右对齐
InputInt(要读入的整形);

////////////////////////////////////////////////////////////////////////

InputPassword(读入的密码,替换符号);
                 string    char
InputPassword(读入的密码);

////////////////////////////////////////////////////////////////////////

Chooseone(进行选择的字符串,选择字符,选中的文字颜色,未选中的文字颜色,最大宽度,最大深度,        对齐方式        ):选中的行数
             AnsiString     string      0..15            0..15        MaxX     MaxY   0:左对齐 1:居中 2:右对齐
Chooseone(进行选择的字符串,选择字符,选中的文字颜色,未选中的文字颜色,        对齐方式        ):选中的行数 Longint
Chooseone(进行选择的字符串,选中的文字颜色,未选中的文字颜色,        对齐方式        ):选中的行数 Longint
Chooseone(进行选择的字符串,选择字符,        对齐方式        ):选中的行数 Longint
Chooseone(进行选择的字符串,对齐方式):选中的行数
Chooseone(进行选择的字符串):选中的行数
进行选择的字符串：选项用回车隔开(#13+#10)


请使用Free Pascal2.0.4编译
请在程序开头输入{$M 1000000000,0,Maxlongint}——增大栈空间（Chooseone的AnsiString）

****************************************************************************************************************************)


Unit betterinput;

{$InLine On}

Interface

Uses Crt,Dos,Math,Sysutils;

Const Ln=#13+#10;
      MaxChooseArr                                      = 1000;
      MaxDarkChoose                                     = 1000;

Var MaxChoose:1..MaxChooseArr                           = 200;
    NumberOfDarkChoose:0..MaxDarkChoose;
    DarkChoose:array[1..maxdarkchoose] of string;
    MaxLengthOfPassword:1..100                          = 30;
    Tcolor,Tbackground:longint;                              
    left,right:array[1..maxchoosearr] of longint;
    s,os:array[1..maxchoosearr] of string;


Procedure tc(c:longint);                                 inline;
Procedure tb(c:longint);                                 inline;


Procedure gotoxy_mid(len:longint;minx,maxx,y:longint);   inline;
Procedure gotoxy_mid(s:string;minx,maxx,y:longint);  inline;
Procedure gotoxy_mid(s:string;y:longint);            inline;
Procedure gotoxy_mid(s:string);                      inline;
Procedure gotoxy_mid(len:longint;y:longint);             inline;
Procedure gotoxy_mid(len:longint);                       inline;

Procedure setwindowsize(x1,y1,x2,y2:longint);

Procedure drawwindow(x1,y1,x2,y2:longint);
Procedure drawwindow(x1,y1,x2,y2,color:longint);

Procedure inputint(var num:longint;max,dq:longint);
Procedure inputint(var num:integer;max,dq:integer);
Procedure inputint(var num:longint);
Procedure inputint(var num:integer);

Procedure inputpassword(var s:string;ch:char);
Procedure inputpassword(var s:string);

Function chooseone(var writestring:ansistring;choosechar:string;choosecolor,notchoosecolor:longint;maxx,maxy,align:longint)  : longint;
Function chooseone(var writestring:ansistring;choosechar:string;choosecolor,notchoosecolor:longint;align:longint)                      : longint;
Function chooseone(var writestring:ansistring;choosecolor,notchoosecolor:longint;align:longint)                                        : longint;
Function chooseone(var writestring:ansistring;choosechar:string;align:longint)                                                         : longint;
Function chooseone(var writestring:ansistring;align:longint)                                                                           : longint;
Function chooseone(var writestring:ansistring)                                                                                         : longint;

Implementation

Procedure tc(c:longint);inline;
begin
  tcolor:=c;
  crt.textcolor(c);
end;
Procedure tb(c:longint);inline;
begin
  tbackground:=c;
  crt.textbackground(c);
end;

Procedure gotoxy_mid(len:longint;minx,maxx,y:longint);inline;
begin
  gotoxy(max(minx,(minx+maxx-len) div 2),y);
end;
Procedure gotoxy_mid(s:string;minx,maxx,y:longint);inline;
begin
  gotoxy_mid(length(s),minx,maxx,y);
end;
Procedure gotoxy_mid(s:string;y:longint);inline;
begin
  gotoxy_mid(s,windminx,windmaxx,y);
end;
Procedure gotoxy_mid(s:string);inline;
begin
  gotoxy_mid(s,windminx,windmaxx,wherey);
end;
Procedure gotoxy_mid(len:longint;y:longint);inline;
begin
  gotoxy_mid(len,windminx,windmaxx,y);
end;
Procedure gotoxy_mid(len:longint);inline;
begin
  gotoxy_mid(len,windminx,windmaxx,wherey);
end;

Procedure setwindowsize(x1,y1,x2,y2:longint);
begin
  crt.window(x1,y1,x2,y2);
end;

Procedure drawwindow(x1,y1,x2,y2:longint);
var a,b,c,d:longint;
begin
  a:=windminx;
  b:=windminy;
  c:=windmaxx;
  d:=windmaxy;
  setwindowsize(x1,y1,x2,y2);
  clrscr;
  setwindowsize(a,b,c,d);
end;
Procedure drawwindow(x1,y1,x2,y2,color:longint);
begin
  tb(color);
  drawwindow(x1,y1,x2,y2);
end;

Procedure inputint(var num:longint;max,dq:longint);
var i,j,n:longint;
    x,y:longint;
    ch:char;
    s:string;
   function smaller(s:string;max:longint):boolean;
   var ms:string;
   begin
     str(max,ms);
     if length(s)>length(ms) then exit(false);
     if length(s)<length(ms) then exit(true);
     exit(s<=ms);
   end;

   procedure enter;
   begin
     if length(s)=0 then s:='0';
     while (length(s)>1) and (s[1]='0') do delete(s,1,1);
     val(s,num);
   end;

begin
  num:=num;
  str(num,s);
  if s='0' then s:='';
  x:=wherex;y:=wherey;
  cursoron;
  repeat
    case dq of
      0:gotoxy(x,y);
      1:gotoxy(x-length(s)+1,y);
      2:gotoxy(x+length(s) div 2,y);
    end;//end case
    write(s); {
    case dq of
      0:gotoxy(x+length(s)+1,y);
      1:gotoxy(x,y);
      2:gotoxy(x+(length(s) div 2),y);
    end;//end case}
    ch:=readkey;
    case ch of
      '0':if (length(s)>0) and (s<>'0') then
          begin
            if smaller(s+ch,max) then s:=s+ch
             else s:=inttostr(max);
          end;
      '1'..'9':if smaller(s+ch,max) then s:=s+ch
                else s:=inttostr(max);
      chr(8):if length(s)>=1 then
             begin
               case dq of
                 0,2:gotoxy(x,y);
                 1:gotoxy(x-length(inttostr(max))+1,y);
                end;//end case
                for i:=1 to length(inttostr(max)) do write(' ');
                delete(s,length(s),1);
             end;
      chr(13):begin
                enter;
                break;
              end;
      #0:case readkey of
           #28:begin
                 enter;
                 break;
               end;
         end;
    end;
  until false;
  cursoroff;
  num:=num;
end;
Procedure inputint(var num:integer;max,dq:integer);
var n:longint;
begin
  n:=num;
  inputint(n,max,dq);
  num:=n;
end;
Procedure inputint(var num:longint);
begin
  inputint(num,maxlongint,0)
end;
Procedure inputint(var num:integer);
begin
  inputint(num,maxint,0)
end;

Procedure inputpassword(var s:string;ch:char);
var c:char;
begin
  s:='';
  cursoron;
  repeat
    c:=readkey;
    if c in [#0,#8,#13,#32..#126]=false then continue;
    if (c=#13) or ((c=#0) and (readkey=#28)) then break;
    if c=#8 then
    begin
      if s='' then continue;
      gotoxy(wherex-1,wherey);
      write(' ');
      gotoxy(wherex-1,wherey);
      delete(s,length(s),1);
      continue;
    end;
    if length(s)=maxlengthofpassword then continue;
    s:=s+c;
    write(ch);
  until false;
  writeln;
  cursoroff;
end;
Procedure inputpassword(var s:string);
begin
  inputpassword(s,'*');
end;


Function chooseone(var writestring:ansistring;choosechar:string;choosecolor,notchoosecolor:longint;maxx,maxy,align:longint):longint;
var t,i,j,n,maxlen,max,charlen:longint;
    x1,y1,l,r:longint;
    oldn,oldl,oldr:longint;

   procedure print;
   var i,j:longint;

      function isdark(s:string):boolean;
      var i:longint;
      begin
        for i:=1 to numberofdarkchoose do
         if (length(s)>=length(darkchoose[i])) and (pos(darkchoose[i],s)=length(s)-length(darkchoose[i])+1) then exit(true);
        exit(false);
      end;

   begin
     if (oldn=n) then exit;
     if (oldn>=l) and (oldn<=r) then
     begin
       gotoxy(x1,y1+oldn-l);for i:=1 to charlen do write(' ');
       tc(notchoosecolor);write(s[oldn]);
       gotoxy(x1+charlen+maxlen,wherey);for i:=1 to charlen do write(' ');
     end
     else begin
       gotoxy(x1,y1);for i:=1 to charlen-1 do write(' ');
       gotoxy(x1+charlen+maxlen,wherey);for i:=1 to charlen do write(' ');
       gotoxy(x1,y1+r-l);for i:=1 to charlen-1 do write(' ');
       gotoxy(x1+charlen+maxlen,wherey);for i:=1 to charlen do write(' ');
     end;
     for i:=l to r do
     begin
       gotoxy(x1+charlen,y1+i-l);
       if i=n then tc(choosecolor) else tc(notchoosecolor);
       if isdark(os[i]) then tc(notchoosecolor);
       if (oldl<>l) or (oldr<>r) or (i=n) then
       begin
         write(s[i]);
         for j:=1 to maxlen-length(s[i]) do write(' ');
       end;
       if i=n then
       begin
         if i=n then tc(choosecolor) else tc(notchoosecolor);
         gotoxy(x1,wherey);write(choosechar);
         gotoxy(x1+charlen+maxlen+1,wherey);write(choosechar);
       end;
     end;
     oldn:=n;oldl:=l;oldr:=r;
   end;

begin
  charlen:=length(choosechar)+1;
  x1:=wherex;
  y1:=wherey;
  if copy(writestring,length(writestring)-1,2)<>ln then writestring:=writestring+ln;
  repeat
    max:=0;
    while pos(ln,writestring)<>0 do
    begin
      if max=maxchoose then break;

      t:=pos(ln,writestring);
      inc(max);
      s[max]:=copy(writestring,1,t-1);
      os[max]:=s[max];
      delete(writestring,1,t+1);
      if length(s[max])>maxx-charlen*2 then s[max]:=copy(s[max],1,maxx-charlen*2-5)+'...'+copy(s[max],length(s[max])-1,2);

    end;
    maxlen:=0;
    for i:=1 to max do
    begin
      right[i]:=x1+charlen+length(s[i]);
      maxlen:=math.max(length(s[i]),maxlen);
    end;
    if max=0 then break;
    for i:=1 to max do
    begin
      t:=length(s[i]);
      case align of
        0:{do nothing};
        1:for j:=1 to (maxlen-t) div 2 do s[i]:=' '+s[i];
        2:for j:=1 to maxlen-t do s[i]:=' '+s[i];
      end;
    end;//end fori
    l:=1;r:=min(max,maxy);
    n:=1;
    oldn:=-1;oldl:=-1;oldr:=-1;
    repeat
      print;
      while keypressed=false do;
      case readkey of
        #13:break;
        #0:if keypressed then
           case readkey of
             #28:break;
             #72:begin
                   if n>1 then dec(n)
                    else n:=max;
                 end;
             #80:begin
                   if n<max then inc(n)
                    else n:=1;
                 end;
           end;
      end;
      if n<l then
      begin
        dec(r,l-n);
        l:=n;
      end
       else if n>r then
       begin
         inc(l,n-r);
         r:=n;
       end;
    until false;
    exit(n);
  until true;
end;
Function chooseone(var writestring:ansistring;choosechar:string;choosecolor,notchoosecolor:longint;align:longint):longint;
begin
  exit(chooseone(writestring,choosechar,choosecolor,notchoosecolor,windmaxx-wherex+1,windmaxy-wherey+1,align));
end;
Function chooseone(var writestring:ansistring;choosecolor,notchoosecolor:longint;align:longint):longint;
begin
  exit(chooseone(writestring,'≡',choosecolor,notchoosecolor,windmaxx-wherex+1,windmaxy-wherey+1,align));
end;
Function chooseone(var writestring:ansistring;choosechar:string;align:longint):longint;
begin
  exit(chooseone(writestring,choosechar,15,8,windmaxx-wherex+1,windmaxy-wherey+1,align));
end;
Function chooseone(var writestring:ansistring;align:longint):longint;
begin
  exit(chooseone(writestring,'≡',15,8,windmaxx-wherex+1,windmaxy-wherey+1,align));
end;
Function chooseone(var writestring:ansistring):longint;
begin
  exit(chooseone(writestring,'≡',15,8,windmaxx-wherex+1,windmaxy-wherey+1,1));
end;

BEGIN
  tb(0);tc(7);
  NumberOfDarkChoose:=2;
  DarkChoose[1]:='返回';DarkChoose[2]:='退出';
End.
