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

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
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
$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '04999'
go
delete canship_webdb..XCUSTLIST_DATA 
from canship_webdb..XCUSTLIST_DATA, #cmt_accts 
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID =  '42204999'
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

print "Running refresh for Running Room account ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05009'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205009'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From RunningRoom address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com  
Subject: Running Room Accounts Errors at $finTime

$sqlError
EOF
`;
}

print "Running refresh for Running Room account ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
#$sqlError
#EOF
#`;

#}

print "Running refresh for Running Room account Jesse ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '04952'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42204952'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From RunningRoom address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Running Room Accounts Errors at $finTime

$sqlError
EOF
`;
}


print "Running refresh for Running Room account Jesse ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account in ('05051', '05052','05053')
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205052'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From RunningRoom address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Running Room Accounts Errors at $finTime

$sqlError
EOF
`;
}


print "Running refresh for Running Room account Keith/Jesse ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05059'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205059'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From RunningRoom address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Running Room Accounts Errors at $finTime

$sqlError
EOF
`;
}

#####################*************************************###############################*****************************

print "Running refresh for Running Room account Keith/Jesse ... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '00610'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42200610'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From RunningRoom address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Running Room Accounts Errors at $finTime

$sqlError
EOF
`;
}

#####################*************************************###############################*****************************




print "Running refresh for Bestsellers--Retail Only  account Requested By Jesse On May 10, 2010... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05062'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205062'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Bestsellers--Retail Only address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Bestsellers--Retail Only Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "Running refresh for Bestsellers - Jack And Jones account Requested By Jesse On May 10, 2010... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05040'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205040'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Bestsellers--Retail Only address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Bestsellers - Jack And Jones Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On May 10, 2010... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05076'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205076'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From  Vero Moda address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Vero Moda Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On Apr 29, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05079'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205079'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From  Vero Moda address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Vero Moda Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On Apr 29, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05078'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205078'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From  Vero Moda address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Vero Moda Accounts Errors at $finTime

$sqlError
EOF
`;
}


#################################****************************************###############################*********************

print "Running room for account Requested By Jesse On May 12, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05080'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205080'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From  Vero Moda address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Vero Moda Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print " Swarski account Requested By Jesse On Aug 3, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05049'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205049'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "  Requested By Jesse On Oct 14, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05094'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205094'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "  Requested By Jesse On Feb 3, 2012... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05006'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205006'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************

print "  Requested By Jesse On Feb 3, 2012... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05105'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205105'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;
}
#################################****************************************###############################*********************

print "  Requested By Jesse On July 10, 2012... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '00579'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42200579'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;
}

#################################****************************************###############################*********************


#################################****************************************###############################*********************

print "  Requested By Jesse On July 10, 2012... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05140'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205140'
go
exit
EOF
`;
print $sqlError."\n";


$finTime = localtime();
   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Swarsksi address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Swarsski Accounts Errors at $finTime

$sqlError
EOF
`;

}

######################3#
print " Parasuc account Requested By Jesse On Aug 29, 2011... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '00024'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42200024'
go
exit
EOF
`;

print $sqlError."\n";


$finTime = localtime();

   if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
      print "Messages From Parasucu address book nightly refresh...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Parasucu Accounts Errors at $finTime

$sqlError
EOF
`;
}
######################3#
print " Boathouse account Requested By Heather On June 4th, 2018... CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
select customer_num as account_num into #cmt_accts from cmfshipr where billto_account = '05106'
go
delete canship_webdb..XCUSTLIST_DATA
from canship_webdb..XCUSTLIST_DATA, #cmt_accts
where ShipperID = account_num
go
insert canship_webdb..XCUSTLIST_DATA
select account_num,LoginName,CustID,Name,Address1,Address2,Address3,Attention,City,Prov,PostalCode,PhoneNumber,EMail,POBox,GroupID,RefType,Reference,CostCentre,GFlag,QFlag,Deleted,SendEMail,FaxNumber,Special,0,null
from canship_webdb..XCUSTLIST_DATA,#cmt_accts  where ShipperID='42205106'
go
exit
EOF
`;
print $sqlError."\n";
$finTime = localtime();
if ($sqlError =~ /Error/i || $sqlError =~ /Msg/){
print "Messages From Boathouse address book nightly refresh...\n";
print "$sqlError\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Boathouse Accounts Errors at $finTime
$sqlError
EOF
`;
}
