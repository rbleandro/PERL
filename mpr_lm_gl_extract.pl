#!/usr/bin/perl 

###################################################################################
#Script:   This script uploads gl data from solomon onto sybase for mpr purposes  #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Dec 19 2013	Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
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

#Setting Time
$currDate=localtime();
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "Test Mount Point...\n";
$mount_pt=`cat /etc/mtab | grep mpr_data_lm`;
if ($mount_pt eq ""){

   #$mount_msgs = `sudo mount -t cifs -o user\=\"canparnt\\gl_ftp_user",password\=C\@np\@r12 \/\/cphqfs1\/ApplicationData\/MPR_DATA_LM /opt/sap/bcp_data/mpr_data_lm/gl_extract -o noperm 2>&1`;
   $mount_msgs = `sudo mount -t cifs \/\/cprhqvfs4.canpar.com\/AppData\/MPR_DATA_LM /opt/sap/bcp_data/mpr_data_lm/gl_extract -o username=gl_ftp_user,password=C\@np\@r12,domain=canparnt 2>&1`;
   print "Any mounting messages, already mounted messages can be ignored:\n\n $mount_msgs\n";
}else{
   print "Dir is already mounted \n";
}

print "GL Extract StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Uploading data...
if (-e "/opt/sap/bcp_data/mpr_data_lm/gl_extract/gl_data_lm.csv"){ 
$bcp_msg = `. /opt/sap/SYBASE.sh
bcp mpr_data_lm..gl_data in /opt/sap/bcp_data/mpr_data_lm/gl_extract/gl_data_lm.csv -Usa -S$prodserver -P\`/opt/sap/cron_scripts/getpass.pl sa\` -c -t","  -r"\r\n" -b1000`;
}else{
 die "File not available yet, dying\n\n";
}

#Any errors
print "BCP Messages: $bcp_msg";

if($bcp_msg !~ /rows copied/ ){      
print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - bcp of gl_data for Loomis
Following status was received during gl_data bcp that started on $currTime
$bcp_msg
EOF
`;
die "Can't Continue\n\n";
}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data_lm
go
set clientapplname \'GL Data Upload\'     
go    
execute mpr_gl_upload_data
go
exit
EOF
`;
print "Any sql messages:". $sqlError."\n";

if($sqlError =~ /Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - GL Upload procedure for Loomis

Following status was received during mpr_gl_upload_data that started on $currTime
$sqlError
EOF
`;

die "Something went wrong, not moving gl file yet";
}

#If all is good, archive gl file...
$mv_msg = `cp /opt/sap/bcp_data/mpr_data_lm/gl_extract/gl_data_lm.csv /opt/sap/bcp_data/mpr_data_lm/gl_extract_bkp/ 2>&1`;
print "Any messages from moving file: $mv_msg \n\n";

$mv_msg =~ s/`//g;

if($mv_msg =~ /cannot/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - copying file to gl_extract_bkp for Loomis

Following status was received during copying file to gl_extract_bkp that started on $currTime
$mv_msg
EOF
`;

die "Something went wrong, not deleting gl file yet";
}

#Deleting file from gl_extract folder...
$del_msg = `sudo rm -f /opt/sap/bcp_data/mpr_data_lm/gl_extract/gl_data_lm.csv`;
print "Any messages from deleting file: $del_msg \n\n";

