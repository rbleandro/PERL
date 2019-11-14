#!/usr/bin/perl -w


#Script:   This script formats the Sybase audit data and sends the final report via email
#
#Author:   Ahsan Ahmed
#Revision: Rafael Leandro
#
#11/01/07		Ahsan Ahmed		Originally created
#May 10 2019	Rafael Leandro	Modified to add the DBA team to the final group and to remove obsolete mail recipients as well. Added error handling for the procedure call.
#May 29 2019	Rafael Leandro	Removed data treatment from the script. All data treatment is now done at the database view level.
#May 29 2019	Rafael Leandro	Simplified the bcp command (less control characters).
#May 29 2019	Rafael Leandro	Added file compression. Now that we are auditing more events and expanding their details, we need to reduce the final file size.

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
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use sybsecurity
go
execute audit_thresh
go
exit
EOF
bcp sybsecurity..audit_report_vw out /tmp/audit_report_vw.tdl -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"\t"
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/ || $sqlError =~ /Error/ || $sqlError =~ /ERROR/ || $sqlError =~ /error/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - weedkly_audit_rpt at $finTime

$sqlError
EOF
`;
die;
}

`rm /tmp/audit_report_vw.tdl.gz`;
`gzip /tmp/audit_report_vw.tdl`;


`/usr/bin/mutt -s "Database weekly changes - Audit report"  "servicedesk\@canpar.com,frank_orourke\@canpar.com,jim_pepper\@canpar.com,CANPARDatabaseAdministratorsStaffList\@canpar.com" -a /tmp/audit_report_vw.tdl.gz <<EOF
Here is your weekly audit report for database changes on Sybase production server.

Thanks,
The DBA team.
EOF
`;
