:: Custom script for RIDE for testing logging of Robot Framework libraries
@echo off
python -m robot %*
python -m robotstatuschecker %~d2%~p2output.xml
python -m robot.rebot -d %~d2%~p2 %~d2%~p2output.xml
