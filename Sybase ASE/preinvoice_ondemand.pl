#!/usr/bin/perl -w

##############################################################################
#Description	This job will run preinvoice and email results to concerned  #
#		people.                                                      #
#Author:    	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#May 16 2014	Amer Khan 	Originally created                           #
#                                                                            #
##############################################################################

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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));


print "Preinvoicing StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\`  -b -n<<EOF 2>&1
use rev_hist_lm
go
declare \@invoice_date date
-- Go to last Friday's date
declare \@day_cnt int
select \@day_cnt = 0
while (datepart(dw,dateadd(dd,\@day_cnt,getdate())) <> 6)
Begin
select \@day_cnt = \@day_cnt - 1
select datepart(dw,dateadd(dd,\@day_cnt,getdate()))
end
select \@invoice_date = dateadd(dd,\@day_cnt,getdate())

select 'Invoice Date Is: ', \@invoice_date

if (\@\@error = 0)


execute lm_inv_update_cparf06i  \@invoice_date
else 
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_create_preinvoice  \@invoice_date
else 
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_balancing_rpt \@invoice_date, 'cparf06i'
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_balancing_rpt \@invoice_date,'revhsti_preinvoice'
else
Begin
print 'Error occurred'

End

if (\@\@error = 0)
begin -- No error in lm_inv_pre_balancing_rpt
  if ((select total_billed_revenue from invoice_balancing where invoice_date=\@invoice_date  and step = 3 ) = (select total_billed_revenue from invoice_balancing where invoice_date=\@invoice_date  and step = 4)) and ((select total_billed_revenue from invoice_balancing where invoice_date=\@invoice_date  and step = 4 ) = (select total_billed_revenue from invoice_balancing where invoice_date=\@invoice_date  and step = 5))
 begin -- Totals Match
   select "we are good"
 end
 else
 begin
  select "Totals Match Error"
 end
end -- No error in lm_inv_pre_balancing_rpt
else
begin -- Errors in Step2
  select "Step 4,5 Errors"
end
go

go
exit
EOF
`;
print $sqlError."\n";


if($sqlError =~ /Totals Match Error|Error occurred|Msg|Step 4,5 Errors/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - executing Step 5 Thru Step 7

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in Step 5 - Step 7 found at $currTime \n";
}
else
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com,adrysdale\@canpar.com, FORourke\@canpar.com
Subject: COMPLETE - Step 5 Thru Step 7

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\`  -b -n<<EOF 2>&1
use rev_hist_lm
go
declare \@invoice_date date
-- Go to last Friday's date
declare \@day_cnt int
select \@day_cnt = 0
while (datepart(dw,dateadd(dd,\@day_cnt,getdate())) <> 6)
Begin
select \@day_cnt = \@day_cnt - 1
select datepart(dw,dateadd(dd,\@day_cnt,getdate()))
end
select \@invoice_date = dateadd(dd,\@day_cnt,getdate())

select 'Invoice Date Is: ', \@invoice_date

-- Step 8 : Generate Report and Send it to all
select invoice_date,step,step_descr,self_invoice_total,pms_invoice_total,pms_unbilled_total,grand_total_pms,
simon_invoice_total,simon_unbilled_total,simon_pi_mw_total,grand_total_simon,total_revenue_without_pimw,
total_billed_revenue,total_unbilled_revenue,total_revenue
from invoice_balancing where invoice_date=\@invoice_date order by invoice_date , step
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - executing preinvoice

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this preinvoice at $currTime \n";
}
else
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,adrysdale\@canpar.com, FORourke\@canpar.com, KKotur\@canpar.com
Subject: COMPLETE - Generting PreInvoice Totals Report

Following status was received during preinvoice that started on $currTime
================================================
$sqlError
================================================
EOF
`;
}


$currTime = localtime();
print "preinvoicing FinTime: $currTime\n";


