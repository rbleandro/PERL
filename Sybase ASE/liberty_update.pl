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

#Execute liberty_update
#
print "***Initiating liberty_update At:".localtime()."***\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
declare \@days int
select \@days = 20
select \@days = \@days * -1

select szF1, shipper_num, RBF_paper, pickup_rec_date into #phase1
from liberty_db..F_PUProc_Data, rev_hist..revhsth where 1=2

insert #phase1
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where szF1 = pickup_rec_num   
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
--
-- Select rows for documents with length 6
-- Stick a space in front to match them with a PUR
--
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where char_length(szF1) = 6
and pickup_rec_num = " " + szF1
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
--
 
-- Unions with rows for documents with one or more leading zeroes
-- Replace the leading zero with a space for searching
--
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,1) = "0"
and stuff(szF1,1,1," ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth 
 where substring(szF1,1,2) = "00"
and stuff(szF1,1,2,"  ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date 
 from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,3) = "000"
and stuff(szF1,1,3,"   ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,4) = "0000"
and stuff(szF1,1,4,"    ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,5) = "00000"
and stuff(szF1,1,5,"     ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,6) = "000000"
and stuff(szF1,1,6,"      ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)

go     

--====== Update F_PUProc tables with the information from dss tables for phase 1

--execute convertdatex \@dt, \@x output
update liberty_db..F_PUProc_Data
set szF2 = shipper_num, 
    szF3 = RBF_paper, 
    szF4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase1 p1, liberty_db..F_PUProc_Data f
where f.szF1 = p1.szF1

go     
--select * from #phase1
--
-- Do the same update to the Rec table
--
update liberty_db..F_PUProc_Rec
set szKey2 = shipper_num, 
    szKey3 = RBF_paper, 
    szKey4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase1 p1, liberty_db..F_PUProc_Rec f
where f.szKey1 = p1.szF1

go     

--==========Inintiating Phase 2
select szF1, shipper_num, RBF_paper, pickup_rec_date into #phase2 
from liberty_db..F_PUProc_Data, rev_hist..revhsth where 1=2
go     
insert #phase2
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where szF1 = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where char_length(szF1) = 6 
and pickup_rec_num = " " + szF1
and szF2 = shipper_num
and szF3 = ""
union    
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,1) = "0"
and stuff(szF1,1,1," ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,2) = "00"
and stuff(szF1,1,2,"  ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,3) = "000"
and stuff(szF1,1,3,"   ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,4) = "0000"
and stuff(szF1,1,4,"    ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth
where substring(szF1,1,5) = "00000"
and stuff(szF1,1,5,"     ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PUProc_Data, rev_hist..revhsth 
 where substring(szF1,1,6) = "000000"
and stuff(szF1,1,6,"      ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""

go     

--====== Update F_PUProc tables with the information from dss tables for Phase 2

--execute convertdatex \@dt, \@x output
update liberty_db..F_PUProc_Data
set szF3 = RBF_paper, 
    szF4 = convert(varchar,pickup_rec_date,112)
from liberty_db..F_PUProc_Data f, #phase2 p2
where f.szF1 = p2.szF1 and f.szF2 = p2.shipper_num

go     

--
-- Do the same update to the Rec table
--

update liberty_db..F_PUProc_Rec
set szKey3 = RBF_paper, 
    szKey4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase2 p2, liberty_db..F_PUProc_Rec f    
where f.szKey1 = p2.szF1 and f.szKey2 = p2.shipper_num

go     
exit
EOF
`;

send_alert($sqlError,"Msg",$noalert,$mail,$0,"exec proc");

$currTime = localtime();
print "Process FinTime: $currTime\n";
