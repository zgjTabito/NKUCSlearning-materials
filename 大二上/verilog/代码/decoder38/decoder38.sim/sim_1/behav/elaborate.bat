@echo off
set xv_path=D:\\vivado\\Vivado\\2017.1\\bin
call %xv_path%/xelab  -wto 4ac19dbf3b2c423ba474661188a4e9fb -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_behav xil_defaultlib.tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
