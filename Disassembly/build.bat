@echo off
bin\asm68k /q /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- sonic1.asm, need4speed.bin
bin\rompad.exe need4speed.bin 255 0
bin\fixheadr.exe need4speed.bin
pause