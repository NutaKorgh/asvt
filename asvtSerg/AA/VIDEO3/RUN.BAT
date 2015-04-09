@echo off
tasm code
tlink /x /t code
ch %1 %2
pause
code