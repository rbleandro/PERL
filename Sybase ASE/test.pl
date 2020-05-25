#!/usr/bin/perl

#Script:   	This script checks for long running transactions that are preventing database log flush
#Author:   	Rafael Leandro
#Revision:
#Date			Name				Description
#---------------------------------------------------------------------------------
#Aug 18 2019	Rafael Leandro		Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList@canpar.com; jpepper@canpar.com; Kenny.Ip@loomis-express.com';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 10\n";

if ($skipcheckprod == 0){
	open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
	while (<PROD>){
		@prodline = split(/\t/, $_);
		$prodline[1] =~ s/\n//g;
	}
	close PROD;
	if ($prodline[1] eq "0" ){
		print "standby server \n";
		die "This is a stand by server\n";
	}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}


`/usr/sbin/sendmail -t -i <<EOF
To: $mail
Subject: ERROR - monitor_long_running_transactions.pl script.
just a test
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";

