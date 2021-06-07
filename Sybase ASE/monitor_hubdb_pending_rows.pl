#!/usr/bin/perl

#Script:   		This script checks for long running transactions that are preventing database log flush
#Aug 18 2019	Rafael Leandro	Originally created
#May 10 2021	Rafael Leandro 	Added several features and enabled kerberos auth

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = "";
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";
my $finalmail="";

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

if ($mail){
	$finalmail .= $mail . "\@canpar.com";
	#print "$finalmail\n";
}else{
	#print "no email found\n";
	#exit;
	$mail = "CANPARDatabaseAdministratorsStaffList\@canpar.com; jpepper\@canpar.com; Kenny.Ip\@loomis-express.com";
}

$currTime = localtime();
print "StartTime: $currTime\n";

my $error = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -w900 -n -b <<EOF 2>&1
set nocount on
go
select status,'#', count(*) as waiting_events,'#', min(inserted_on) as oldest_inserted_on,'#', min(scanned_on) as oldest_scanned_on
from hub_db..event 
where processed = 0 and inserted_on < dateadd(minute, -15, getdate())
group by status
go
EOF
`;

send_alert($error,"Msg",$noalert,$mail,$0,"get pending rows");

$error =~ s/\t//g;

if ($error =~ /#/){

my $htmlmail="<html>
<head>
<title>HTML E-mail</title>
</head>
<body>
<p>Check below the list of records pending processing in hub_db.</p>

<table border=\"1\">
<tr><td>status</td><td>waiting_events</td><td>oldest_inserted_on</td><td>oldest_scanned_on</td></tr>\n";
my @results="";
my $htmltable="";
my $td="";
my $spid = 0;

@results = split(/\n/,$error);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable . "</table></body></html>\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail
Subject: Long running transactions alert!!!
Content-Type: text/html
MIME-Version: 1.0

$htmlmail

Script name:$0.

EOF
`;
}
else{
$finTime = localtime();
print "No pending rows detected at $finTime\n";
}