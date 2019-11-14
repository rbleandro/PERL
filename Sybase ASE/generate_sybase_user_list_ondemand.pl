#!/usr/bin/perl -w

#Script:   This script generates Sybase users list
#
#Author:   Rafael Leandro
#Date           Name            Description
#Feb 4 2015		Rafael Leandro	Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my @prodline="";
my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 100000\n";

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

#Set starting variables
my $currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

my $sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -SCPDB1 -b -n<<EOF 2>&1
use master
go
select name, CASE when locksuid is null then 'Yes' else 'No' end as Enabled
from master..syslogins where suid > 3
order by name
go
exit
EOF
`;

if($sqlError =~ /Msg/)
{
print $sqlError . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - generate_sybase_user_list_ondemand.pl
$sqlError
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
From: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Sybase Access Users List Created on $finTime

Please assign to Adela for her review.

===================================

$sqlError

===================================
EOF
`;

