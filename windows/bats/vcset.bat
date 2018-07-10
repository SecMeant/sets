@echo off

if "%1" == "" goto usage
if "%1" == "x86" goto x86
if "%1" == "x64" goto x64
if "%1" == "arm" goto arm
if "%1" == "arm64" goto arm64

:usage
	echo You need to specify target. x86, x64, arm, or arm64.
	exit /b 1

:x86
	"C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars32"
	set PATH=c:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.13.26128\bin\Hostx64\x86;%PATH%
	exit /b 0

:x64
	"C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64"
	set PATH=c:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.13.26128\bin\Hostx64\x64;%PATH%
	exit /b 0


:arm
	set PATH=c:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.13.26128\bin\Hostx64\arm;%PATH%
	exit /b 0


:arm64
	set PATH=c:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.13.26128\bin\Hostx64\arm64;%PATH%
	exit /b 0

