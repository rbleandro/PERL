#!/usr/bin/perl

#Script:   		Generates the full schema of all databases in the server. Also scripts some important server properties
#Dec 18 2019	Rafael Leandro		Originally created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

require "/opt/sap/cron_scripts/lib/libfunc.pl";

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
my $ddlgen ="";
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

generate one script for configured server caches = 1
generate one script for configured server devices = 2
generate one script for configured server engine classes = 4
generate one script for configured server roles = 8
generate one script for configured remote servers = 16
generate all database schema in one big script = 32
generate separate scripts for all database procedures = 64
generate separate scripts for all database triggers = 128 
generate separate scripts for all database tables = 256
generate separate scripts for all database views = 512
generate separate scripts for all database user defined data types = 1024
generate separate scripts for all database scalar functions = 2048
generate separate scripts for all database groups = 4096
generate separate scripts for system tables = 8192\n";
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

if ($scriptaction & 8192){
	
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
\$SYBASE/OCS-16_0/bin/bcp_r master..sysdatabases out $objtypepath/sysdatabases.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysdevices out $objtypepath/sysdevices.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysusages out $objtypepath/sysusages.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysloginroles out $objtypepath/sysloginroles.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysconfigures out $objtypepath/sysconfigures.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..syscharsets out $objtypepath/syscharsets.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysservers out $objtypepath/sysservers.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysremotelogins out $objtypepath/sysremotelogins.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..sysresourcelimits out $objtypepath/sysresourcelimits.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;
$bcpError .=`. /opt/sap/SYBASE.sh
\$SYBASE/OCS-16_0/bin/bcp_r master..systimeranges out $objtypepath/systimeranges.csv -c -t"," -S $prodserver -V -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\``;

send_alert($bcpError,"Msg|Error|error",$noalert,$mail,$0,"bcp system tables");
}

my $cmd = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
grant role sa_role to cronmpr
go
exit
EOF
`;

send_alert($cmd,"no|not|Msg",$noalert,$mail,$0,"grant sa_role");

if ($scriptaction & 1){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TC -N% -S$prodserver -O$repopath/$prodserver/$prodserver\_cache_install.sql << END 
\$PSWD 
END`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"ddlgen caches");
}

if ($scriptaction & 2){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TDBD -N% -S$prodserver -O$repopath/$prodserver/$prodserver\_devices_install.sql << END 
\$PSWD 
END`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"ddlgen devices");
}

if ($scriptaction & 4){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TEC -N% -S$prodserver -O$repopath/$prodserver/$prodserver\_engineclass_install.sql << END 
\$PSWD 
END`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"ddlgen engines");
}

if ($scriptaction & 8){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TRO -N% -S$prodserver -O$repopath/$prodserver/$prodserver\_role_install.sql << END 
\$PSWD 
END`;


send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"ddlgen roles");

}

if ($scriptaction & 16){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TRS -N% -S$prodserver -O$repopath/$prodserver/$prodserver\_remoteserver_install.sql << END 
\$PSWD 
END`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"ddlgen remote servers");

}

my $dbname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
select name from master..sysdatabases
where 1=1
and name not in ('master','model','sybmgmtdb','sybsecurity','sybsystemdb','sybsystemprocs')
and name not like 'tempdb%'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get database list ");


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


if ($scriptaction & 32){#full db schema
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -TDB -N$curdb -S$prodserver -O$repopath/$prodserver/$prodserver\_$curdb\_schema_install.sql << END 
\$PSWD 
END`;
}

if ($scriptaction & 64){
$objtypepath = "$repopath/$prodserver/$curdb/Proc";
$ddlgen="";

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
select name from sysobjects where type='P'
go
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get procedures ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TP -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Proc/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 128){
$objtypepath = "$repopath/$prodserver/$curdb/Trigger";
$ddlgen="";

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
select name from sysobjects where type='TR'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get triggers");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TTR -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Trigger/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 256){
$objtypepath = "$repopath/$prodserver/$curdb/Table";
$ddlgen="";

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
select name from sysobjects where type='U'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get tables ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TU -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Table/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 512){
$objtypepath = "$repopath/$prodserver/$curdb/View";
$ddlgen="";

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
select name from sysobjects where type='V'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get views ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TV -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/View/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 1024){
$ddlgen="";	
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
select name from sysobjects where type='UDD'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"user datatypes ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TUDD -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Datatype/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 2048){
$objtypepath = "$repopath/$prodserver/$curdb/Function";
$ddlgen="";

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
select name from sysobjects where type='SF'
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get scalar functions ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TF -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Function/$curobj.sql << END 
\$PSWD 
END`;
}
}

if ($scriptaction & 4096){
$objtypepath = "$repopath/$prodserver/$curdb/Group";
$ddlgen="";

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
SELECT
name FROM
dbo.sysusers WHERE
(uid = gid AND
environ IS NOT NULL)
go
exit
EOF
`;

send_alert($ddlgen,"no|not|Msg",$noalert,$mail,$0,"get groups ");

@dbobjects = split(/\n/,$objname);

for (my $j=0; $j <= $#dbobjects; $j++){
$curobj=$dbobjects[$j];
$curobj=~s/^\s+|\s+$//g;

$ddlgen .= `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -Ppwd -D$curdb -TGRP -N$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Group/$curobj.sql << END 
\$PSWD 
END`;
}
}
}

send_alert($ddlgen,"Error|error|Invalid|invalid|Inconsistent|inconsistent|No such file",$noalert,$mail,$0,"ddlgen execution");

$cmd = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
revoke role sa_role from cronmpr
go
exit
EOF
`;

send_alert($cmd,"no|not|Msg",$noalert,$mail,$0,"revoke sa_role");

if ($nogitversion==0){
$finTime=localtime();
$git=`cd $repopath
git pull origin main
git add .
git commit -m "Versioning database and server deploy scripts for $prodserver at $finTime"
git push origin main`;
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
die "Email sent at $finTime";
}

$finTime=localtime();
print "Ending generation at $finTime\n";