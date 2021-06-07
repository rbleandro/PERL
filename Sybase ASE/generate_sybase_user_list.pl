#!/usr/bin/perl

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = "servicedesk\@canpar.com, audit.report\@loomis\-express.com";
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";
my @results="";
my $htmltable="";
my $td="";
my $finalmail="";
my $htmlmail="";

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

#this needs a more elegant solution...
if ($mail =~ /servicedesk/){
	$finalmail = $mail;
	#print "$finalmail\n";
}else{
	$finalmail = "$mail\@canpar.com";
}

$currTime = localtime();
print "StartTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
set nocount on
go
select name,'#', CASE when locksuid is null then 'Yes' else 'No' end as Enabled
from master..syslogins
where suid > 3
order by name
go
exit
EOF
`;

send_alert($sqlError,"Msg|invalid|Invalid",$noalert,$mail,$0,"exec proc");

$sqlError=~s/\t//g;

$htmlmail="<html>
<head>
<style>
table {
  border-collapse: collapse;
}
table, th, td {
  border: 1px solid black;
}
td {
  padding: 5px;
  text-align: left;
}
th {
  background-color: #99bfac;
  color: white;
  padding: 5px;
  text-align: center;
}
</style>
</head>
<body>
<p>Please assign to Adela for her review.</p>
<table border=\"1\">
<tr><th>User Name</th><th>Locked Status</th></tr>\n";

@results = split(/\n/,$sqlError);

for (my $i=0; $i <= $#results; $i++){
	my @line = split(/#/,$results[$i]);
	$htmltable.="<tr>\n";
	for (my $l=0; $l <= $#line; $l++){
		$line[$l]=~s/\s//g;
		$td.="<td>" . $line[$l] . "</td>\n";
	}
	$htmltable.=$td;
	$htmltable.="</tr>\n";
	$td="";
}

$htmlmail .= $htmltable;
$htmlmail .= "</table>\n";
$htmlmail .= "</body></html>\n";

if ($noalert == 0){

`/usr/sbin/sendmail -t -i<<EOF
To: $finalmail
Subject: Sybase Disabled Users List Created on $finTime
Content-Type: text/html
MIME-Version: 1.0

$htmlmail
EOF
`;

}else{
	print "$htmlmail\n\n";
}

$currTime = localtime();
print "Process FinTime: $currTime\n";

