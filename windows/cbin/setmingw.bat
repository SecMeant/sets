@echo off

if "%1" == "" goto usage
if "%1" == "x86" goto x86
if "%1" == "x64" goto x64
if "%1" == "x64posix" goto x64posix

:usage
	echo You need to specify target. x86, x64 or x64posix.
	exit /b 1

:x86
	set PATH=C:\MinGW\bin;%PATH%
	g++ -v
	exit /b 0

:x64
	set PATH=C:\Program Files\mingw-w64\x86_64-7.2.0-win32-seh-rt_v5-rev1\mingw64\bin;%PATH%
	g++ -v
	exit /b 0

:x64posix
	set PATH=C:\Program Files\mingw-w64\x86_64-7.2.0-posix-seh-rt_v5-rev1\mingw64\bin;%PATH%
	g++ -v
	exit /b 0

