#!/usr/bin/perl

#Script:   	This script monitor the number of sessions in the server.
#Aug 10 2019	Rafael Leandro  Created
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
my $tsession=4500;
my $sessionlowlimit=50;


GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help,
	'threshold|t=i' => \$tsession,
	'sessionlowlimit|sll=i' => \$sessionlowlimit
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
isql_r -V -S$prodserver -n -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
use dba
go
exec dba.dbo.monitor_num_connections
go
select sum(NumSessions) as NumTotalConn
from dba.dbo.monNumSession
where snapTime = (select max(snapTime) from dba.dbo.monNumSession)
go
exit
EOF
`;


send_alert($error,"no|not|Msg",$noalert,$mail,$0,"exec proc");


my $NumConnections = `. /opt/sap/SYBASE.sh
isql_r -V -w900 -S$prodserver -n -b<<EOF 2>&1
set nocount on
go
select isnull(hostname,'unknown') as hostname,'#',isnull(username,'unknown') as username,'#',isnull(NumSessions,0) as NumSessions,'#',isnull(status,'unknown') as status
from dba.dbo.monNumSession
where 1=1
and NumSessions>$sessionlowlimit
and snapTime = (select max(snapTime) from dba.dbo.monNumSession)
order by NumSessions desc
go
exit
EOF
`;

if($NumConnections =~ /Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_num_sessions script (get sessions per app phase).
$NumConnections
EOF
`;
die "Email sent (get sessions per app)";
}

$error =~ s/\s//g;

my @results="";
my $htmltable="<tr><td>hostname</td><td>username</td><td>NumSessions</td><td>status</td></tr>";
my $td="";

@results = split(/\n/,$NumConnections);
for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>";
	}
	$htmltable.=$td;
	$htmltable.="</tr>";
	$td="";
}

if ($error >= $tsession)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Number of connections alert!!!
Content-Type: text/html
MIME-Version: 1.0

<html>
<head>
<title>HTML E-mail</title>
</head>
<body>
<p>Please check. Below you can find the top session consumers in the server. Also run the query at the bottom for more details.</p>
<table border="1">
$htmltable
</table>
<p>select * from dba.dbo.monNumSession where snapTime=(select max(snapTime) from dba.dbo.monNumSession).</p>
<p>Script's name:$0. Current threshold:$tsession.</p>
</body>
</html>
EOF
`;
}
else
{
print "Number of connections is now: $error\n\n";
}
