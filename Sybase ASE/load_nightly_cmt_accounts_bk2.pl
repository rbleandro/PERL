#!/usr/bin/perl -w

##############################################################################
#Note:     This scrip will load cmt accounts based on the query in           #
#          XCUSTLIST_DATA in canship_webdb                                   #
#Author:   Ahsan Ahmed                                                       #                                                    
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Aug 01 2007	Amer Khan	Originally                                   # 
##############################################################################
#Usage Restrictions

open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account in  ('04999','05009','04952')
go
delete canship_webdb..XCUSTLIST_DATA 
from canship_webdb..XCUSTLIST_DATA, #cmt_accts 
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID  in  ('42204999','42205009','42204952')
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From CMT account refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: CMT Accounts Errors at $finTime

$sqlError
EOF
`;
}
