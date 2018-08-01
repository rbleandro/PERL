#!/usr/bin/perl

#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

$repError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
##if exists (select 1 from sysprocesses where program_name like "%rep agent%" and dbid = db_id('$database'))
##sp_stop_rep_agent $database
go
exit
EOF
`;

print "Shutting any rep agent down...$repError\n";

print "\n###Killing any users still logged into database###\n";
`/opt/sybase/cron_scripts/kill_processes.pl $server $database`;

print "***Initiating read_only At:".localtime()."***\n";
$modeError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
sp_dboption $database,'single',true
go
use $database
go
checkpoint
go
exit
EOF
`;



print "Read Only Setup Messages:\n$modeError \n";
