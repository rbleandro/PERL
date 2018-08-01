#!/usr/bin/perl -w

use strict;
use Spreadsheet::WriteExcel;
use Text::CSV_XS;
use Math::Round;
use POSIX;
   
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

#Prepare shipper file names and extract data in csv formate into separate files...
#Usage Restrictions
my @prodline;
my $prodserver;
my @error;
my $shipper_data;
my @shipper_list;
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
print "$_\n";
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

#Get all the shippers from scan_RTP
@shipper_list = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -Dcmf_data -n -b<<EOF 2>&1
set nocount on
SELECT distinct rtrim(shipper_num) FROM dbo.scan_RTP
go
exit
EOF
`;

#print @shipper_list;

my $n=0;

if(-e "/tmp/csv"){
`rm -fr /tmp/csv/*`;
}else{
 `mkdir /tmp/csv`;
}

while($shipper_list[$n])
{
$shipper_list[$n] =~ s/\D//g;

$shipper_data =`. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -Dcmf_data -n -b <<EOF>/tmp/csv/$shipper_list[$n]_$run_dt.csv
set nocount on
SELECT ltrim(rtrim(service_type+reference_num)),",",ltrim(rtrim(postal_code)),",",ltrim(rtrim(weight)) FROM dbo.scan_RTP
where shipper_num = convert(varchar,$shipper_list[$n])
go
exit
EOF
`;

if ($shipper_data =~ /Error/i || $shipper_data =~ /no/i || $shipper_data =~ /message/i){
      print "Messages From processing XLS conversion...\n";
      print "$shipper_data\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: RTP XLS Conversion messages

$shipper_data
EOF
`;

die "Can't proceed!! \n";
}
#Convert file to xls now...
my $msg_output = `/opt/sybase/cron_scripts/csv2xls.pl /tmp/csv/$shipper_list[$n]_$run_dt.csv /tmp/csv/$shipper_list[$n]_$run_dt.xls`;

print "$msg_output \n";

$n++;
}

#initiating FTP process

print "...Initiating FTP Process...\n";


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
