#!/usr/bin/perl -w

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

my $stbyserver;
my $lbkpdir;
my $rbkpdir;
if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; $lbkpdir='/opt/sap'; $rbkpdir='/opt/sap';} else { $stbyserver = 'CPDB2'; $lbkpdir='/opt/sap'; $rbkpdir='/opt/sap';}

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
dump database mpr_data to "$lbkpdir/db_backups/mpr_data.dmp" compression=100
go
dump database mpr_data_lm to "$lbkpdir/db_backups/mpr_data_lm.dmp" compression=100
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - dump_databases_mpr at $finTime

$sqlError
EOF
`;
die;
}

#Copying files to standby server
my $scpError;
$scpError=`scp -p $lbkpdir/db_backups/mpr_data.dmp sybase\@$stbyserver:$rbkpdir/db_backups`;
print "$scpError\n";

$scpError=`scp -p $lbkpdir/db_backups/mpr_data_lm.dmp sybase\@$stbyserver:$rbkpdir/db_backups`;
print "$scpError\n";


#Copying files to DR server
##$scpError=`scp -p $lbkpdir/db_backups/mpr_data.dmp sybase\@$drserver:$lbkpdir/db_backups`;
##print "$scpError\n";

##$scpError=`scp -p $lbkpdir/db_backups/mpr_data_lm.dmp sybase\@$drserver:$lbkpdir/db_backups`;
##print "$scpError\n";

#Loading databases into standby server
my $load_msgs;
$load_msgs = `ssh $stbyserver /opt/sap/cron_scripts/load_databases_mpr.pl -s $stbyserver`;
#Loading databases into DR server
##$load_msgs_dr = `ssh $drserver /opt/sap/cron_scripts/load_databases_mpr.pl -s $drserver`;

print "$load_msgs \n";
##print "$load_msgs_dr \n";

$finTime = localtime();
print "Time Finished: $finTime\n";
