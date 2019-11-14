@echo off

perl %Dropbox%\DBA\ScriptWH\Perl\CPDB1\excel_to_csv.pl > %Dropbox%\DBA\ScriptWH\IQ\data-integration\eng_temp.csv
pscp -i %Dropbox%\DBA\ScriptWH\Linux\private-key.ppk %Dropbox%\DBA\ScriptWH\IQ\data-integration\eng_temp.csv sybase@CPIQ:/opt/sybase/bcp_data

pause


