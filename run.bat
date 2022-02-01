@echo off

cls
pause>nul
set m1=1.fsm
echo %m1%
type 1.fsm
pause>nul



cls
pause>nul
set c1=perl paths.pl --input 1.fsm ^^^> 1.paths
echo %c1%
pause>nul
perl paths.pl --input 1.fsm > 1.paths
type 1.paths
pause>nul



cls
pause>nul
set c2=perl check.pl --paths 1.paths --model 1.fsm
echo %c2%
pause>nul
perl check.pl --paths 1.paths --model 1.fsm
pause>nul



cls
pause>nul
set c3=perl reduce.pl --input ab09.fsm --n 18 ^^^> 18.fsm
echo %c3%
pause>nul
perl reduce.pl --input ab09.fsm --n 18 > 18.fsm
type 18.fsm
pause>nul



cls
pause>nul
set c4=perl paths.pl --input 18.fsm ^^^> 18.paths
echo %c4%
pause>nul
perl paths.pl --input 18.fsm > 18.paths
type 18.paths
pause>nul



cls
pause>nul
set c5=perl check.pl --paths 18.paths --model ab09.fsm
echo %c5%
pause>nul
perl check.pl --paths 18.paths --model ab09.fsm
pause>nul



cls
