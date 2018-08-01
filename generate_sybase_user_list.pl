#!/usr/bin/perl -w

##############################################################################
#Script:   This script generates Sybase users list                           #
#                                                                            #
#Author:   Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Feb 4 2015	Amer Khan	Originally created                           #
#                                                                            #
##############################################################################

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -SCPDB1 -b -n<<EOF 2>&1
use master
go
select name, CASE when locksuid is null then 'Yes' else 'No' end as Enabled from syslogins where suid > 3 and locksuid is null order by name
go
exit
EOF
`;

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: servicedesk\@canpar.com, audit.report\@loomis\-express.com
From: amer_khan\@canpar.com
Subject: Sybase Access Users List Created on $finTime

Please assign to Adela for her review.

===================================

$sqlError

===================================
EOF
`;

