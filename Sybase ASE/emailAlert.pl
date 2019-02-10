#!/usr/bin/perl 

###################################################################################
#Script:   This script sends out pages when a job completes        	          #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#07/02/15       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 2){
   print "Usage: pageNow.pl jobName complete P9\n";
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

`mail -s "Job Status: $job has $status" \`cat /opt/sap/sybmail/MPR_RCVRS\` <<EOF

Dated: $currDate\--$currHour\:$currMin

--=========== SOF Comments ============

$comments

--========== EOF Comments =============
EOF
`;
