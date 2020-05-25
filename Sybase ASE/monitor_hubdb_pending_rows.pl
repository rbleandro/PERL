#!/usr/bin/perl

#Script:   	This script checks for long running transactions that are preventing database log flush
#Author:   	Rafael Leandro
#Revision:
#Date			Name				Description
#---------------------------------------------------------------------------------
#Aug 18 2019	Rafael Leandro		Originally created

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $mail = 'CANPARDatabaseAdministratorsStaffList@canpar.com; jpepper@canpar.com; Kenny.Ip@loomis-express.com';
my $skipcheckprod=0;
my $finTime = localtime();
my @prodline="";

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

my $error = `. /opt/sap/SYBASE.sh
isql -Usybmaint -w900 -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b <<EOF 2>&1
set nocount on
go
select status,'#', count(*) as waiting_events,'#', min(inserted_on) as oldest_inserted_on,'#', min(scanned_on) as oldest_scanned_on
from hub_db..event 
where processed = 0 and inserted_on < dateadd(minute, -15, getdate())
group by status
go
EOF
`;

if($error =~ /Msg/)
{
print $error . "\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $mail
Subject: ERROR - monitor_long_running_transactions.pl script.
$error
EOF
`;
$finTime = localtime();
print $finTime . "\n";
die "Email sent\n";
}

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