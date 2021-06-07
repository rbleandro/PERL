#!/usr/bin/perl
# Pass in command line parameter "--test" to perform an email test.

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

my $default_warning_level=85;

sub check_free_space {
my $out = "";
my ($dir, $warning_level) = @_;
# set warning level to default if not specified
if(!defined($warning_level)) {
	$warning_level = $default_warning_level;
}

my $res=`df $dir | tail -n 1`;
my @vec = split(/\s+/,$res);
my $dev=$vec[0];
my $total=$vec[1];
my $used=$vec[2];
my $avail=$vec[3];
my $use_perc=$vec[4];

my $up = $used / $total * 100;

# compare
if (($up > $warning_level) || (defined($ARGV[0]) && ($ARGV[0] eq "--test"))) {
	$out .= sprintf("WARNING Low Disk Space on $dir : %0.2f%% of space used on the device. \n\n Check the /tmp, /var/log and /opt/sap folders as they are generally the ones that give more trouble. If you need to tweak this alert, change the script /opt/sap/cron_scripts/monitor-disk-space.pl. \n",$use_perc);
}

if($out ne "") {
#print $out;
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject:   $prodserver Low Disk Space

$out
EOF
`;
}
}

check_free_space("/", 80);
check_free_space("/opt/sap/db_backups", 90);