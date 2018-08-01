#!/usr/bin/perl -w
######################################################################
#Description:	This programs is run through a proc called
#		mpr_linehaul_vols_generate in mpr_data which
#		generates a xls file meant to be sent to a user
#		who then enters cost for the volumes avaialable
#		in the file and then saves it in the gl_data folder
#		from where it is then picked for linehaul processing
#Created By:	Amer Khan
#Created Date:	Jan 23 2013
#######################################################################

use strict;
use Spreadsheet::WriteExcel;
use Text::CSV_XS;
use Math::Round;
use POSIX;
 
#Prepare shipper file names and extract data in csv formate into separate files...
##Usage Restrictions
my @prodline;
my $prodserver;
my @error;
my $shipper_data;
my @shipper_list;
my $start_date;
my $end_date;

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
#print "$_\n";
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}

close PROD;

if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n";
}
use Sys::Hostname;
$prodserver = hostname();

#Set date now...
my $wday=sprintf('%02d',((localtime())[6]));

#We need to roll the date back to previous friday or most recent past Friday
my $friday = ($wday - 5) + 7;

my $epochFriday = time - 24 * 60 * 60 * $friday; # Must do this to subtract days, since simple subtract from localtime DOES NOT work;

my $year=sprintf('%02d',((localtime($epochFriday))[5]));
my $month=sprintf('%02d',((localtime($epochFriday))[4])+1);
my $day=sprintf('%02d',((localtime($epochFriday))[3]));

$year += 1900; # To get four digit


my $run_dt = $year.$month.$day;

#=======================================
#Enter input data
$start_date = $ARGV[0];
$end_date = $ARGV[1];
#=======================================

#Get all the shippers from scan_RTP
@shipper_list = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -Dcmf_data -n -b<<EOF 2>&1
set nocount on
select period from cmf_data..tot_fm where start_date = '12/02/2012' and end_date = '12/29/2012 12:00:00.000 AM'
go
exit
EOF
`;

#print @shipper_list;

my $n=0;

if(-e "/tmp/mpr"){
`rm -fr /tmp/mpr/*`;
}else{
 `mkdir /tmp/mpr`;
}

while($shipper_list[$n])
{
$shipper_list[$n] =~ s/\D//g;

$shipper_data =`. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -Dmpr_data -n -b -w200 <<EOF>/tmp/mpr/$shipper_list[$n]_$run_dt.csv
set nocount on
SELECT convert(char(10),start_date,101),",",convert(char(10),end_date,101),",",ltrim(rtrim(linehaul_lane)),",",ltrim(rtrim(service)),",",convert(char(3),total_cost),",",volume_in_ft,",",convert(char(3),cost_per_cubic_ft) FROM mpr_data.dbo.mpr_linehaul
where start_date = '12/02/2012' and end_date = '12/29/2012 12:00:00.000 AM'
go
exit
EOF
`;

if ($shipper_data =~ /Error/i || $shipper_data =~ /no/i || $shipper_data =~ /message/i){
      print "Messages From processing XLS conversion...\n";
      print "$shipper_data\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: MPR Linehaul volumes xls file

$shipper_data
EOF
`;

die "Can't proceed!! \n";
}
#Convert file to xls now...
my $msg_output = `/opt/sybase/cron_scripts/mpr_vols_csv2xls.pl /tmp/mpr/$shipper_list[$n]_$run_dt.csv /tmp/mpr/$shipper_list[$n]_$run_dt.xls`;

print "$msg_output \n";

$n++;
}

#initiating FTP process

print "...Initiating FTP Process...\n";

die;
my $ftp_msg = `/usr/bin/ftp -n -v ftp.canpar.com << EOF
bin
user .rtp_user.customersftp.canpar !Rtp_user11
cd /prodpoll/XNET/MANAGER/custom/rtp
lcd /tmp/csv
prompt
mput *.xls
bye
bye
EOF
`;

print "$ftp_msg \n";

if ($ftp_msg =~ /Error/i || $ftp_msg =~ /no /i || $ftp_msg =~ /message/i){
      print "Messages From RTP FTP...\n";
      print "$ftp_msg\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: RTP FTP messages

$ftp_msg
EOF
`;

}
