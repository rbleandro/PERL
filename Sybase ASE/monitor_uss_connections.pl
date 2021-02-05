#!/usr/bin/perl

#Script:   		Monitors connections from uss user and kills idle connections if their number is higher than 250.
#Jun 04 2020	        Rafael Leandro  Created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $tduration=1000;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'threshold|t=i' => \$tduration
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 1000\n";

if ($skipcheckprod == 0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
exec dba.dbo.rp_kill_recvsleep_sessions 'uss'
go
exit
EOF
`;

if($error =~ /no|not|Msg/ && $error != /Msg 511/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_uss_connections.pl script.
$error
EOF
`;
die "Email sent";
}

