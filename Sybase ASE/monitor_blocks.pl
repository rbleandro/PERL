#!/usr/bin/perl

#Script:   This script monitors any blocking that exists for over 5 minutes
#          or any blocks caused by sleeping processes with open transactions for
#          more than 10 seconds
#Apr 05 2005	Amer Khan		Originally created
#Oct 12 2007   	Ahsan Ahmed     Modified
#Jul 11 2018   	Rafael Leandro  Formating ajustments.
#Dec 14 2018   	Rafael Leandro  Added automatic kill for phantom processes blocking for more than 10 minutes.
#Dec 08 2019   	Rafael Leandro  Reduced clutter in the code and in the final email. Script now tells how many processes are blocked in the server.
#Aug 16 2019   	Rafael Leandro  Added html support for a better look in the final email.
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

my $error = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -w900 -b<<EOF 2>&1
set nocount on
go
select s1.spid,'#',s2.spid,'#',suser_name(s1.suid) blocked_user,'#',suser_name(s2.suid) blocking_user,'#',s1.time_blocked,'#',s2.physical_io
from master..sysprocesses s1 left outer join master..sysprocesses s2 on s2.spid = s1.blocked 
where s1.status = 'lock sleep' and s1.time_blocked > 300
union
select s1.spid,'#',s2.spid,'#',suser_name(s1.suid) blocked_user,'#',suser_name(s2.suid) blocking_user,'#',s1.time_blocked,'#',s2.physical_io
from master..sysprocesses s1 left outer join master..sysprocesses s2 on s2.spid = s1.blocked
where s1.status = 'lock sleep' and s1.time_blocked > 10
and s2.status = 'recv sleep'
go
exit
EOF
`;

send_alert($error,"Msg",$noalert,$mail,$0,"get current blocks");

$error=~s/\t//g;

if ($error =~ /#/){

my @results="";
my $htmltable="<tr><td>Blocked</td><td>Blocking</td><td>blockedUser</td><td>blockingUser</td><td>timeBlocked(s)</td><td>physical_io</td></tr>";
my $td="";
my $io = 0;
my $user = "";
my $spid1 = 0;
my $spid2 = 0;
my $tblocked = 0;
my $ublocked="";
my $ublocking="";

@results = split(/\n/,$error);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>";
		if ($i ==0){$spid1=$line[0];$spid2=$line[1];$tblocked=$line[4];$ublocked=$line[2];$ublocking=$line[3];}
	}
	$htmltable.=$td;
	$htmltable.="</tr>";
	$td="";
}

my $tblockedmin=$tblocked/60;
$tblockedmin=sprintf("%.2f", $tblockedmin);

#I will only proceed if there is indeed a blocking process on the server
if ($spid2 != 0){

if ($tblocked > 45){

my $error2 = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b -w400<<EOF 2>&1
set nocount on
set proc_return_status off
go
select char(10)+"========== Here is the showplan for the blocked query ============"
go
sp_showplan $spid1
go
select char(10)+"========== Here is the showplan for the blocking query ============"
go
sp_showplan $spid2
go
exit
EOF
`;

send_alert($error2,"Msg",$noalert,$mail,$0,"get execution plans");

my $plandetails="";

@results = split(/\n/,$error2);
for (my $i=0; $i <= $#results; $i++){
	$plandetails.="<p>" . $results[$i] . "</p>";
}

if($error2 =~ /Possibly the query has not started or has finished executing/ && $tblocked > 600)
{
my $error3 = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -n -b <<EOF 2>&1
kill $spid2
go
exit
EOF
`;

send_alert($error3,"no|not|Msg",$noalert,$mail,$0,"exec sp_getRunningProcesses");

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Blocking Found!!!
Content-Type: text/html
MIME-Version: 1.0

<html> 
<head>
<title>HTML E-mail</title>
</head>
<body>

<p> User $ublocked was being blocked by $ublocking for $tblockedmin minutes. Spid $spid2 was killed automatically (phantom session with open transaction but no execution plan). Further action should not be necessary, unless there are other blocked processes listed below. </p>

<table border="1">
$htmltable
</table>
$plandetails
</body>
</html>
EOF
`;
}
else
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Blocking Found!!!
Content-Type: text/html
MIME-Version: 1.0

<html> 
<head>
<title>HTML E-mail</title>
</head>
<body>

<p> User $ublocked is being blocked by $ublocking for $tblockedmin minutes. A summary of the blocked processes followed by some information on the blocking session is shown below. </p>

<table border="1">
$htmltable
</table>
$plandetails
</body>
</html>
EOF
`;
}
}
}
}
else{
$finTime = localtime();
print "No blocked processes at $finTime\n";
}