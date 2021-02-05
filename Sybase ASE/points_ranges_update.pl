#!/usr/bin/perl -w


#Script:   	This script updates points_ranges table in cmf_data
#
#Author:   		Amer Khan
#2006/12/11		Amer Khan			Originally created
#11/01/07   	Ahsan Ahmed      	Modified
#April 7 2020	Rafael 				Improved the error checking logic

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
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}

#Set inputs
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = ""; # Initialize Var

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
execute reset_points_ranges
go
execute reset_points_ranges_minor
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i || $sqlError =~ /Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject:   $prodserver ERROR - updating points_ranges

Followinv status was received during updating points_ranges that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime on $prodserver: $currTime\n";
