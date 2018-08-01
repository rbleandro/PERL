#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Note:     This script updates the Liberty Scanned Pickup Record database    #
#          tables 'F_PU200704_Data' and 'F_PU200704_Rec' from Revenue History#
#          data                                                              #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 23 07	Amer Khan	Originally created                           #
#                                                                            #
##############################################################################
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

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
#$startHour=sprintf('%02d',((localtime())[6]));
$startHour=substr($currTime,0,3);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute liberty_update
#
print "***Initiating liberty_update At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Urhload -P\`/opt/sybase/cron_scripts/getpass.pl rhload\` -S$prodserver -b -n<<EOF 2>&1
declare \@days int
select \@days = 20
select \@days = \@days * -1

select szF1, shipper_num, RBF_paper, pickup_rec_date into #phase1
from liberty_db..F_PU200704_Data, rev_hist..revhsth where 1=2

insert #phase1
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
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
from liberty_db..F_PU200704_Data, rev_hist..revhsth
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
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,1) = "0"
and stuff(szF1,1,1," ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth 
 where substring(szF1,1,2) = "00"
and stuff(szF1,1,2,"  ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date 
 from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,3) = "000"
and stuff(szF1,1,3,"   ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,4) = "0000"
and stuff(szF1,1,4,"    ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,5) = "00000"
and stuff(szF1,1,5,"     ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,6) = "000000"
and stuff(szF1,1,6,"      ") = pickup_rec_num 
and data_entry_date > dateadd(day, \@days, getdate())
and substring(RBF_paper,5,1) < "5"
and (szF2 = "" or szF2 is null)

go     

--====== Update F_PUProc tables with the information from dss tables for phase 1

--execute convertdatex \@dt, \@x output
update liberty_db..F_PU200704_Data
set szF2 = shipper_num, 
    szF3 = RBF_paper, 
    szF4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase1 p1, liberty_db..F_PU200704_Data f
where f.szF1 = p1.szF1

go     
--select * from #phase1
--
-- Do the same update to the Rec table
--
update liberty_db..F_PU200704_Rec
set szKey2 = shipper_num, 
    szKey3 = RBF_paper, 
    szKey4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase1 p1, liberty_db..F_PU200704_Rec f
where f.szKey1 = p1.szF1

go     

--==========Inintiating Phase 2
select szF1, shipper_num, RBF_paper, pickup_rec_date into #phase2 
from liberty_db..F_PU200704_Data, rev_hist..revhsth where 1=2
go     
insert #phase2
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where szF1 = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where char_length(szF1) = 6 
and pickup_rec_num = " " + szF1
and szF2 = shipper_num
and szF3 = ""
union    
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,1) = "0"
and stuff(szF1,1,1," ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,2) = "00"
and stuff(szF1,1,2,"  ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,3) = "000"
and stuff(szF1,1,3,"   ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,4) = "0000"
and stuff(szF1,1,4,"    ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth
where substring(szF1,1,5) = "00000"
and stuff(szF1,1,5,"     ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""
union
select szF1, shipper_num, RBF_paper, pickup_rec_date
from liberty_db..F_PU200704_Data, rev_hist..revhsth 
 where substring(szF1,1,6) = "000000"
and stuff(szF1,1,6,"      ") = pickup_rec_num
and szF2 = shipper_num
and szF3 = ""

go     

--====== Update F_PUProc tables with the information from dss tables for Phase 2

--execute convertdatex \@dt, \@x output
update liberty_db..F_PU200704_Data
set szF3 = RBF_paper, 
    szF4 = convert(varchar,pickup_rec_date,112)
from liberty_db..F_PU200704_Data f, #phase2 p2
where f.szF1 = p2.szF1 and f.szF2 = p2.shipper_num

go     

--
-- Do the same update to the Rec table
--

update liberty_db..F_PU200704_Rec
set szKey3 = RBF_paper, 
    szKey4 = convert(varchar,pickup_rec_date,112)
--select *    
from #phase2 p2, liberty_db..F_PU200704_Rec f    
where f.szKey1 = p2.szF1 and f.szKey2 = p2.shipper_num

go     
exit
EOF
`;
print $sqlError."\n";
#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "Messages From liberty_update...\n";
      print "$sqlError\n";
}
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Liberty_update for 200704 table

$sqlError
EOF
`;

