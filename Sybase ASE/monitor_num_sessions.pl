#!/usr/bin/perl

#Script:   	This script monitor the number of sessions in the server.
#
#Author:   		Rafael Leandro
#Date			Name				Description
#---------------------------------------------------------------------------------
#Aug 10 2019	Rafael Leandro  	Created
#16/08/19   	Rafael Leandro  	Added html support for a better look in the final email.


#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";
my $tsession=4500;
my $sessionlowlimit=50;

GetOptions(
    'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'threshold|t=i' => \$tsession,
	'sessionlowlimit|sll=i' => \$sessionlowlimit
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro --threshold|t 4500 --sessionlowlimit|sll 50\n";

my $hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);

if ($skipcheckprod == 0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
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

if($error =~ /no|not|Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_num_sessions script (get current metrics phase).
$error
EOF
`;
die "Email sent";
}

my $NumConnections = `. /opt/sap/SYBASE.sh
isql -w900 -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
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
