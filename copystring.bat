@ECHO OFF
Findstr /v server.seed server.cfg >> tempserver.cfg
ECHO Created tempserver.cfg

DEL server.cfg
ECHO Deleted server.cfg

REN tempserver.cfg server.cfg
ECHO Renamed tempserver.cfg

SET /p text=< seedlist.txt
ECHO %text% >> server.cfg
ECHO Inserted server.seed value into server.cfg

more +1 seedlist.txt > templist.txt
ECHO Removed top line of seedlist file and saved to templist.txt

DEL seedlist.txt
ECHO Deleted seedlist.txt

REN templist.txt seedlist.txt
ECHO Renamed templist.txt to seedlist.txt

TIMEOUT 2