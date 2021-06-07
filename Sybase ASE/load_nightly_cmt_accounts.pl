#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help
) or die showDefaultHelp(1,$0);

showDefaultHelp($help,$0);
checkProcessByName($checkProcessRunning,$0);
isProd($skipcheckprod);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 01");

print "Running refresh for Running Room account ... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 02");

print "Running refresh for Running Room account Jesse ... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 03");

print "Running refresh for Running Room account Jesse ... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query04");

print "Running refresh for Running Room account Keith/Jesse ... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query05");

#####################*************************************###############################*****************************

print "Running refresh for Running Room account Keith/Jesse ... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query06");

#####################*************************************###############################*****************************

print "Running refresh for Bestsellers--Retail Only  account Requested By Jesse On May 10, 2010... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query07");

#################################****************************************###############################*********************

print "Running refresh for Bestsellers - Jack And Jones account Requested By Jesse On May 10, 2010... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 08");

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On May 10, 2010... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 09");

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On Apr 29, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 10");

#################################****************************************###############################*********************

print "Running refresh for  Vero Moda account Requested By Jesse On Apr 29, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 11");

#################################****************************************###############################*********************

print "Running room for account Requested By Jesse On May 12, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 12");

#################################****************************************###############################*********************

print " Swarski account Requested By Jesse On Aug 3, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 13");

#################################****************************************###############################*********************

print "  Requested By Jesse On Oct 14, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 14");

#################################****************************************###############################*********************

print "  Requested By Jesse On Feb 3, 2012... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 15");

#################################****************************************###############################*********************

print "  Requested By Jesse On Feb 3, 2012... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 16");
#################################****************************************###############################*********************

print "  Requested By Jesse On July 10, 2012... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 17");

#################################****************************************###############################*********************

#################################****************************************###############################*********************

print "  Requested By Jesse On July 10, 2012... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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
send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 18");

print " Parasuc account Requested By Jesse On Aug 29, 2011... CurrTime: $currTime\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 19");

print " Boathouse account Requested By Heather On June 4th, 2018... CurrTime: $currTime\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
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

send_alert($sqlError,"Msg",$noalert,$mail,$0,"query 20");
