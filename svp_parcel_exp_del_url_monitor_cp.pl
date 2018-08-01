#!/usr/bin/perl 

###################################################################################
#Script:   This script is reporting the startup and completion of url execution   #
#          for Parcel Del  batch evaluation java program                          #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jun 22,15	Amer Khan       Originally created                                #
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
#$date_flag = '02/21/2012 12:48:53 AM';
print "Date to check from : $date_flag \n";

#################################################
#Check if the process completed within a minute #
#as it will not be caught by the logic below,   #
#since the logic below only runs once per minute#
#################################################
$found = 0;
$not_found=0;
$sqlMsg = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
set nocount on   
go   
use svp_cp
go    
print '$date_flag'
select * from svp_url_status 
where status_date > '$date_flag' and job_name = 'Canpar Parcel Expected Delivery Date Evaluation' and job_status = 'complete'
order by status_date desc
go    
exit
EOF
`;

print $sqlMsg;

if($sqlMsg =~ /complete/){
    $found++;
}

if ($found >= 1){
`touch /tmp/svp_cp_ed_completed`;
 `/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com
Subject: svp_cp_url Expected Del trigger completed...
==============================================
$sqlMsg
==============================================

EOF
`;

}
