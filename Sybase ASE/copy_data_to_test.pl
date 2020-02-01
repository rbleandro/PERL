#!/usr/bin/perl -w

##########################################################################################################################################################
#Script:   This script copies data from production to cpsybtest using the bcp component
#
#Author:	Rafael Leandro
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Oct 24 2018	Rafael Leandro	Created
#Aug 09 2019	Rafael Leandro	1.Added parameters to control the script behavior (check the usage guidelines below). 
#								2.Added mail recipient parameter.
#								3.Added error handling
#								4.Added CPDB1 to the list of trustworthy servers for SSH protocol
##########################################################################################################################################################

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my $database = "";
my $table = "";
my $action = "";
my @prodline="";
my $scpError="";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'action|a=s' => \$action,
	'db|d=s' => \$database,
	'table|t=s' => \$table
) or die "Usage: $0 --db|d svp_cp --table|t svp_stats --skipcheckprod|s 0 --to|r rleandro --action|a bcl\n";

if ($database eq "" || $table eq "" || $action eq "" ){
   print "Usage: copy_data_to_test.pl --db svp_cp --table svp_stats --skipcheckprod 0 --to rleandro --action bcl.\n";
   print "The parameter --action will control the script behavior. Type b to bcp out only, bc to bcp out and copy the generated file to the destination server, bcl to do everything else plus load the data at the destination server.";
   print "The parameter --to tells the script the mail recipient in case of any errors. If not provided it defaults to the DBA mail group";
   die "Script Executed With Wrong Number Of Arguments\n";
}

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

my $testserver = '10.3.1.165';

#Set starting variables
my $currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
my $startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

`find /opt/sap/db_backups/ -mindepth 1 -mtime +7 -delete`;

my $bcpError=`/opt/sap/OCS-16_0/bin/bcp $database..$table out /opt/sap/db_backups/$database\_$table.dat -n -S CPDB1 -U sa -P\`/opt/sap/cron_scripts/getpass.pl sa\``;

if ($bcpError =~ /Error/ || $bcpError =~ /Msg/){
print $bcpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_data_to_test at $finTime - bcp out phase

$bcpError
EOF
`;
die;
}

if ($action =~ /bc/){
$scpError=`scp /opt/sap/db_backups/$database\_$table.dat sybase\@10.3.1.165:/opt/sap/db_backups/`;

$scpError = $? >> 8;
if ($scpError != 0) {
print "$scpError\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_data_to_test (scp phase) at $finTime

$scpError
EOF
`;
die;
}
}

if ($action =~ /bcl/){
my $load_msgs = `ssh $testserver /opt/sap/cron_scripts/load_data_to_test.pl $database $table $mail`;
print "$load_msgs \n";

if ($load_msgs =~ /Error/ || $load_msgs =~ /Msg/){
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_data_to_test at $finTime - bcp in phase

$load_msgs
EOF
`;
die;
}
}

$finTime = localtime();
print "Time Finished: $finTime\n";