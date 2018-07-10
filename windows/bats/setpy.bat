@echo off

if "%1" == "" goto usage

rem python3
if "%1" == "py3" goto py3
if "%1" == "3" goto py3

rem python2
if "%1" == "py2" goto py2
if "%1" == "2" goto py2

:usage
	echo You need to specify target. x86, x64 or x64posix.
	exit /b 1

:py3
	call py3.bat
	exit /b 0

:py2
	call py2.bat
	exit /b 0

