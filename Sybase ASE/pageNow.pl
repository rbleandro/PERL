#!/usr/bin/perl -w

#Script:   This script sends out pages when thresholds of segments in database
#          are reached. This script is executed from within threshold stored
#          procedure and should not be used individually.
#
#08/27/04       Amer Khan       Originally created
#Mar 30 2019	Rafael Leandro	Changed the script to automatically add extra space as a precaution
#Apr 03 2019	Rafael Leandro	Implemented better error handling and mail messaging
#May 15 2019	Rafael Leandro	Changed the mail client to sendmail for faster mailing. Changed the script so it can run properly on secondary servers to report low space and add more space when necessary.
#May 15 2019	Rafael Leandro	Now the script will send an email if the script is invoked with the wrong parameter order.
#May 15 2019	Rafael Leandro	Now the script is taking into consideration all available temporary databases existing on the server (named with the tempdb* prefix) and not only tempdb.
#May 29 2019	Rafael Leandro	Final message regarding the automatic database expansion now differentiates between production and secondary servers.
#May 26 2021	Rafael Leandro	Formatted html message. Added best practices compliance (strict,warnings)

use strict;
use warnings;

my $prodserver="";
my $dbname="";
my $segname="";
my $space_left="";
my $spacetoadd="";
my $finTime=localtime();
my $sqlError="";
my $scriptname = $0;
my $log = $scriptname;
$log =~ s/(\w+).pl$/cron_logs\/$1.log/g;

if ($#ARGV != 2){
print "Usage: pageNow.pl cpscan image_seg 256000 \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR on script pageNow.pl. Check as soon as possible!!
Content-Type: text/html
MIME-Version: 1.0

The script didn't receive the proper parameters in the right order. Check the threshold procedures on Sybase and match the parameters. The script is located is /opt/sap/cron_scripts/pageNow.pl.</br></br>
EOF
`;
die;
}

use Sys::Hostname;
$prodserver = hostname();

if ($prodserver =~ /cpsybtest2/){
$prodserver='CPSYBTEST';
}

$dbname = $ARGV[0];
$segname = $ARGV[1];
$space_left = $ARGV[2];

if ($segname eq "logsegment"){
$spacetoadd = 1000;
}else{
$spacetoadd = 5000;
}

#Convert to MB
$space_left = ($space_left/512);

if ($dbname =~ /tempdb/){

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!
Content-Type: text/html
MIME-Version: 1.0

Only $space_left MB left</br></br>

Please contact DBAs for support.</br></br>

Dated: $finTime</br></br>
<p>Script path: perl $scriptname</p><p>Script log path: cat $log</p>
EOF
`;

}
else{
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use master
go
exec sp_add_database_space $dbname,"$segname",$spacetoadd
go
exit
EOF
`;


if ($sqlError =~ /Msg/ || $sqlError =~ /error/){
print $sqlError."\n";
$sqlError =~ s/\n/<\/br>/g;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!
Content-Type: text/html
MIME-Version: 1.0

Only $space_left MB left. Attempting to add 5GB of extra space automatically failed. See the error below.</br></br>

$sqlError

Dated: $finTime</br></br>
<p>Script path: perl $scriptname</p><p>Script log path: cat $log</p>
EOF
`;
}
else{
if ($sqlError =~ /no space left to add/){
print $sqlError."\n";
$sqlError =~ s/\n/<\/br>/g;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!
Content-Type: text/html
MIME-Version: 1.0

Only $space_left MB left</br></br>

The space for this segment on this secondary server is already synchronized with production. Please check what might have triggered the segment growth.</br></br>

Dated: $finTime</br></br>
<p>Script path: perl $scriptname</p><p>Script log path: cat $log</p>
EOF
`;
}else{
print $sqlError."\n";
$sqlError =~ s/\n/<\/br>/g;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!
Content-Type: text/html
MIME-Version: 1.0

Only $space_left MB left. </br></br>

If this is production, 5 GB were added automatically as a precaution (see output below). You should still check if any additional action is necessary. Remember to also add space on the standby and dr servers accordingly.</br></br>

If this is a secondary server, the database size was synchronized automatically using the production's database size as reference (see output below). If the attempt to synchronize the space failed, check the procedure master..sp_add_database_space and see what is missing (use the log below as a reference).</br></br>

$sqlError

Dated: $finTime</br></br>
<p>Script path: perl $scriptname</p><p>Script log path: cat $log</p>
EOF
`;
}
}
}


