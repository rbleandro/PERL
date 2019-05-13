#!/usr/bin/perl -w

###################################################################################
#Script:   This script sends out pages when thresholds of segments in database    #
#          are reached. This script is executed from within threshold stored      #
#          procedure and should not be used individually.                         #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#08/27/04       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 2){
   print "Usage: pageNow.pl cpscan image_seg 256000 \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$dbname = $ARGV[0];
$segname = $ARGV[1];
$space_left = $ARGV[2];

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute

#Convert to MB
$space_left = ($space_left/512);

if ($space_left <= 500 && $dbname ne 'tempdb'){
`mail -s "Segment: $segname in Database: $dbname may be FULL!!!" \`cat /opt/sap/sybmail/SYB_ADM_GROUP\` <<EOF
======================================
Only $space_left MB left
======================================

Please contact DBAs for support

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}else{
`mail -s "Segment: $segname in Database: $dbname may be FULL!!!" \`cat /opt/sap/sybmail/SYB_ADM_GROUP\` <<EOF
======================================
Only $space_left MB left
======================================

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}

