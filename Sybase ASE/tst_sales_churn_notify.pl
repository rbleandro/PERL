#!/usr/bin/perl 

###################################################################################
#Script:   This script sends out notification for any new sales lead by           #
#          triggering notification with new insert in sales_churn table           #
#Note:	   This script is only executed from within a trigger.                    #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Aug 1,07	Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 1){
   print "Usage:sales_churn_notify.pl employee_num shipper_num comments dated  \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$employee_num = $ARGV[0];
$shipper_num  = $ARGV[1];
$comments     =	$ARGV[2];
$dated        =	$ARGV[3];

$employee_name = `. /opt/sybase/SYBASE.sh
isql -b -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -Dcpscan <<EOF 2>&1
USE cpscan
go
set nocount on
go
declare \@emp_name varchar(50)
select \@emp_name = employee_name from employee where employee_num = '$employee_num'
select \@emp_name
go
exit
EOF
`;

$shipper_name = `. /opt/sybase/SYBASE.sh
isql -b -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -Dcpscan <<EOF 2>&1
USE cpscan
go
set nocount on
go
declare \@shipper_name varchar(50)
select \@shipper_name = customer_name from shipper where customer_num = '$shipper_num'
select \@shipper_name
go
exit
EOF
`;

$employee_name =~ s/\n//g;
$shipper_name  =~ s/\n//g;

`mail -s "Handheld - Sales Churn" frank_orourke\@canpar.com,ron_pogson\@canpar.com <<EOF

Dated: $dated
Employee: $employee_num -- $employee_name
Shipper: $shipper_num -- $shipper_name

Comments: 
---------------------
$comments 
---------------------
 
EOF
`;
