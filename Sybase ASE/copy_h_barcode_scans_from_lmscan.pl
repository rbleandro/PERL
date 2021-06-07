#!/usr/bin/perl -w

use strict;
use warnings;
use Sys::Hostname;

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

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
set clientapplname 'copy_h_barcode'
go
use cpscan
go
exec copy_h_barcode_scans_from_lmscan null,null
go
exit
EOF
`;
print $sqlError."\n";

if ($sqlError !~ /Attempt to insert duplicate key row in object 'PictureDataCapture'/i){
        send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");
}
$currTime = localtime();
print "copy_h_barcode_scans_from_lmscan FinTime: $currTime\n";

