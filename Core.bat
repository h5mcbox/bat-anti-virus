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
Setlocal enabledelayedexpansion
if "%1"=="updated-1" goto updated1
if "%1"=="ro" goto ro
call:config
call:init %0
goto:menu
:config
set address=https://h5mcbox.github.io/bat-anti-virus
set maxload=9
set loaded=0
set loadname=init
set localver=1
goto:eof
:init
color f9
echo Bat Anti Virus
start /min "" %1 ro
goto:eof
:menu
cls
title Bat Anti Virus
echo Bat Anti Virus
set select=
echo 1����ɱָ��·�� 2������
set /p select=ѡ�����:
if "%select%"=="1" goto selectkill
if "%select%"=="2" goto update
echo ������ѡ��!
pause
goto menu
:selectkill
cls
set selecta=
echo 1����ɱָ��Ŀ¼���ļ�
echo 2����ɱ�ļ�
echo 3������
set /p selecta=ѡ�����:
if "%selecta%"=="1" goto killdir
if "%selecta%"=="2" goto killfile
if "%selecta%"=="3" goto menu
echo ������ѡ��!
pause
goto selectkill
:ro
cls
title Bat Anti Virusֻ������
echo Bat Anti Virusֻ������
attrib +s +r %0
if exist "sha256.lib" attrib +s +r sha256.lib
if exist "exitreadonly" del exitreadonly&attrib -s -r Core.bat&attrib -s -r sha256.lib&exit
goto ro
:update
if "%address%"=="no" echo ���ɸ���!&pause&goto menu
echo �������С���
certutil -urlcache * delete >nul
certutil -urlcache -f %address%/ver.lib ver.lib >nul
set /p netver=<ver.lib
if /i %netver% gtr %localver% (
cls&echo ������桭��
certutil -urlcache * delete >nul
cls&echo �˳�ֻ������
echo runoff >exitreadonly
cls&echo ����sha256.lib�С���
certutil -urlcache -f %address%/sha256.lib sha256.lib >nul
cls&echo ����Core����������
certutil -urlcache -f %address%/Core.bat updatecore.bat&start "" updatecore.bat updated-1&exit
)
echo ����Ҫ����!
pause
goto menu
exit
:textsha256
echo %1 >sha2566.tmp
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
set /p dir=�ļ���λ��:
if not exist "%dir%" echo ������!&pause&goto selectkill
if not exist sha256.lib echo �����ļ�������!&pause&goto selectkill
for /r %dir% %%o in (*) do (
call:hashfind %%o
if "%hashfind%"=="true" del %%o
)
echo ��ɱ��ɣ�
pause
goto selectkill
:killfile
set file=
set /p file=�ļ�λ��:
if not exist "%file%" echo �ļ�������!&pause&goto selectkill
if not exist sha256.lib echo �����ļ�������!&pause&goto selectkill
call:hashfind %file%
if "%hashfind%"=="true" del %file%
echo ��ɱ��ɣ�
pause
goto selectkill
:updated1
copy Core.bat backupcore.bat
copy %0 Core.bat
del %0&Core.bat