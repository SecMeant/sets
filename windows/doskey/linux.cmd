@echo off
doskey cat=type $*
doskey clear=cls $*
doskey cp=copy $*
doskey his=doskey /history
doskey ls=dir $*
doskey mv=move $*
doskey rm=del $*
doskey c11=g++ -std=c++11 -Wall -Wextra $*
doskey c14=g++ -std=c++14 -Wall -Wextra $*
doskey c17=g++ -std=c++17 -Wall -Wextra $*
set sfmlcpp=-I C:\SFML\include -I C:\SFML\lib -L C:\SFML\bin\*

prompt %USERNAME%@%USERDOMAIN%$S$G
@echo on

