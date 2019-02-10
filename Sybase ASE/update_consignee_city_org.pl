#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates consignee_city in tttl_dr_delivery_record from     #
#          all_minor_cities in canda_post db based on the consignee_postal_code   #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#09/13/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
   print "Usage:update_consignee_city.pl\n";

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$server = "CPDB2";
$database = "cpscan";

#Execute update now

print "\n###Running update on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating update At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
use cpscan
go
set parallel_degree 1
go
execute update_consignee_city
go
set replication off
go
select  conv_time_date,employee_num,delivery_rec_num,consignee_city = t2.minor_city+','+t2.province_code
into #consignee_info
from tttl_dr_delivery_record t1 (index tttl_dr_nc_ioc), canada_post..all_minor_cities t2
where t1.consignee_postal_code = t2.postal_code
and t1.consignee_postal_code <> ''
and (t1.consignee_city = '' or t1.consignee_city is null)
and t1.inserted_on_cons > dateadd(dd,-3,getdate())
go
update tttl_dr_delivery_record
set consignee_city = con.consignee_city
from tttl_dr_delivery_record tdr, #consignee_info con
where tdr.conv_time_date = con.conv_time_date
and tdr.employee_num = con.employee_num
and tdr.delivery_rec_num = con.delivery_rec_num
go
exit
EOF
`;
print "$error\n";

print "***Initiating update At:".localtime()."in CPDB1 now***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 <<EOF 2>&1
use cpscan
go
set replication off
go
select  conv_time_date,employee_num,delivery_rec_num,consignee_city = t2.minor_city+','+t2.province_code
into #consignee_info
from tttl_dr_delivery_record t1 (index tttl_dr_nc_ioc), canada_post..all_minor_cities t2
where t1.consignee_postal_code = t2.postal_code
and t1.consignee_postal_code <> ''
and (t1.consignee_city = '' or t1.consignee_city is null)
and t1.inserted_on_cons > dateadd(dd,-3,getdate())
go
update tttl_dr_delivery_record
set consignee_city = con.consignee_city
from tttl_dr_delivery_record tdr, #consignee_info con
where tdr.conv_time_date = con.conv_time_date
and tdr.employee_num = con.employee_num
and tdr.delivery_rec_num = con.delivery_rec_num
go
exit
EOF
`;
print "$error\n";

   if ($error =~ /not/){
      print "Messages From Update of consignee_city Process...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Update consignee_city in tttl_dr_delivery_record

$error
EOF
`;
   }#end of if messages received

