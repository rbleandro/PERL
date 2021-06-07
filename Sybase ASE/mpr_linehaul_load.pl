#!/usr/bin/perl 


open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

# Process Check

$isProcessRunning =`ps -ef|grep sybase|grep mpr|grep _linehaul|grep _load|awk \'{ print \$3 }\'`;
@pid_array = split(/\n/,$isProcessRunning);
$my_pid = getppid();

foreach(@pid_array){ 

   if ($_ != $my_pid)
      {
        die "Can't continue,process is already running, dying!!\n";
      }

}

#Setting Time
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

print "Test Mount Point...\n";
#$mount_pt=`cat /etc/mtab | grep mpr`;
#if ($mount_pt eq ""){
#   $mount_msgs = `sudo mount -t cifs -o user\=\"canparnt\\gl_ftp_user",password\=C\@np\@r12 \/\/cphqfs1\/ApplicationData\/MPR_DATA /opt/sybase/bcp_data/mpr_data/gl_extract -o noperm 2>&1`;
#   print "Any mounting messages, already mounted messages can be ignored:\n\n $mount_msgs\n";
#}else{
#   print "Dir is already mounted \n";
#}

opendir ($GL_DIR, "/opt/sybase/bcp_data/mpr_data/gl_extract/") || die "Cant open dir /opt/sybase/bcp_data/mpr_data/gl_extract : $!";

@ALLFILES=grep { /linehaul_data/ } readdir $GL_DIR;

print "$ALLFILES[0] \n";

@period = split(/\./,$ALLFILES[0]);

print "Period Running for: $period[1] \n";

print "Linehaul Load StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Uploading data...
if (-e "/opt/sybase/bcp_data/mpr_data/gl_extract/linehaul_data.$period[1]"){ 
$bcp_msg = `. /opt/sybase/SYBASE.sh
bcp_r mpr_data..linehaul_bcp in /opt/sybase/bcp_data/mpr_data/gl_extract/linehaul_data.$period[1] -V -S$prodserver -c -t"," -F2 -r"\r\n" -b1000`;
}else{
 die "File not available yet: linehaul_data.$period[1] , dying\n\n";
}

#Any errors
print "BCP Messages: $bcp_msg";

if($bcp_msg !~ /rows copied/ ){      
print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - bcp of linehaul_data
Following status was received during linehaul_data bcp that started on $currTime
$bcp_msg
EOF
`;
die "Can't Continue\n\n";
}

$sqlError = `. /opt/sybase/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
set clientapplname \'Linehaul Data Upload\'     
go    
execute mpr_linehaul_upload_data $period[1]
go
exit
EOF
`;
print "Any sql messages:". $sqlError."\n";

if($sqlError =~ /Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - Linehaul Upload procedure

Following status was received during mpr_linehaul_upload_data that started on $currTime
$sqlError
EOF
`;

die "Something went wrong, not moving linehaul file yet";
}

#If all is good, archive gl file...
$mv_msg = `cp /opt/sybase/bcp_data/mpr_data/gl_extract/linehaul_data.$period[1] /opt/sybase/bcp_data/mpr_data/gl_extract_bkp/ 2>&1`;
print "Any messages from moving file: $mv_msg \n\n";
$mv_msg =~ s/`//g;

if($mv_msg =~ /cannot/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - copying linehaul file to gl_extract_bkp

Following status was received during copying linehaul file to gl_extract_bkp that started on $currTime
'$mv_msg'
EOF
`;

die "Something went wrong, not deleting linehaul file yet";
}

#Deleting file from gl_extract folder...
$del_msg = `rm /opt/sybase/bcp_data/mpr_data/gl_extract/linehaul_data.$period[1]`;
print "Any messages from deleting file: $del_msg \n\n";

