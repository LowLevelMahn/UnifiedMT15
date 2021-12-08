@echo off

::just use clangs better error/warning detection to find bugs, the resulting obj file is of no use

set llvm_bin="C:\Program Files\LLVM\bin"
set clang_exe=%llvm_bin%\clang.exe
set clang_tidy_exe=%llvm_bin%\clang-tidy.exe

echo ===================================================

%clang_exe% -c -m32 -pedantic drv.c
pause

echo ===================================================

::what does clang-tidy mean

%clang_tidy_exe% drv.c -checks=*,-cppcoreguidelines-avoid-magic-numbers,-readability-magic-numbers,-google-readability-todo,-altera-struct-pack-align,-hicpp-uppercase-literal-suffix,-readability-uppercase-literal-suffix --   
pause
