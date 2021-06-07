#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $currTime="";
my $sqlError="";

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";

my $database = $ARGV[0];
my $table = $ARGV[1]; 
$mail = $ARGV[2]; 

#$deleteoldfiles =`find /opt/sap/db_backups/ -mindepth 1 -mtime +7 -delete`;

my $bcpError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/bcp_r $database..$table out /opt/sap/db_backups/$database\_$table\_backup.dat -n -V -S$prodserver`;

send_alert($sqlError,"Msg|Error",$noalert,$mail,$0,"bcp_r out");

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use $database
go
truncate table $table
go
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"truncate table");

$bcpError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/bcp_r $database..$table in /opt/sap/db_backups/$database\_$table.dat -n -V -S$prodserver`;

send_alert($sqlError,"Msg|Error",$noalert,$mail,$0,"bcp_r in");