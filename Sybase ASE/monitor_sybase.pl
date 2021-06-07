#!/usr/bin/perl

#Script:       This script monitors sybase Database  
#Nov 01 2021   Ahsan Ahmed     Modified         
#May 10 2021	Rafael Leandro 	Added several features and enabled kerberos auth

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";
my$standbyserver="";

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help
) or die showDefaultHelp(1,$0);

showDefaultHelp($help,$0);
checkProcessByName($checkProcessRunning,$0);
isProd($skipcheckprod);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";
   
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}else{
   $standbyserver = "CPDB2";
}

my $error = `. /opt/sap/SYBASE.sh
isql_r -V -S$standbyserver -l180 -n -b <<EOF 2>&1
exit
EOF
`;

print $error;

if ($error) {
print "sybase frozen   Error: $error and hostname: $standbyserver \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Sybase Server not responding on $standbyserver!!!

Sybase Server may be down on $standbyserver
******
$error \`date\`
******
EOF
`;
}
