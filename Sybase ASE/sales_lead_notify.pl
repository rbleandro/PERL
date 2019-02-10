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
$driverName = 	$ARGV[0];
$territory = 	$ARGV[1];
$salesRep = 	$ARGV[2];
$contactName = 	$ARGV[3];
$customerName = $ARGV[4];
$addressLine1 = $ARGV[5];
$addressLine2 = $ARGV[6];
$city = 	$ARGV[7];
$postalCode = 	$ARGV[8];
$contactPhone = $ARGV[9];
$dated = 	$ARGV[10];
$employee_num = $ARGV[11];
$terminal_num = $ARGV[12];

`mail -s "Driver 50/50 Lead" \`cat /opt/sybase/sybmail/SALES_GROUP\` <<EOF

Dated: $dated
Driver: $driverName - $employee_num - $terminal_num
Territory: $territory
Sales Rep: $salesRep

Business Profile: 
---------------------
Contact: $contactName
Title: N/A
Company Name: $customerName
Address: $addressLine1
	 $addressLine2
City: $city
Province: ON
Postal Code: $postalCode
Telephone: $contactPhone
Customer Email: N/A
 
---------------------
 
EOF
`;

`mail -s "Driver 50/50 Lead" \`cat /opt/sybase/sybmail/SALES_EXEC_GROUP\` <<EOF

Dated: $dated
Driver: $driverName
Territory: $territory
Sales Rep: $salesRep

Business Profile:
---------------------
Contact: $contactName
Title: N/A
Company Name: $customerName
Address: $addressLine1
         $addressLine2
City: $city
Province: ON
Postal Code: $postalCode
Telephone: $contactPhone
Customer Email: N/A

---------------------

EOF
`;



`echo \"$driverName\" \"$territory\" \"$salesRep\" \"$contactName\" \"$customerName\" \"$addressLine1\" \"$addressLine2\" \"$city\" \"$postalCode\" \"$contactPhone\" \"$dated\" >> /opt/sybase/cron_scripts/cron_logs/sales_lead.log`;

