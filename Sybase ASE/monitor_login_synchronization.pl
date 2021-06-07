#!/usr/bin/perl

#Script:   		This script will check if all the logins and roles are properly created on the secondary servers
#Dec 18 2019	Rafael Leandro		Originally created
#May 10 2021	Rafael Leandro 	Added several features and enabled kerberos auth

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

my $countprod = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select count(*) from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
and sr.name not like 'replication%'
go
EOF
`;

if($countprod =~ /no|not|Msg/)
{
print $countprod;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_login_synchronization script.
$countprod
EOF
`;
die "Email sent";
}

my $countstdby = `. /opt/sap/SYBASE.sh
isql_r -V -SCPDB2 -n -b <<EOF 2>&1
set nocount on
go
select count(*) from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
and sr.name not like 'replication%'
go
EOF
`;

if($countstdby =~ /no|not|Msg/)
{
print $countstdby;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_login_synchronization script.
$countstdby
EOF
`;
die "Email sent";
}

#my $countdr = `. /opt/sap/SYBASE.sh
#isql_r -V -SCPDB4 -n -b <<EOF 2>&1
#set nocount on
#go
#select count(*) from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
#and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
#and sr.name not like 'replication%'
#go
#EOF
#`;
#
#if($countdr =~ /no|not|Msg/)
#{
#print $countdr;
#`/usr/sbin/sendmail -t -i <<EOF
#To: $mail\@canpar.com
#Subject: ERROR - monitor_login_synchronization script.
#$countdr
#EOF
#`;
#die "Email sent";
#}

$countprod =~ s/\s//g;
$countprod =~ s/\t//g;
$countstdby =~ s/\s//g;
$countstdby =~ s/\t//g;
#$countdr =~ s/\s//g;
#$countdr =~ s/\t//g;


print $countprod."\n";

if ($countprod != $countstdby)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Logins not synchronized on Standby server.

The logins or role assignments are not synchronized between Production and Standby. Please check asap. Suggestion: run the query below and compare what is missing using a diff tool like winmerge.

select --sl.name, sr.name 
"EXEC sp_role 'grant','"+sr.name+"','"+sl.name+"'
go
EXEC sp_modifylogin "+sl.name+",'add default role',"+sr.name+" 
go"
from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
and sr.name not like 'replication%'
order by sl.name
go

Current production server is: $prodserver. This script's name is: $0.

EOF
`;
}

#if ($countprod != $countdr)
#{
#`/usr/sbin/sendmail -t -i <<EOF
#To: $mail\@canpar.com
#Subject: Logins not synchronized on DR server.
#
#The logins or role assignments are not synchronized between Production and DR. Please check asap. Suggestion: run the query below and compare what is missing using a diff tool like winmerge.
#
#select --sl.name, sr.name 
#"EXEC sp_role 'grant','"+sr.name+"','"+sl.name+"'
#go
#EXEC sp_modifylogin "+sl.name+",'add default role',"+sr.name+" 
#go"
#from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
#and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
#and sr.name not like 'replication%'
#order by sl.name
#go
#
#Current production server is: $prodserver. This script's name is: $0.
#
#EOF
#`;
#}