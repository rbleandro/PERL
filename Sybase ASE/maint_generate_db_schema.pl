#!/usr/bin/perl

#Script:   		Generates the full schema of all databases in the server. Also scripts some important server properties
#Dec 18 2019	Rafael Leandro		Originally created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

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
my $scriptaction=0;
my $bcpError="";
my @results="";
my @dbobjects="";
my @prodline="";
my $checkProcessRunning=1;
my $database = "";

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
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'database|d=s' => \$database,
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

showDefaultHelp($help,$0);
checkProcessByName($checkProcessRunning,$0);
isProd($skipcheckprod);

if (-e $git_path){
	print "Repository clone found. Proceeding...\n";
}else{
	die "Could not find git control file for the remote repo. Clone the repo using the git clone command."
}

#my $PSWD = `. /opt/sap/SYBASE.sh
#echo \$PSWD
#`;
#die ($PSWD);

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

send_alert($bcpError,"Msg|does not exist",$noalert,$mail,$0,"bcp system tables");
}

my $cmd = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b -n<<EOF 2>&1
set nocount on
go
exec sp_locklogin cronmpr,'unlock'
go
grant role sa_role to cronmpr
go
grant role sso_role to cronmpr
go
exit
EOF
`;

send_alert($cmd,"Msg",$noalert,$mail,$0,"grant cronmpr permissions");

if ($scriptaction & 1){
$ddlgen = `. \$SYBASE/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TC -N% -S$prodserver -O$repopath/$prodserver/cache_install.sql<<END 2>&1
\$PSWD
END
`;

send_alert($ddlgen,"no|not|Msg|Unable",$noalert,$mail,$0,"ddlgen caches");
}

if ($scriptaction & 2){
$ddlgen = `. \$SYBASE/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TDBD -N% -S$prodserver -O$repopath/$prodserver/devices_install.sql<<END 2>&1 
\$PSWD
END
`;

send_alert($ddlgen,"no|not|Msg|Unable",$noalert,$mail,$0,"ddlgen devices");
}

if ($scriptaction & 4){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TEC -N% -S$prodserver -O$repopath/$prodserver/engineclass_install.sql<<END 2>&1
\$PSWD
END
`;

send_alert($ddlgen,"no|not|Msg|Unable",$noalert,$mail,$0,"ddlgen engines");
}

if ($scriptaction & 8){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TRO -N% -S$prodserver -O$repopath/$prodserver/role_install.sql<<END 2>&1
\$PSWD
END
`;


send_alert($ddlgen,"no|not|Msg|Unable",$noalert,$mail,$0,"ddlgen roles");

}

if ($scriptaction & 16){
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TRS -N% -S$prodserver -O$repopath/$prodserver/remoteserver_install.sql<<END 2>&1
\$PSWD
END
`;

send_alert($ddlgen,"no|not|Msg|Unable",$noalert,$mail,$0,"ddlgen remote servers");

}

my $dbname = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
select name from master..sysdatabases
where 1=1
and name not in ('master','model','sybmgmtdb','sybsecurity','sybsystemdb','sybsystemprocs')
and name not like 'tempdb%'
and name >= '$database'
go
exit
EOF
`;

#die($dbname);

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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TDB -N$curdb -S$prodserver -O$repopath/$prodserver/$prodserver/$curdb/full_schema_install.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen full schema");

if ($scriptaction & 16384){#database users
$ddlgen = `. /opt/sap/SYBASE.sh
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -TUSR -N$curdb.% -S$prodserver -O$repopath/$prodserver/$curdb/user_install.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen users");

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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TP -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Proc/$curobj.sql<<END 2>&1
\$PSWD
END
`;

send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen proc");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TTR -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Trigger/$curobj.sql<<END 2>&1
\$PSWD
END
`;

send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen Trigger");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TU -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Table/$curobj.sql<<END 2>&1
\$PSWD
END
`;
}

send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen Table");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TV -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/View/$curobj.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen View");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TUDD -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Datatype/$curobj.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen Datatype");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TF -Ndbo.$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Function/$curobj.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen functions");
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
\$SYBASE/\$SYBASE_ASE/bin/ddlgen -Ucronmpr -D$curdb -TGRP -N$curobj -S$prodserver -O$repopath/$prodserver/$curdb/Group/$curobj.sql<<END 2>&1
\$PSWD
END
`;
}
send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen groups");
}
}

send_alert($ddlgen,"does not exist|Invalid|invalid|Inconsistent|inconsistent|No such file|Unable",$noalert,$mail,$0,"ddlgen execution");

$cmd = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -b<<EOF 2>&1
set nocount on
go
revoke role sa_role from cronmpr
go
revoke role sso_role from cronmpr
go
exec sp_locklogin cronmpr,'lock'
go
exit
EOF
`;

send_alert($cmd,"no|not|Msg",$noalert,$mail,$0,"revoke cronmpr permissions");

if ($nogitversion==0){
$finTime=localtime();
$git=`cd $repopath
git pull -q origin main
git add .
git commit -q -m "Versioning database and server deploy scripts for $prodserver at $finTime"
git push -q origin main
`;
}

send_alert($git,"failed|error|No such file or directory",$noalert,$mail,$0,"git versioning");

$finTime=localtime();
print "Ending generation at $finTime\n";