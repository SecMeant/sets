@echo off

IF "%1" == "" (
	conemu "ssh holz@192.168.1.2"
) ELSE (
 conemu "ssh %1@192.168.1.2"
)
