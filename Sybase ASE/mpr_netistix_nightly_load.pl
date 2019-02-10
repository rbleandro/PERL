#!/usr/bin/perl -w

##############################################################################
#Script:   This script loads data into truk_data from netistix files         #
#                                                                            #
#Author:   Amer Khan                             			     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#10/20/08	Amer Khan	Created					     #
##############################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
$mon=$mon+1;#Month perl starts with 0, go figure...
$year += 1900;

#if (1==2){
print "FTP'ing netistix file now...".localtime()."\n";

$ftp_msg = `/usr/kerberos/bin/ftp -n -v ftp.canpar.com << EOF
ascii
user .netistix.external.canpar canp-netistix
lcd /opt/sybase/bcp_data/mpr_data/netistix
prompt
mget Stop*.csv
bye
bye
EOF
`;
#}#eof don't run

print "Any messages from ftp: $ftp_msg \n";

$dirname = "/opt/sybase/bcp_data/mpr_data/netistix";

opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";

# Consider files with .csv extension only
@file_array = grep {/\.csv$/} readdir(DIR);

if ($#file_array < 0){
   print "No new files are here!!...Paging someone who cares\n";
`/usr/sbin/sendmail -t -i <<EOF
To: jburn\@bsmwireless.com,jesse_robinson\@canpar.com
Subject: No Netistix Files Found at $currTime

Check FTP from Netistix now...
EOF
`;

die "Nothing to do...\n Dying miserably\n";
}

#Need temporary file save massage and save data for bcp purposes
open (OUTFILE,">/tmp/netistix.dat") || print "cannot open: $!\n";

foreach $filename (@file_array){
   next if !($filename =~ /\.csv$/);
   print "Loading $filename at ".localtime()." \n";
   open (INFILE,"</opt/sybase/bcp_data/mpr_data/netistix/$filename") || print "cannot open: $!\n";

   while (<INFILE>){      
      ($truck_id,$stop_time,$start_time,$rpm,$odometer,$fuel_usage,$gps_location) = split(/\,/,$_);
      next if ($truck_id eq '' || $truck_id !~ /^\d\d\d\D\d\d\d\d\d\d/);
      if ($fuel_usage eq ''){$fuel_usage = '0';}
      if ($odometer eq ''){$odometer = '0';}
      if ($rpm eq 'off'){$rpm = '0';}else{$rpm='1';}
      if ($fuel_usage <= 0){$fuel_usage = '0';}

      print OUTFILE substr($truck_id,0,3)."||".$truck_id."||"."$mon/$mday/$year"."||"." "."||".$stop_time."||".$start_time."||".$rpm."||".$odometer."||".$fuel_usage."||"." "."\n";
   
#      last; #last of records for testing

   }#eof while loop
#   last; # last of file names testing
   close INFILE;
#   print $sqlError."\n";
}
closedir(DIR);
close OUTFILE;

$sqlError .= `. /opt/sybase/SYBASE.sh
bcp_1501 mpr_data..truck_data in /tmp/netistix.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver  -c -t"||" -r"\n" -Q
`;

print "Any BCP messages: $sqlError\n";


$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 -e <<EOF 2>&1
use mpr_data
go    
update truck_data    
set employee_num = ts.employee_num   
from truck_data td, cpscan..truck_stats ts   
where ts.truck_num = substring(td.truck_id,5,6)   
and td.employee_num = ''   
and convert(date,td.start_time) = convert(date,ts.conv_time_date)   
go    
exit   
EOF   
`;

print "Messages from update: $sqlError\n";

#Paging if errors occurred in the previous update

$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Netistix data load...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Netitstix Update Errors at $finTime

$sqlError
EOF
`;
}

print "Archiving netistix file now...localtime()";

$ftp_msg = `/usr/kerberos/bin/ftp -n -v ftp.canpar.com << EOF
ascii
user .netistix.external.canpar canp-netistix
lcd /opt/sybase/bcp_data/mpr_data/netistix
cd archive
prompt
mput Stop*.csv
cd ..
delete Stop*.csv
bye
bye
EOF
`;

print "Any messages from ftp: $ftp_msg \n";

$mv_msg = `mv /opt/sybase/bcp_data/mpr_data/netistix/Stop*.csv /opt/sybase/bcp_data/mpr_data/netistix/archive/`;

print "Any messages from moving file from netistix to archive folder locally: $mv_msg \n";

`touch /tmp/netistix_load_done`;

