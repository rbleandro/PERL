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

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\`  -b -n<<EOF 2>&1
use rev_hist_lm
go
set nocount on
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

-- -- Step 0:   (Status Check, Make Sure that revhist tables are loaded ad arinvage is done )
declare \@cnt int, \@max_cnt int
select \@cnt=0, \@max_cnt=2000
while (\@cnt < \@max_cnt)
begin
    if ((select 1 from cmf_data_lm..invoicing_status_checks where resource = 'rv_tables' and processed_date = convert(date, getdate())) = (select 1 from cmf_data_lm..invoicing_status_checks where resource = 'arinvage' and processed_date = convert(date, getdate())))
    begin
     select 'We are clear to proceed...'
     break
    end
    
    waitfor delay "00:00:10"
    select \@cnt = \@cnt + 1
    if (\@cnt = \@max_cnt)
    begin
     select 'rv_tables or arinvage not finished yet'
    end

end
go

exit

EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /rv_tables or arinvage not finished yet/ || $sqlError =~ /error/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - Check invoicing_status_checks table

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in Step 0, which must be resolved. Errored out  at $currTime \n";
}
else
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: COMPLETE - executing Step 0

All data is available, we can proceed with Step 1
Proceeding with next steps on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\`  -b -n<<EOF 2>&1
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

-- -- Step 1:   (Report )
---------------------------
print 'Running lm_inv_balancing_rpt invoice_date, PMS'
execute lm_inv_balancing_rpt \@invoice_date, 'PMS'
if (\@\@error <> 0)
Begin
print 'Errors occurred lm_inv_balancing_rpt invoice_date, PMS'
End

execute lm_inv_pre_balance_rpt_selfinvoice  \@invoice_date
if (\@\@error = 0)
execute lm_inv_pre_balancing_rpt_pms   \@invoice_date
else 
Begin
print 'Errors occurred'
End

if (\@\@error = 0)
execute lm_inv_pre_balancing_rpt_simon   \@invoice_date
else
Begin
print 'Errors occurred'
End

if (\@\@error = 0)
execute lm_inv_balancing_rpt \@invoice_date,'Before'
else
Begin
print 'Errors occurred'
End


if (\@\@error = 0)
begin -- No error in lm_inv_pre_balancing_rpt
  if ((select self_invoice_total + grand_total_pms from invoice_balancing where invoice_date=\@invoice_date  and step = 1 ) = (select self_invoice_total + grand_total_pms from invoice_balancing where invoice_date=\@invoice_date  and step = 2))
 begin -- Totals Match
   select "we are good"
 end
 else
 begin -- Total Do NOT Match
   declare \@totals_value float(12)
   select \@totals_value = ((select self_invoice_total + grand_total_pms from invoice_balancing where invoice_date=\@invoice_date  and step = 1) - 
                            (select self_invoice_total + grand_total_pms from invoice_balancing where invoice_date=\@invoice_date  and step = 2))   
   -- Check the difference and if it is not more than 1000 and not less than 100 then, still proceed.
   if (\@totals_value <= 1000 and \@totals_value >= -100)
    begin
       select "We are off, but still proceeding", \@totals_value
    end
   else
    begin
       select "Totals Match Error", \@totals_value
    end
 
 end

end -- No error in lm_inv_pre_balancing_rpt
else
begin -- Errors in Step1
  select "Step 1 Errors"
end
go

exit

EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /Totals Match Error|Step 1 Errorso|Errors occurred/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - In Either Totals Match or Step 1

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in Step 1, which must be resolved. Errored out  at $currTime \n";
}
else
{
 if ($sqlError =~ /We are off/){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: WE ARE OFF BUT PROCEEDING to next step

Proceeding with next steps on $currTime

$sqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: COMPLETE - executing Step 1

Proceeding with next steps on $currTime
$sqlError
EOF
`;
}
}

$currTime = localtime();
print "Step 1 FinTime: $currTime\n";


$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\`  -b -n<<EOF 2>&1
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

-- Step 2 : Detemine Bill period and Transfer Data to Work Table
-----------------------------------
execute lm_inv_work_creation  \@invoice_date
if (\@\@error = 0)

-- Step 3 :  (Report Before Assigning invoice numbers )
------------------------------------
execute lm_inv_rpt_balance_before   \@invoice_date
else 
Begin
print 'Error occurred'

End
if (\@\@error = 0)
Begin
-- Step 4: Assign Invoice Numbers
-----------------------------------
execute lm_inv_cal_weeklypickup_charge  \@invoice_date
execute lm_inv_assign_invnumber   \@invoice_date
End
else 
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_cal_invoiceprintcharge \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_cal_manualwaybill_charge  \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_update_invoice_threshold  \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

-- Step 5:  (Report After Assigning invoice numbers )
----------------------------------
execute lm_inv_rpt_balance_after   \@invoice_date
else 
Begin
print 'Error occurred'

End

if (\@\@error = 0)

-- Step 6:  Update Modified Data
-----------------------------------------------
execute lm_inv_update_revhst  \@invoice_date
else
Begin
print 'Error occurred'

End

if (\@\@error = 0)

execute lm_inv_last_balance_rpt_selfinvoice \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_last_balance_rpt_total_billed   \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_last_balance_rpt_total_unbilled  \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)

execute lm_inv_last_balance_rpt_total  \@invoice_date
else
Begin
print 'Error occurred'

End
if (\@\@error = 0)
execute lm_inv_balancing_rpt \@invoice_date, 'After'
else
Begin
print 'Error occurred'

End


if (\@\@error = 0)
begin -- No error in lm_inv_pre_balancing_rpt
  if ((select total_revenue_without_pimw from invoice_balancing where invoice_date=\@invoice_date  and step = 2 ) = (select total_revenue_without_pimw from invoice_balancing where invoice_date=\@invoice_date  and step = 3))
 begin -- Totals Match
   select "we are good"
 end
 ELSE
 begin --- totals did not match
   select "Totals Match Error"
 end
end -- No error in lm_inv_pre_balancing_rpt
else
begin -- Errors in Step2
  select "Step 2 Errors"
end
go

exit

EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /Totals Match Error|Step 2 Errors|Errors occurred/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: ERROR - In Either Totals Match or Step 2

Following status was received during preinvoice that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in Step 2, which must be resolved. Errored out  at $currTime \n";
}
else
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,kkotur\@canpar.com
Subject: COMPLETE - executing Step 2

Proceeding with next steps on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();
print "Step 2 FinTime: $currTime\n";


$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\`  -b -n<<EOF 2>&1
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
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\`  -b -n<<EOF 2>&1
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


