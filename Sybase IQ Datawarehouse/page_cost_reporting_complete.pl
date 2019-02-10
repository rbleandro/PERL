#!/usr/bin/perl

###################################################################################
#Script:   This script keeps track of the database growth and percent increase in #
#          db size from the last reading taken                                    #
#                                                                                 #
#Note:     This script can be used with any database, but you have to have a table#
#          called db_growth_record in the database where it is being executed     #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################


$date1 = $ARGV[0];
$date2 = $ARGV[1];
$rec_cnt = $ARGV[2];
$email_add = $ARGV[3];

`cat $date $date2 $rec_cnt $email_add > /tmp/checking`;

`/usr/sbin/sendmail -t -i <<EOF
To: $email_add\@canpar.com,CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Load of cost_analysis in CPIQ is complete

Period Processed: $date1 to $date2
Records Processed: $rec_cnt

Note: Please do not reply to this email, this is a machine generated email.

Thanks
Amer
EOF
`;

