#!/usr/bin/perl

#Script:   		Generates the full schema of all databases in the server. Also scripts some important server properties
#Dec 18 2019	Rafael Leandro		Originally created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use lib ('/opt/sap/cron_scripts/lib');
use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my $prodserver = hostname();
my $help=0;
my $noalert=0;
my $nodb=0;
my $nosrv=0;
my $curdb="";
my $curobj="";
my $defncopy_r ="";
my $nogitversion=0;
my $git="";
my $repopath="/opt/sap/db_backups/canpar-install-scripts";
my $git_path="$repopath/.git";
my $objname="";
my $objtypepath="";
my $scriptaction=2047;
my $bcpError="";
my @results="";
my @dbobjects="";
my @prodline="";


if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'repopath|rp=s' => \$repopath,
	'noalert' => \$noalert,
	'nogitversion' => \$nogitversion,
	'scriptaction|sa=i' => \$scriptaction,
	'help|h' => \$help
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --nodb --nosrv --dbserver|ds CPSYBTEST --noalert --nogitversion --scriptaction 30 --help\n";

if ($help){
die "Usage: $0 --skipcheckprod|-s 0 --to|-r rleandro --dbserver|-ds CPSYBTEST --noalert --nogitversion --help|-h\n
--skipcheckprod: skips the server check, allowing you to run the program on servers that are not production
--to: changes the destination of the alerts to the email specified. Type in only the text before the @ sign. ie: if your email is xyz\@xpto.com, type only xyz for this parameter
--noalert: instructs the script to skip sending mail alerts
--nogitversion: skips the git versioning of any added/altered files
--help: shows this help

--scriptaction: This parameter is bitwise. Add the values for each option below to tell the program what to script.

generate separate scripts for all database procedures = 1
generate separate scripts for all database triggers = 2 
generate separate scripts for all database tables = 4
generate separate scripts for all database views = 8
generate separate scripts for all database user defined data types = 16
generate separate scripts for all database scalar functions = 32
generate separate scripts for all database groups = 64 (NOT WORKING ATM)
generate separate scripts for system tables = 128\n";
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

if (-e $git_path){
	print "Repository clone found. Proceeding...\n";
}else{
	die "Could not find git control file for the remote repo. Clone the repo using the git clone command."
}

print "Starting generation at $finTime\n";

if ($scriptaction & 128){
	
$objtypepath = "$repopath/$prodserver/SystemTables";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
	#system("mkdir $objtypepath/");
}
else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}

$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysdatabases out $objtypepath/sysdatabases.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysdevices out $objtypepath/sysdevices.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysusages out $objtypepath/sysusages.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysloginroles out $objtypepath/sysloginroles.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysconfigures out $objtypepath/sysconfigures.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..syscharsets out $objtypepath/syscharsets.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysservers out $objtypepath/sysservers.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysremotelogins out $objtypepath/sysremotelogins.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysresourcelimits out $objtypepath/sysresourcelimits.csv -c -t"," -S $prodserver -V`;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..systimeranges out $objtypepath/systimeranges.csv -c -t"," -S $prodserver -V`;

send_alert($bcpError,"Msg|Error|error",$noalert,$mail,$0,"bcp_r system tables");
}

my $dbname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
select name from master..sysdatabases
where 1=1
and name not in ('master','model','sybmgmtdb','sybsecurity','sybsystemdb','sybsystemprocs')
and name not like 'tempdb%'
--and name ='canada_post'
order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get database list ");

@results = split(/\n/,$dbname);

for (my $i=0; $i <= $#results; $i++){
$curdb=$results[$i];
$curdb=~s/^\s+|\s+$//g;

if (not -d "$repopath/$prodserver/$curdb") {
	#print "Database directory found. Proceeding...\n$objtypepath\n";
	system("mkdir $repopath/$prodserver/$curdb/");
}
#else{
#	print "$repopath/$prodserver/$curdb\n";
#    system("mkdir $repopath/$prodserver/$curdb/");
#}


if ($scriptaction & 1){
$objtypepath = "$repopath/$prodserver/$curdb/Proc";
$defncopy_r="";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects
where type='P'
--and name ='JCC_CPost_table'
order by name
go
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get procedures ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Proc/$curobj.sql $curdb dbo.$curobj`;
}
}

if ($scriptaction & 2){
$objtypepath = "$repopath/$prodserver/$curdb/Trigger";
$defncopy_r="";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects where type='TR' order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get triggers");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Trigger/$curobj.sql $curdb dbo.$curobj`;
}
}

if ($scriptaction & 4){
$objtypepath = "$repopath/$prodserver/$curdb/Table";
$defncopy_r="";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects where type='U' order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get tables ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Table/$curobj.sql $curdb dbo.$curobj`;
}
}

if ($scriptaction & 8){
$objtypepath = "$repopath/$prodserver/$curdb/View";
$defncopy_r="";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects where type='V' order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get views ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/View/$curobj.sql $curdb dbo.$curobj`;
}
}

if ($scriptaction & 16){
$defncopy_r="";	
$objtypepath = "$repopath/$prodserver/$curdb/Datatype";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects where type='UDD' order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"user datatypes ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Datatype/$curobj.sql $curdb dbo.$curobj`;
}
}

if ($scriptaction & 32){
$objtypepath = "$repopath/$prodserver/$curdb/Function";
$defncopy_r="";

if (-d "$objtypepath") {
	print "Object directory found. Proceeding...\n$objtypepath\n";
}else{
	print "$objtypepath\n";
    system("mkdir $objtypepath/");
}	
	
$objname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
use $curdb
go
select name from sysobjects where type='SF' order by name
go
exit
EOF
`;

send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get scalar functions ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$defncopy_r .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Function/$curobj.sql $curdb dbo.$curobj`;
}
}

#if ($scriptaction & 64){
#$objtypepath = "$repopath/$prodserver/$curdb/Group";
#$defncopy_r="";
#
#if (-d "$objtypepath") {
#	print "Object directory found. Proceeding...\n$objtypepath\n";
#}else{
#	print "$objtypepath\n";
#    system("mkdir $objtypepath/");
#}
#
#$objname = `. /opt/sap/SYBASE.sh
#isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
#set nocount on
#go
#use $curdb
#go
#SELECT
#name FROM
#dbo.sysusers WHERE
#(uid = gid AND
#environ IS NOT NULL)
#order by name
#go
#exit
#EOF
#`;
#
#send_alert($defncopy_r,"no|not|Msg",$noalert,$mail,$0,"get groups ");
#
#@dbobjects = split(/\n/,$objname);
#
#for (my $j=0; $j <= $#dbobjects; $j++){
#$curobj=$dbobjects[$j];
#$curobj=~s/^\s+|\s+$//g;
#
#$defncopy_r .= `. /opt/sap/SYBASE.sh
#\$SYBASE/\$SYBASE_OCS/bin/defncopy_r -V -S$prodserver out $repopath/$prodserver/$curdb/Group/$curobj.sql $curdb $curobj`;
#}
#}
}

send_alert($defncopy_r,"Error|error|Invalid|invalid|Inconsistent|inconsistent|No such file|ERROR",$noalert,$mail,$0,"defncopy_r execution");

if ($nogitversion==0){
$finTime=localtime();
$git=`cd $repopath
git pull -q origin main
git add .
git commit -q -m "Versioning database and server deploy scripts for $prodserver at $finTime"
git push -q origin main
`;
}

if(($git =~ /failed|error/) || ($git =~ /No such file or directory/))
{
$finTime=localtime();
print $git;
if ($noalert == 0){
$finTime=localtime();
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - maint_generate_db_schema script at git versioning execution phase.
$git
EOF
`;
die "Email sent at $finTime";
}
die "Error occured while processing the git versioning sent at $finTime";
}


$finTime=localtime();
print "Ending generation at $finTime\n";