#!/usr/bin/perl 

###################################################################################
#Script:   This script sends out notification for any new sales lead by           #
#          triggering notification with new insert in sales_leas table            #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#May 17,07	Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage: pageNow.pl cpscan image_seg 256000 \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$employee_num 	= 	$ARGV[0];
$shipper_num	= 	$ARGV[1];
$conv_time_date	= 	$ARGV[2];
$form_type	= 	$ARGV[3];

`mail -s "Supply Order For $shipper_num" \`cat /opt/sap/sybmail/BC_REQ_GRP\` <<EOF

Customer: $shipper_num
Entered by Emp Num: $employee_num
Entry Date: $conv_time_date

Label Type: $form_type

EOF
`;

`echo \"$employee_num\" \"$shipper_num\" \"$conv_time_date\" \"$form_type\" >> /opt/sap/cron_scripts/cron_logs/barcode_req_notify.log`;

