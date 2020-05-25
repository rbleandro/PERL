#!/usr/bin/perl

#Script:   		This script will check if all the logins and roles are properly created on the secondary servers
#Author:   		Rafael Leandro
#Revision:
#Date			Name				Description
#-----------------------------------------------------------------------------------------
#Dec 18 2019	Rafael Leandro		Originally created

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $error="";

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

my $countprod = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -SCPDB1 -n -b <<EOF 2>&1
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
Subject: ERROR - monitor_phantom_locks script.
$countprod
EOF
`;
die "Email sent";
}

my $countstdby = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -SCPDB2 -n -b <<EOF 2>&1
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
Subject: ERROR - monitor_phantom_locks script.
$countstdby
EOF
`;
die "Email sent";
}

my $countdr = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -SCPDB4 -n -b <<EOF 2>&1
set nocount on
go
select count(*) from master..sysloginroles slr, master..syslogins sl, master..syssrvroles sr where slr.suid = sl.suid and slr.srid = sr.srid 
and sr.name not in ('sa_role','sso_role','oper_role','sybase_ts_role','replication_role','mon_role','js_admin_role','js_user_role','sa_serverprivs_role')
and sr.name not like 'replication%'
go
EOF
`;

if($countdr =~ /no|not|Msg/)
{
print $countdr;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_phantom_locks script.
$countdr
EOF
`;
die "Email sent";
}

$countprod =~ s/\s//g;
$countprod =~ s/\t//g;
$countstdby =~ s/\s//g;
$countstdby =~ s/\t//g;
$countdr =~ s/\s//g;
$countdr =~ s/\t//g;


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

if ($countprod != $countdr)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Logins not synchronized on DR server.

The logins or role assignments are not synchronized between Production and DR. Please check asap. Suggestion: run the query below and compare what is missing using a diff tool like winmerge.

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