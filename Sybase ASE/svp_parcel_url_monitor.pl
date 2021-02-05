#!/usr/bin/perl

###################################################################################
#Script:   This script is reporting the startup and completion of url execution   #
#          for Parcel batch evaluation java program                               #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jul 21,08	Amer Khan       Originally created                                #
#Feb 21,12	Amer Khan	Modified to use table for complete status         #                                                                                 #
#                                                                                 #
###################################################################################

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
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

#Setting Time
$currDate=localtime();
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);

$date_flag = $ARGV[0];
#$date_flag = '02/21/2016 12:48:53 AM';
#print "Date to check from : $date_flag \n";

#################################################
#Check if the process completed within a minute #
#as it will not be caught by the logic below,   #
#since the logic below only runs once per minute#
#################################################
$found = 0;
$not_found=0;
$sqlMsg = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
set nocount on   
go   
use cmf_data
go    
print '$date_flag'
select top 1 * from svp_url_status 
where status_date > '$date_flag' and job_name = 'Parcel Evaluation' and job_status = 'complete'
order by status_date desc
go    
exit
EOF
`;

print $sqlMsg;
print "Found:$found\n";

if($sqlMsg =~ /complete/){
    $found++;
}

if ($found >= 1){
print "found it";
`touch /tmp/svp_p_completed`;
 `/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com
Subject: svp_url Parcel trigger completed...
==============================================
$sqlMsg
==============================================

EOF
`;

die;
}

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep svp_parcel_url_execution.pl|grep -v grep|grep -v $my_pid|grep -v "vim svp_parcel_url_execution.pl"|grep -v "less svp_parcel_url_execution.pl"| awk \'{ printf \$5\" \" }\'`;

print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning &&  $isProcessRunning !~ /:/){
print "URL over day old\n";
 if (!-e "/tmp/svp_url_not_completed"){
  print "Paging Someone \n";

#`touch /tmp/svp_url_not_completed`;
`echo hi`;
}

}else { print "here \n"; if (-e "/tmp/svp_url_not_completed") {print "I am here \n"; `rm /tmp/svp_url_not_completed`;}}

