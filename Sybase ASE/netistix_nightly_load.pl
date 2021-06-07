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

$prodserver = "CPSYBTEST"; # Remove this when testing is done...Amer

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

print "FTP'ing netistix file now...".localtime()."\n";

$ftp_msg = `/usr/kerberos/bin/ftp -n -v ftp.canpar.com << EOF
ascii
user .netistix.external.canpar canp-netistix
lcd /opt/sybase/bcp_data/mpr_data/netistix
prompt
mget *Stop.csv
bye
bye
EOF
`;

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

foreach $filename (@file_array){
   next if !($filename =~ /\.csv$/);
   print "Loading $filename at ".localtime()." \n";
   open (INFILE,"</opt/sybase/bcp_data/mpr_data/netistix/$filename") || print "cannot open: $!\n";
   while (<INFILE>){      
      ($truck_id,$stop_time,$start_time,$rpm,$odometer,$fuel_usage,$gps_location) = split(/\,/,$_);
      next if ($truck_id eq '' || $truck_id !~ /^\d\d\d\D\d\d\d\d\d\d/);
      if ($fuel_usage eq ''){$fuel_usage = '0';}
      if ($odometer eq ''){$odometer = '0';}

      $sqlError .= `. /opt/sybase/SYBASE.sh
isql_r -V -S$prodserver -w300 -e <<EOF 2>&1
use mpr_data
go
insert truck_data
select substring(\'$truck_id\',1,3), \'$truck_id\', convert(date,getdate()), '',\'$stop_time\',\'$start_time\',
rpm = case when \'$rpm\' = 'off' then 0 else 1 end,
$odometer,
fuel_usage = case when $fuel_usage > 0 then $fuel_usage else 0 end,
''
go
exit
EOF
`;
#      last; #last of records for testing

   }#eof while loop
#   last; # last of file names testing
   close INFILE;
   print $sqlError."\n";
}
closedir(DIR);

      $sqlError = `. /opt/sybase/SYBASE.sh
isql_r -V -S$prodserver -w300 -e <<EOF 2>&1
use mpr_data
go    
update truck_data    
set employee_num = ts.employee_num   
from truck_data td, cpscan..truck_stats ts   
where ts.truck_num = substring(td.truck_id,5,6)   
and td.employee_num = ''   
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
mput *Stop.csv
cd ..
delete *Stop.csv
bye
bye
EOF
`;

print "Any messages from ftp: $ftp_msg \n";

$mv_msg = `mv /opt/sybase/bcp_data/mpr_data/netistix/*Stop.csv /opt/sybase/bcp_data/mpr_data/netistix/archive/`;

print "Any messages from moving file from netistix to archive folder locally: $mv_msg \n";

