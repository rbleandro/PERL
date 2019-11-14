#!/usr/bin/perl

#Script:   This script monitors any blocking that exists for over 5 minutes
#          or any blocks caused by sleeping processes with open transactions for
#          more than 10 seconds
#Author:   Amer Khan
#Date		Name			Description
#05/04/05	Amer Khan		Originally created
#10/12/07   Ahsan Ahmed     Modified
#11/07/18   Rafael Leandro  Formating ajustments.
#14/12/18   Rafael Leandro  Added automatic kill for phantom processes blocking for more than 10 minutes.
#12/08/19   Rafael Leandro  Reduced clutter in the code and in the final email. Script now tells how many processes are blocked in the server.
#16/08/19   Rafael Leandro  Added html support for a better look in the final email.

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod 0 --to rleandro\n";

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

#Execute monitor now

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -b<<EOF 2>&1
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

if($error =~ /Msg/)
{
print $error;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_blocks script (get current blocks phase).
$error
EOF
`;
$finTime = localtime();
print $finTime;
die "Email sent";
}

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

if ($tblocked > 10){

my $error2 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b -w400<<EOF 2>&1
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

if($error2 =~ /Msg/)
{
print $error2;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_blocks script(get execution plans phase).
$error2
EOF
`;
$finTime = localtime();
print $finTime;
die "Email sent";
}

my $plandetails="";

@results = split(/\n/,$error2);
for (my $i=0; $i <= $#results; $i++){
	$plandetails.="<p>" . $results[$i] . "</p>";
}

if($error2 =~ /Possibly the query has not started or has finished executing/ && $tblocked > 600)
{
my $error3 = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
kill $spid2
go
exit
EOF
`;

if($error3 =~ /no|not|Msg/)
{
print $error3;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_blocks script(kill phase).
$error3
EOF
`;
$finTime = localtime();
print $finTime;
die "Email sent";
}

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