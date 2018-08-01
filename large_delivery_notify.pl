#!/usr/bin/perl 

###################################################################################
#Script:   This script sends out report (or something similar) to the customer via#
#          email							          #
#                                                                                 #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#June 15, 2010	Ahsan Ahmed     Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage: pageNow.pl cpscan image_seg 256000 \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$refrence_num =	$ARGV[0];
$service_type =	$ARGV[1];
$shipper_num =$ARGV[2];
$status =$ARGV[3];
$scan_time_date = $ARGV[4];

`mail -s "Large Volume Delivery" \`cat /opt/sybase/sybmail/TERMINAL_GROUP\` <<EOF

Date Generated: $dated
Full Barcode: $refrence_num$service_type$shipper_num
Destination

Barcode		Shipper		Status		Scanned: 
-------		-------		------		-------
$reference_num	$shipper_num	$status		@scan_time_date

__________________________________________________________________________________
EOF
`;



`echo \"$reference_num\" \"$shipper_num\" \"$shipper_num\" \"$scan_time_date\"  >> /opt/sybase/cron_scripts/cron_logs/large_volume.log`;

