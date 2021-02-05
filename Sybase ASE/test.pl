#!/usr/bin/perl -w

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Sys::Hostname;

my $prodserver = hostname();
my $drserver = 'CPDB4';
my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my $stbyserver="";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod 0 --to rleandro\n";

my @prodline="";

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";


system("/usr/bin/crontab -l > /opt/sap/cron_scripts/cronjobs.bk");
my $cronbkp = $? >> 8;
print "$cronbkp\n\n";
system("scp -p /opt/sap/cron_scripts/cronjobs.bk sybase\@$stbyserver:/opt/sap/cron_scripts");
my $stbycopy = $? >> 8;
print "$stbycopy\n\n";
#my $drcopy=system("scp -p /opt/sap/cron_scripts/cronjobs.bk sybase\@$drserver:/opt/sap/cron_scripts"); #uncomment this when the DR server comes back online
