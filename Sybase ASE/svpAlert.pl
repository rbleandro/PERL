#!/usr/bin/perl 

###################################################################################
#Script:   This script sends out pages when svp URL hangs                         #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Oct 12 2016	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 2){
   print "Usage: pageNow.pl cpscan image_seg 256000 \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$job = $ARGV[0];
$status = $ARGV[1];
$comments = $ARGV[2];

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute

`mail -s "URL Execution Status: $job has $status" \`cat /opt/sap/sybmail/SVP_RCVRS\` <<EOF

Date And Time Checked: $currDate\--$currHour\:$currMin

--=========== SOF Comments ============

$comments

--========== EOF Comments =============
EOF
`;
