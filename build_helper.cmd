@echo off

if "%~1" == "" goto error
if "%~2" == "" goto error
if "%~3" == "" goto error
if "%~4" == "" goto error

rem source folder
set src_dir=%~dp0
rem out of source build folder
set build_dir=%~dp0\..\_build
mkdir %build_dir%

set tools_dir=f:\projects\fun\dos_games_rev\tools

set ulink_exe=%tools_dir%\ulink\ulink.exe
set uasm_exe=%tools_dir%\uasm_x64\uasm64.exe

set WATCOM=%tools_dir%\open-watcom-2_0-c-win-x64
set WATCOM_BIN=%watcom%\binnt64
set INCLUDE=%watcom%\h
set PATH=%WATCOM_BIN%;%PATH%
set wcc_exe=%watcom_bin%\wcc.exe

:: 10 or 11
set drv_version=%1
set equal_binary=%2
set remove_dead_code=%3
set replace_with_c_code=%4

set output_dir=%build_dir%\%drv_version%
echo output_dir: %output_dir%

mkdir %output_dir%
pushd %output_dir%

set src_dir=%~dp0

%uasm_exe% -DVERSION=%drv_version% -DEQUAL_BINARY=%equal_binary% -DREMOVE_DEAD_CODE=%remove_dead_code% -DREPLACE_WITH_C_CODE=%replace_with_c_code% %src_dir%\MT15.asm

pause

if "%replace_with_c_code%" NEQ "1" goto link_asm_only

rem -2 only 286 code
rem -zl and -zls no standard-lib dependencie and unused symbols removed from obj
rem -s Removes stack check

:: optimization flags: http://www.x-hacker.org/ng/wcppug/ng43372.html
:: The recommended options for generating the fastest 16-bit Intel code are
:: for 286: /oneatx /oh /oi+ /ei /zp8 /2 /fpi87 /fp2

%wcc_exe% %src_dir%\drv.c -2 -zl -zls -s -DVERSION=%drv_version%

pause

set asm_obj_file=%output_dir%\MT15.obj
set cpp_obj_file=%output_dir%\drv.obj
set drv_file=%output_dir%\MT15.drv
set map_file=%output_dir%\MT15.map
echo obj_file: %obj_file%
echo drv_file: %drv_file%
echo map_file: %map_file%
%ulink_exe% -T16 -Tbi %asm_obj_file%  %cpp_obj_file%, %drv_file%, %map_file%

pause

goto compare

:link_asm_only

set obj_file=%output_dir%\MT15.obj
set drv_file=%output_dir%\MT15.drv
set map_file=%output_dir%\MT15.map
echo obj_file: %obj_file%
echo drv_file: %drv_file%
echo map_file: %map_file%
%ulink_exe% -T16 -Tbi %obj_file%, %drv_file%, %map_file%

pause

:compare

popd

if "%equal_binary%" NEQ "1" goto success

echo ------
echo check if result is still binary equal to orginal driver
echo ------

set org_dir=%src_dir%\org
echo org_dir: %org_dir%

fc /B %org_dir%\%drv_version%\MT15.drv %output_dir%\MT15.drv 
if %ERRORLEVEL% == 0 goto success
echo !!!!
echo !!!! Resulting DRV is not binary identical to original !!!
echo !!!!

goto error

:success
exit /b 0

:error
echo first parameter needs to be the driver version: 10 for stunts 1.0, 11 for stunts 1.1
pause
exit /b 1

