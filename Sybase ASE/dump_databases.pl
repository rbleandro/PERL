#!/usr/bin/perl -w

#Script:   This script dumps various databases to the secondary servers
#
#Author:		Amer Khan
#Revision:
#Date           Name            Description
#----------------------------------------------------------------------------
#Oct 12 2016	Amer Khan		Created
#Aug 14 2019	Rafael Leandro	1.Since all user databases have been added to the replication, this script was completely rewritten to refect this
#								2.Added flags to control script behavior
#								3.Made the script compliant with some best practices
#								4.Removed databases included in the replication schema
#								5.Completely rewrote the script to be a fully customizable dump and load script

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $prodserver = hostname();
my $drserver = 'CPDB4';
my $finTime = localtime();
my $stbyserver=""; 

#setting default values for parameters. All parameters are optional except for paramenter --dbname
my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0; #tells the script to skip the check prod phase (in case you want to run this on some other server for testing purposes)
my $allowparallel=0; #if 1 (one), allows multiple instances of the script to run in parallel
my $numthreads=0; #Tells the script the number of threads (stripes) to use in the dump operation
my $loadtostandby=0; #Tells the script either to load the database at standby server
my $loadtodr=0; #Tells the script either to load the database at DR server
my $database=""; #database to backup/copy/load
my $compressdump=1; #Tells the script either to compress the dump file
my $copytostandby=0; #Tells the script either to copy the files to standby server
my $copytodr=0; #Tells the script either to copy the files to the DR server
my $nodump=0; #Tells the script either to skip the dump phase (maybe you just want to copy the files to the destination servers?)
my $help;

#reading values passed
GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'allowparallel|ap=i' => \$allowparallel,
	'numthreads|t=i' => \$numthreads,
	'dbname|d=s' => \$database,
	'refreshstandby|rs=i' => \$loadtostandby,
	'refreshdr|rd=i' => \$loadtodr,
	'compressdump|c=i' => \$compressdump,
	'copytostandby|cs=i' => \$copytostandby,
	'copytodr|cd=i' => \$copytodr,
	'nodump|nd=i' => \$nodump
) or die "Usage: $0 --dbname dba --nodump 1|0 --skipcheckprod 1|0 --to rleandro --allowparallel 1|0 --numthreads [0-10] --refreshdr 1|0 --refreshstandby 1|0 --compressdump 1|0 --copytostandby 1|0 --copytodr 1|0\n";

$help = "$0 usage:

--dbname or -d = Name of the database to be dumped. Mandatory.
--nodump or -nd = Skips the dump phase. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--skipcheckprod or -s = Allows the script to run in non-production environment. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--to rleandro or -r = Mail recipient for any email alerts. Specify only the string before the @ sign. Optional. Default DBA group mail.
--allowparallel or -ap = if 1 (one), allows multiple instances of the script to run in parallel. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--numthreads or -t = Number of threads to be used during the dump/load operations. Remember! Higher values don't exactly mean faster operations. Current tested sweet spot value is 5. Optional. Default 1 (single thread).
--refreshdr or -rd = Tells the script either to load the database at DR server. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--refreshstandby or -rs = Tells the script either to load the database at standby server. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--compressdump or -c = Tells the script either to compress the dump file. Accepted values 1 or 0 (zero). Optional. Default 1.
--copytostandby or -cs = Tells the script either to copy the files to standby server. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).
--copytodr or -cd = Tells the script either to copy the files to the DR server. Accepted values 1 or 0 (zero). Optional. Default 0 (zero).\n\n";

if ($database eq "") {die "\nDatabase name cannot be blank.\n\n $help";}

if ($skipcheckprod==0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod") or die "Can't open < /opt/sap/cron_scripts/passwords/check_prod : $!";

my @prodline="";
while (<PROD>){
	@prodline = split(/\t/, $_);
	$prodline[1] =~ s/\n//g;
}

if ($prodline[1] eq "0" ){
	print "standby server \n";
	die "This is a stand by server\n"
}
}

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";

#Set starting variables
#my $currTime = localtime();
#my $startHour=sprintf('%02d',((localtime())[2]));
#my $startMin=sprintf('%02d',((localtime())[1]));

if ($allowparallel==0){
my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep dump_databases.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_databases.pl"|grep -v "less dump_databases.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}
}

#print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
$finTime = localtime();
print $finTime . "\n";

my $cmd = "";
my $cleanup=0;
my $i=0;

if ($nodump==0){
if ($numthreads == 0){
	$cmd = "dump database $database to '/opt/sap/db_backups/$database.dmp'";
	if ($compressdump==1){
	$cmd .= " with compression=100";
	}
}
if ($numthreads > 0){
	$cleanup = system("rm -rf /opt/sap/db_backups/$database*");
	if ($cleanup != 0){
		print $cleanup."\n";
		$finTime = localtime();
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during cleanup phase

$cleanup
EOF
`;
die;
}
	$cmd = "dump database $database to '/opt/sap/db_backups/$database$i.dmp'";
	for ($i=1; $i<$numthreads; $i++){
		$cmd .= "\n stripe on '/opt/sap/db_backups/$database$i.dmp'";
	}
	if ($compressdump==1){
	$cmd .= "\n with compression=100";
	}
}

print "$cmd\n";

my $sqlError="";
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
$cmd
go
exit
EOF
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";
$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during dump phase

$sqlError
EOF
`;
die;
}

$cmd =~ s/dump database (\w+) to/load database $1 from/g;
$cmd =~ s/with compression=100//g;

print "Dump finished with success. Use the command below to load the database at the destination.\n\n" . $cmd . "\n";
}

my $scpError=0;

if ($copytostandby==1){
#Copying files to standby server
$scpError=system("scp -p /opt/sap/db_backups/dba*.dmp sybase\@$stbyserver:/opt/sap/db_backups");

if ($scpError !=0){
print $scpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during copy to stdby stage

$scpError
EOF
`;
die;
}
}

if ($copytodr==1){
#Copying files to DR server
$scpError=system("scp -p /opt/sap/db_backups/dba*.dmp sybase\@$drserver:/opt/sap/db_backups");

if ($scpError!=0){
print $scpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during copy to DR stage

$scpError
EOF
`;
die;
}
}

if ($loadtostandby==1 && $nodump==0){
#Loading databases into standby server
my $load_msgs = `ssh $stbyserver /opt/sap/cron_scripts/load_databases.pl $stbyserver -d $database -r $mail -s $skipcheckprod -ap $allowparallel -lc $cmd`;

if ($load_msgs =~ /Msg/ || $load_msgs =~ /Possible Issue Found/){
print $load_msgs."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during load stage

$load_msgs
EOF
`;
}
}

if ($loadtodr==1 && $nodump==0){
#Loading databases into DR server
my $load_msgs_dr = `ssh $drserver /opt/sap/cron_scripts/load_databases.pl $drserver -d $database -r $mail -s $skipcheckprod -ap $allowparallel -lc $cmd`;

if ($load_msgs_dr =~ /Msg/ || $load_msgs_dr =~ /Possible Issue Found/){
print $load_msgs_dr."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases at $finTime during load stage

$load_msgs_dr
EOF
`;
}
}

$finTime = localtime();
print "Time Finished: $finTime\n";
