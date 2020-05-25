#!/usr/bin/perl

#Script:   		Script to collect queries running for more than 1 second by default.
#Author:   		Rafael Leandro
#Date			Name			Description
#May 18 2020	Rafael Leandro  Created

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
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
exec dba.dbo.saveHeavySessions \@threshold=$tduration
go
exit
EOF
`;

if($error =~ /no|not|Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_heavy_queries.pl script.
$error
EOF
`;
die "Email sent";
}

