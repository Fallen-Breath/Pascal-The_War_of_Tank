@echo off
:orz
echo Брвыжа...
C:\FPC\2.0.4\bin\i386-win32\fpc Leftist_Tree.pas -g
C:\FPC\2.0.4\bin\i386-win32\fpc test.pas -g
pause
goto orz