#!/usr/bin/perl -w

##############################################################################
#Script:   This script  archives data from cmf_data svp_parce to arch_db     #
#          every week                                                        #
#                                                                            #
#Author:   Amer Khan                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Aug 7 2014	Amer Khan	Originally Created                           #
##############################################################################

#Check if the process is still running from last scheduled time
$isProcRunning =`ps -ef|grep sybase|grep purge|grep purge_arch_db|grep "exec purge_arch_db" | grep -v grep`;

if($isProcRunning){
die "Process is still running...dying now: $isProcRunning \n";
}else{
print "Is it really running: $isProcRunning \n";
}

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use arch_db
go
declare \@run_date date
select \@run_date = dateadd(yy,-7,getdate())
select "Executing for data prior to this date -->",\@run_date
exec purge_arch_db \@run_date   
go   
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:CANPARDatabaseAdministratorsStaffList\@canpar.com 
Subject: Purge arch_db at $finTime

$sqlError
EOF
`;
}
