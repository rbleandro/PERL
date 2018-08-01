#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates ACprocessing information in liberty_db             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#04/18/05	Amer Khan	Originally created                                #
#                                                                                 #
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

#Execute update now

print "***Initiating update At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cpscan
go    
set rowcount 1000
insert tempdb2..tmpt
select arc.service_type,arc.shipper_num,arc.reference_num
from arch_db..tttl_ma_manifest arc, cpscan..tttl_ma_manifest cps
where arc.service_type  = cps.service_type 
and arc.reference_num = cps.reference_num
and arc.shipper_num = cps.shipper_num  
and arc.shipper_num <> '99999999'
and arc.shipper_num <> '99999998'
go

delete cpscan..tttl_ma_manifest from cpscan..tttl_ma_manifest cps, tempdb2..tmpt arc
where cps.service_type = arc.service_type
and cps.reference_num = arc.reference_num
and cps.shipper_num = arc.shipper_num 
go

truncate table tempdb2..tmpt
go     
exit     
EOF
`;
print "$error\n";
   if ($error =~ /not/ || $error =~ /Msg/){
      print "Messages From Archival Errors...\n";
      print "$error\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Update ma_manifest

$error
EOF
`;
   }#end of if messages received

