@echo off

IF "%1" == "" (
	start kitty -load vm holz@192.168.1.2
) ELSE (
  start kitty -load vm %1@192.168.1.2
)
