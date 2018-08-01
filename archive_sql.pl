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
set rowcount 100
go     
delete cpscan..tttl_dr_delivery_record
from arch_db..tttl_dr_delivery_record tdr (prefetch 2 index tttl_dr_pidx), cpscan..tttl_dr_delivery_record pdr (prefetch 2) 
where tdr.conv_time_date   = pdr.conv_time_date
and   tdr.employee_num     = pdr.employee_num
and   tdr.delivery_rec_num = pdr.delivery_rec_num     
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
Subject: UpdateAC

$error
EOF
`;
   }#end of if messages received

