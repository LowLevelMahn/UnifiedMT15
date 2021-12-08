::@echo off

:: originals - should always build
call build_helper.cmd 10 1 0 0
call build_helper.cmd 11 1 0 0

:: c port stuff
call build_helper.cmd 10 0 0 1
call build_helper.cmd 11 0 0 1

pause
