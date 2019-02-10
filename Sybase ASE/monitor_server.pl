#!/usr/bin/perl

###################################################################################
#Script:   This script monitors IOS over 1000000                                  #
#                                                                                 #
#Author:   Rafael Bahia                                                           #
#Revision:                                                                        #
#Date		Name		Description                                       		  #
#---------------------------------------------------------------------------------#
#09/22/2018      Rafael Bahia      Created
###################################################################################

#Usage Restrictions
$hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod") or die "Can't open < /opt/sap/cron_scripts/passwords/check_prod : $!";

while (<PROD>){
	@prodline = split(/\t/, $_);
	$prodline[1] =~ s/\n//g;
}

if ($prodline[1] eq "0" ){
	print "standby server \n";
	die "This is a stand by server\n"
}

use Sys::Hostname;
$prodserver = hostname();

#Execute CPU Monitoring 

$error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on

exec dba.dbo.sp_monitor_server_custom
go
select top 1 '|',cpu_busy,'|',convert(int,str_replace(substring(connections,charindex("(", connections)+1,6),')','')) as num_logins from dba.dbo.server_health order by SnapTime desc
go
exit
EOF
`;

$NumConnections = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w200 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
select "Host","Program","User","#Sessions"
union
SELECT
	case 
	    CASE clienthostname 
            WHEN '' 
            THEN hostname 
            WHEN NULL 
            THEN hostname 
            ELSE clienthostname 
	    END
	WHEN NULL then 
	    case ipaddr 
	        when '10.4.96.82' then 'lmsdc1vaproc02' 
	        when '10.3.1.223' then 'hqvmanproc1' 
	        when '10.4.96.121' then 'lmsdc1vaproc01' 
	        when '10.3.1.37' then 'hqvdstage1' 
	        when '10.3.1.100' then 'cprhqvprtl03'
	        when '10.3.1.107' then 'cprhqvprtlstg'
	        when '10.3.1.167' then 'hqvcsw01'
	        when '10.4.96.108' then 'lmsws1'
	        when '10.4.96.43' then 'hqvlmsecomm1'
	        when '10.4.96.103' then 'lmscrystrpt1'
	        
	    end 
	    else CASE clienthostname 
            WHEN '' 
            THEN hostname 
            WHEN NULL 
            THEN hostname 
            ELSE clienthostname 
	    END
	end 'host',

	CASE clientapplname 
		WHEN '' 
		THEN program_name 
		WHEN NULL 
		THEN program_name 
		ELSE clientapplname 
	END 'program',
	SUSER_NAME(suid),
	convert(varchar(50),count(spid)) as 'NumSessions'
FROM master.dbo.sysprocesses sp
where 1=1
and DB_NAME(dbid) not in  ('tempdb3')
and status not in ('background')
and cmd not in ('HK WASH','HK GC','HK CHORES','NETWORK HANDLER','MEMORY TUNE','DEADLOCK TUNE','SHUTDOWN HANDLER','KPP HANDLER','ASTC HANDLER','CHECKPOINT SLEEP','PORT MANAGER','AUDIT PROCESS','CHKPOINT WRKR','LICENSE HEARTBEAT','JOB SCHEDULER')
and status <> 'recv sleep'
and blocked not in (select distinct spid from master..syslocks where spid not in (select spid from master..sysprocesses))
group by CASE clientapplname 
		WHEN '' 
		THEN program_name 
		WHEN NULL 
		THEN program_name 
		ELSE clientapplname 
	END, SUSER_NAME(suid)
	,case 
	    CASE clienthostname 
            WHEN '' 
            THEN hostname 
            WHEN NULL 
            THEN hostname 
            ELSE clienthostname 
	    END
	WHEN NULL then 
	    case ipaddr 
	        when '10.4.96.82' then 'lmsdc1vaproc02' 
	        when '10.3.1.223' then 'hqvmanproc1' 
	        when '10.4.96.121' then 'lmsdc1vaproc01' 
	        when '10.3.1.37' then 'hqvdstage1' 
	        when '10.3.1.100' then 'cprhqvprtl03'
	        when '10.3.1.107' then 'cprhqvprtlstg'
	        when '10.3.1.167' then 'hqvcsw01'
	        when '10.4.96.108' then 'lmsws1'
	        when '10.4.96.43' then 'hqvlmsecomm1'
	        when '10.4.96.103' then 'lmscrystrpt1'
	        
	    end 
	    else CASE clienthostname 
            WHEN '' 
            THEN hostname 
            WHEN NULL 
            THEN hostname 
            ELSE clienthostname 
	    END
	end
go
exit
EOF
`;

#print $error;
#CANPARDatabaseAdministratorsStaffList
#rleandro

if($NumConnections =~ /no|not|Msg/)
{	
print $NumConnections;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_server script. 
$NumConnections
EOF
`;
die "Email sent";
}

if($error =~ /no|not|Msg/)
{	
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - monitor_server script. 
$error
EOF
`;
die "Email sent";
}

$error =~ s/\s//g;
$error =~ s/\t//g;
@list = split(/\|/,$error);
$cpu = $list[1];
$num_logins = $list[2];

#print $cpu;
#print $num_logins;

if ($cpu > 85 && $hour > 6 && $hour < 23)
{
#print "sending";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Server load alert!!!
CPU now (%): $cpu. Please check. Number of logins is: $num_logins. Below is a summary of active applications right now. Execute the queries at the end to see server trends and historical data.

$NumConnections

select top 100 * from dba.dbo.dba_mon_processes where snapTime=(select max(snapTime) from dba.dbo.dba_mon_processes) order by program
select top 10 * from dba.dbo.server_health order by SnapTime desc
EOF
`;
}
else
{
print "CPU is now(%): $cpu
";
}

#if ($num_logins > 13000 && $hour > 6 && $hour < 23)
#{
##print "sending";
#`/usr/sbin/sendmail -t -i <<EOF
#To: CANPARDatabaseAdministratorsStaffList\@canpar.com
#Subject: High number of user connections!!!
#Number of logins is: $num_logins. CPU load is at $cpu.. Below is a summary of active applications right now. Execute the queries at the end to see server trends and historical data.
#
#$NumConnections
#
#select top 100 * from dba.dbo.dba_mon_processes where snapTime=(select max(snapTime) from dba.dbo.dba_mon_processes) order by program
#select top 10 * from dba.dbo.server_health order by SnapTime desc
#EOF
#`;
#}
#else
#{
#print "Number of users is now: $num_logins
#";
#}

