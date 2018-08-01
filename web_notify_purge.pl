#!/usr/bin/perl -w

##############################################################################
#Subject:	Web related Job created at the request of An Phan.           #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Sep 21 2015	Amer Khan 	Originally created                           #
#                                                                            #
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

print "web_notify_purge StartTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use lmscan
go
execute web_notify_purge 90
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,An.Phan\@loomis-express.com
Subject: ERROR - Executing nightly web_notify_purge

Following status was received during web_notify_purge that started on $currTime
$sqlError
EOF
`;

}

