@echo off
tasm code
tlink /x /t code
ch %1 %2
final /s
code
final /r
ch  3 0