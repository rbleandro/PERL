#!/usr/bin/perl -w

##############################################################################
#Script:   This script clears proc cache and frees unused pages, due to a bug#
#          in this version of server ASE 15.7.1 SP135                        #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Jan 5 2016	Amer Khan	Created					     #
##############################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -w200 <<EOF 2>&1
use master
go
sp_monitorconfig "procedure cache"
go
dbcc proc_cache(free_unused)
go
sp_monitorconfig "procedure cache"
go
/*
use tempdb
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb1
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb2
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb3
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb4
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb5
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb6
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb7
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
use tempdb8
go
dbcc traceon(3604)
go
dbcc orphantables
go
dbcc traceoff(3604)
go
dbcc orphantables("drop")
go
*/
exit
EOF
`;

print $sqlError."\n";

$finTime = localtime();
print "Time Finished: $finTime\n";
