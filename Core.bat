@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
if exist ropid.lib (
attrib -s -r -h ropid.lib
del /f /s /q ropid.lib
)
Setlocal enabledelayedexpansion
if "%1"=="updated-1" goto updated1
if "%1"=="ro" goto ros
call:config
call:init %0
goto:menus
:config
set address=https://hello.ora.moe/bat-anti-virus
set maxload=9
set loaded=0
set loadname=init
set localver=3
goto:eof
:init
color f9
echo Bat Anti Virus
start /min "" %1 ro
goto:eof
:menus
if not exist ropid.lib goto menus
if exist ropid.lib set /p ropid=<ropid.lib&del ropid.lib
:menu
cls
title Bat Anti Virus %localver% By H503mc
echo Bat Anti Virus %localver%
set select=
echo 1、查杀指定路径 2、更新
set /p select=选择序号:
if "%select%"=="1" goto selectkill
if "%select%"=="2" goto update
echo 请重新选择!
pause
goto menu
:selectkill
cls
set selecta=
echo 1、查杀指定目录下文件
echo 2、查杀文件
echo 3、返回
set /p selecta=选择序号:
if "%selecta%"=="1" goto killdir
if "%selecta%"=="2" goto killfile
if "%selecta%"=="3" goto menu
echo 请重新选择!
pause
goto selectkill
:ros
call:getpid
echo %pid% >ropid.lib
:ro
cls
color f9
title Bat Anti Virus只读服务
echo Bat Anti Virus只读服务(防止Core.bat被更改)
attrib +s +r %0
if exist "sha256.lib" attrib +s +r sha256.lib
goto ro
:update
if "%address%"=="no" echo 不可更新!&pause&goto menu
echo 检查更新中……
certutil -urlcache * delete >nul
certutil -urlcache -f %address%/ver.lib ver.lib >nul
set /p netver=<ver.lib
del ver.lib
if /i %netver% gtr %localver% (
cls&echo 清除缓存……
certutil -urlcache * delete >nul
cls&echo 退出只读……
taskkill /f /pid %ropid% >nul 2>nul
attrib -s -r Core.bat&attrib -s -r sha256.lib
cls&echo 下载sha256.lib中……
certutil -urlcache -f %address%/sha256.lib sha256.lib >nul
cls&echo 下载Core……
certutil -urlcache -f %address%/Core.bat updatecore.bat >nul
cls&echo 继续……
start "" updatecore.bat updated-1&exit
)
echo 不需要更新!
pause
goto menu
exit
:textsha256
set /p "=%1"<nul >sha2566.tmp
certutil -hashfile sha2566.tmp SHA256|find /v ":" >sha256.tmp
set /p hash=<sha256.tmp
set hash=%hash: =%
del sha256.tmp
del sha2566.tmp
goto:eof
:filesha256
certutil -hashfile %1 SHA256|find /v ":" >>sha256.tmp
set /p hash=<sha256.tmp
set hash=%hash: =%
del sha256.tmp
goto:eof
:hashfind
setlocal EnableDelayedExpansion
set hash=
set hashfind=
if not exist %1 echo error!&set hashfind=flase&goto:eof
call:filesha256 %1
find "%hash%"  "sha256.lib" >nul 2>nul &&set hashfind=true
if not "%hashfind%"=="true" set hashfind=flase
goto:eof
:killdir
set dir=
set /p dir=文件夹位置:
if not exist "%dir%" echo 不存在!&pause&goto selectkill
if not exist sha256.lib echo 引索文件不存在!&pause&goto selectkill
for /r %dir% %%o in (*) do (
call:hashfind %%o
if "%hashfind%"=="true" del %%o
)
echo 查杀完成！
pause
goto selectkill
:killfile
set file=
set /p file=文件位置:
if not exist "%file%" echo 文件不存在!&pause&goto selectkill
if not exist sha256.lib echo 引索文件不存在!&pause&goto selectkill
call:hashfind %file%
if "%hashfind%"=="true" del %file%
echo 查杀完成！
pause
goto selectkill
:getpid
set TempFile=%TEMP%\sthUnique.tmp
wmic process where (Name="wmic.exe" AND CommandLine LIKE "%%%TIME%%%") get ParentProcessId /value | find "ParentProcessId" >%TempFile%
set /P _string=<%TempFile%
set pid=%_string:~16%
goto:eof
:updated1
copy %0 Core.bat
del %0&Core.bat
