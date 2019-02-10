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
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1";
}
else
{
   $standbyserver = "CPDB2";
}

#Usage Restrictions
   print "Usage:update_consignee_city.pl\n";

#Initialize vars
$database = "cpscan";

#Execute update now

print "\n###Running update on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating update At:".localtime()."***\n";
$error = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cpscan
go
execute update_consignee_city
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

