:: Custom script for RIDE for testing logging of Robot Framework libraries
@echo off
robot -L DEBUG --quiet %*
python -m robotstatuschecker %~d2%~p2output.xml
rebot -d %~d2%~p2 %~d2%~p2output.xml
