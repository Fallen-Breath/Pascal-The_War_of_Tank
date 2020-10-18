uses mmsystem,sysutils;
var s,m:ansistring;
begin
  if paramcount=0 then halt;
  s:=paramstr(1);//s:='H:\OI\program\神迹\坦克大战\MusicPlayer\stone1.wav';
  m:=paramstr(2);
  if length(m)=0 then m:='0';
  case m[1] of
    '0':sndplaysound(pchar(s),SND_SYNC);//播放一次
    '1':begin
          sndplaysound(pchar(s),SND_LOOP);//播放多次
          while FileExists(pchar('stopplaymucsic'))=false do;
        end;
  end;
  halt;
end.

