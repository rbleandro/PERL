#!/usr/bin/perl 

###################################################################################
#Script:   This script converts cmf data from flat files into CPDATA1 test_cmf db #
#          Once the ETL process completes, dump is taken which gets loaded to     #
#          CPDB2, from where it gets loaded to IQ                                 #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04	Amer Khan	Originally created                                #
#11/18/04	Amer Khan	Modified to unzip file that is now received       #
#                               directly from OPS3                                #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   #print "Usage: db_growth.pl CPDATA1 cpscan \n";
#   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";
require "/opt/sybase/cron_scripts/accents";

$server = $ARGV[0];

print "\n**********Starting test_cmf load now...".localtime()."*************\n\n";

print "\n=======Disabling triggers now======".localtime()."==============\n\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
exec toggle_triggers 'd'
go
exit
EOF
`;

#***************************Starting cmfaudit bcp***********************#
print "******Starting cmfaudit bcp*******\n";

#Truncating table 
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
drop index cmfaudit.cmfaudit_idx_1
go
truncate table cmfaudit
go
exit
EOF
bcp test_cmf..cmfaudit in /tmp/cmfaudit.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfaudit.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfaudit) > 1)
CREATE INDEX cmfaudit_idx_1
ON dbo.cmfaudit(change_date_time,customer_num,file_id,field_id)
else
select "No data in table: cmfaudit"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfaudit\n\n$sqlError\n\n";

#**************************Starting cmfextra bcp***********************#
print "*****Starting cmfextra bcp******\n";

#Truncating table 
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfextra drop constraint web_cmfextra_pkey
go
truncate table cmfextra
go
exit
EOF
bcp test_cmf..cmfextra in /tmp/cmfextra.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfextra.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfextra) > 1)
ALTER TABLE cmfextra
ADD  CONSTRAINT web_cmfextra_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfextra"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfextra_new\n\n$sqlError\n\n";
#*******************************************************************************#
#}#eof of dont run the above code

#**************************Starting cmfnotes bcp***********************#
print "*****Starting cmfnotes bcp******\n";

#Truncating table 
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
drop index cmfnotes.cmfnotes_idx_1
go
truncate table cmfnotes
go
exit
EOF
bcp test_cmf..cmfnotes in /tmp/cmfnotes.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfnotes.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfnotes) > 1)
CREATE INDEX cmfnotes_idx_1
ON cmfnotes(customer_num,note_group,note_date_time)
else
select "No data in table: cmfnotes"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfnotes\n\n$sqlError\n\n";
#****************************************************************************#

#**************************Starting cmfotc bcp***********************#
print "*****Starting cmfotc bcp*****\n";

#Truncating table 
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfotc drop constraint cmfotc_pkey
go
truncate table cmfotc
go
exit
EOF
bcp test_cmf..cmfotc in /tmp/cmfotc.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfotc.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfotc) > 1)
ALTER TABLE cmfotc
ADD CONSTRAINT cmfotc_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfotc"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfotc\n\n$sqlError\n\n";

#**************************Starting cmfprice bcp***********************#
print "******Starting cmfprice bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfprice drop constraint cmfprice_pkey
go
truncate table cmfprice
go
exit
EOF
bcp test_cmf..cmfprice in /tmp/cmfprice.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfprice.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfprice) > 1)
ALTER TABLE cmfprice
ADD CONSTRAINT cmfprice_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfprice"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfprice\n\n$sqlError\n\n";

#**************************Starting cmfrates bcp***********************#
print "*****Starting cmfrates bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfrates drop constraint web_cmfrates_pkey
go
truncate table cmfrates
go
exit
EOF
bcp test_cmf..cmfrates in /tmp/cmfrates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfrates.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfrates) > 1)
ALTER TABLE cmfrates
ADD CONSTRAINT web_cmfrates_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrates"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrates\n\n$sqlError\n\n";

#**************************Starting cmfrevty bcp***********************#
print "*****Starting cmfrevty bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfrevty drop constraint web_cmfrevty_pkey
go
truncate table cmfrevty
go
exit
EOF
bcp test_cmf..cmfrevty in /tmp/cmfrevty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfrevty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfrevty) > 1)
ALTER TABLE cmfrevty
ADD CONSTRAINT web_cmfrevty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrevty"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrevty\n\n$sqlError\n\n";

#**************************Starting cmfservc bcp***********************#
print "*****Starting cmfservc bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfservc drop constraint cmfservc_pkey
go
truncate table cmfservc
go
exit
EOF
bcp test_cmf..cmfservc in /tmp/cmfservc.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfservc.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfservc) > 1)
ALTER TABLE cmfservc
ADD CONSTRAINT cmfservc_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfservc"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfservc\n\n$sqlError\n\n";

#**************************Starting cmfshipr bcp***********************#
print "*****Starting cmfshipr bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfshipr drop constraint web_cmfshipr_pkey
go
truncate table cmfshipr
go
exit
EOF
bcp test_cmf..cmfshipr in /tmp/cmfshipr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfshipr.fmt -b1000 -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfshipr) > 1)
ALTER TABLE cmfshipr
ADD CONSTRAINT web_cmfshipr_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfshipr"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfshipr\n\n$sqlError\n\n";

#**************************Starting ratecodn bcp***********************#
print "****Starting ratecodn bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table ratecodn drop constraint web_rc_pk1
go
truncate table ratecodn
go
exit
EOF
bcp test_cmf..ratecodn in /tmp/ratecodn.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ratecodn.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from ratecodn) > 1)
ALTER TABLE ratecodn
ADD CONSTRAINT web_rc_pk1
PRIMARY KEY CLUSTERED (rate_code,rate_code_alpha,service_type)
else
select "No data in table: ratecodn"
go
exit
EOF
`;

print "Messages from truncating and repopulating ratecodn\n\n$sqlError\n\n";
#**************************************************************************#
#}#eof dont run

#**************************Starting cmfclmty bcp***********************#
print "****Starting cmfclmty bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfclmty drop constraint cmfclmty_pkey
go
truncate table cmfclmty
go
exit
EOF
bcp test_cmf..cmfclmty in /tmp/cmfclmty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfclmty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfclmty) > 1)
ALTER TABLE cmfclmty
ADD CONSTRAINT cmfclmty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfclmty"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfclmty\n\n$sqlError\n\n";
#***************************************************************************#

#**************************Starting ratecodn bcp***********************#
print "****Starting ratecodn bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfcurrp drop constraint cmfcurrp_pkey
go
truncate table cmfcurrp
go
exit
EOF
bcp test_cmf..cmfcurrp in /tmp/cmfcurrp.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfcurrp.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfcurrp) > 1)
ALTER TABLE cmfcurrp
ADD CONSTRAINT cmfcurrp_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfcurrp"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfcurrp\n\n$sqlError\n\n";

#**************************Starting cmfbilto bcp***********************#
print "****Starting cmfbilto bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfbilto drop constraint cmfbilto_pkey
go
truncate table cmfbilto
go
exit
EOF
bcp test_cmf..cmfbilto in /tmp/cmfbilto.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfbilto.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfbilto) > 1)
ALTER TABLE cmfbilto
ADD CONSTRAINT cmfbilto_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfbilto"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfbilto\n\n$sqlError\n\n";

#**************************Starting cmfcodad bcp***********************#
print "****Starting cmfcodad bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfcodad drop constraint cmfcodad_pkey
go
truncate table cmfcodad
go
exit
EOF
bcp test_cmf..cmfcodad in /tmp/cmfcodad.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfcodad.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfcodad) > 1)
ALTER TABLE cmfcodad
ADD CONSTRAINT cmfcodad_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfcodad"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfcodad\n\n$sqlError\n\n";

#**************************Starting cmforvty bcp***********************#
print "****Starting cmforvty bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmforvty drop constraint cmforvty_pkey
go
truncate table cmforvty
go
exit
EOF
bcp test_cmf..cmforvty in /tmp/cmforvty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmforvty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmforvty) > 1)
ALTER TABLE cmforvty
ADD CONSTRAINT cmforvty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmforvty"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmforvty\n\n$sqlError\n\n";
#*****************************************************************************#
#}#eof dont run

#**************************Starting cmfpcsty bcp***********************#
print "******Starting cmfpcsty bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfpcsty drop constraint cmfpcsty_pkey
go
truncate table cmfpcsty
go
exit
EOF
bcp test_cmf..cmfpcsty in /tmp/cmfpcsty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfpcsty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfpcsty) > 1)
ALTER TABLE cmfpcsty
ADD CONSTRAINT cmfpcsty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfpcsty"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfpcsty\n\n$sqlError\n\n";
#***************************************************************************#

#**************************Starting cmfsales bcp***********************#
print "******Starting cmfsales bcp*******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfsales drop constraint cmfsales_pkey
go
truncate table cmfsales
go
exit
EOF
bcp test_cmf..cmfsales in /tmp/cmfsales.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfsales.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfsales) > 1)
ALTER TABLE cmfsales
ADD CONSTRAINT cmfsales_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfsales"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfsales\n\n$sqlError\n\n";

#**************************Starting cmforvty bcp***********************#
print "****Starting cmforvty bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmforvty drop constraint cmforvty_pkey
go
truncate table cmforvty
go
exit
EOF
bcp test_cmf..cmforvty in /tmp/cmforvty.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmforvty.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmforvty) > 1)
ALTER TABLE cmforvty
ADD CONSTRAINT cmforvty_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmforvty"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmforvty\n\n$sqlError\n\n";
#}#eof don't run

#**************************Starting rc_zones bcp***********************#
print "****Starting rc_zones bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table rc_zones drop constraint ground_rate_pk1
go
truncate table rc_zones
go
exit
EOF
bcp test_cmf..rc_zones in /tmp/rc_zones.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rc_zones.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from rc_zones) > 1)
ALTER TABLE rc_zones
ADD CONSTRAINT ground_rate_pk1
PRIMARY KEY CLUSTERED (zone_name,zone_version,from_fsa_1,from_fsa_2,to_fsa_1,to_fsa_2,rate_zone)
else
select "No data in table: rc_zones"
go
exit
EOF
`;

print "Messages from truncating and repopulating rc_zones\n\n$sqlError\n\n";
#**********************************************************************************************

print "****Starting pts_not_served bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table pts_not_served
go
exit
EOF
bcp test_cmf..pts_not_served in /tmp/pts_not_served.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/pts_not_served.fmt -Q
`;


print "Messages from truncating and repopulating pts_not_served\n\n$sqlError\n\n";

#**************************Starting pts_served bcp***********************#
print "****Starting pts_served bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table pts_served
go
exit
EOF
bcp test_cmf..pts_served in /tmp/pts_served.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/pts_served.fmt -Q
`;


print "Messages from truncating and repopulating pts_served\n\n$sqlError\n\n";

#**********************************************************************************************
print "****Starting srvc_times_ground bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table srvc_times_ground
go
exit
EOF
bcp test_cmf..srvc_times_ground in /tmp/srvc_times_ground.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/srvc_times_ground.fmt -Q
`;


print "Messages from truncating and repopulating srvc_times_ground\n\n$sqlError\n\n";

#**********************************************************************************************
print "****Starting srvc_times_select bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table srvc_times_select
go
exit
EOF
bcp test_cmf..srvc_times_select in /tmp/srvc_times_select.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/srvc_times_select.fmt -Q
`;


print "Messages from truncating and repopulating srvc_times_select\n\n$sqlError\n\n";
#} #end of don't run
#**********************************************************************************************
print "****Starting rate_code_names bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table rate_code_names
go
exit
EOF
bcp test_cmf..rate_code_names in /tmp/rate_code_names.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rate_code_names.fmt -Q
`;


print "Messages from truncating and repopulating rate_code_names\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run
#**********************************************************************************************
print "****Starting ara_letr bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_letr
go
exit
EOF
bcp test_cmf..ara_letr in /tmp/ara_letr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_letr.fmt -Q
`;


print "Messages from truncating and repopulating ara_letr\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_numb bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_number
go
exit
EOF
bcp test_cmf..ara_number in /tmp/ara_numb.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_numb.fmt -Q
`;


print "Messages from truncating and repopulating ara_numb\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_purs bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_purs
go
exit
EOF
bcp test_cmf..ara_purs in /tmp/ara_purs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_purs.fmt -Q -m1 -b10
`;


print "Messages from truncating and repopulating ara_purs\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_srce bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_source
go
exit
EOF
bcp test_cmf..ara_source in /tmp/ara_srce.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_srce.fmt -Q
`;


print "Messages from truncating and repopulating ara_srce\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_stmt bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_statement
go
exit
EOF
bcp test_cmf..ara_statement in /tmp/ara_stmt.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_stmt.fmt -Q
`;


print "Messages from truncating and repopulating ara_stmt\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_actn bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_action
go
exit
EOF
bcp test_cmf..ara_action in /tmp/ara_actn.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_actn.fmt -Q
`;

print "Messages from truncating and repopulating ara_actn\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_comm bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_comments
go
exit
EOF
bcp test_cmf..ara_comments in /tmp/ara_comm.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_comm.fmt -Q
`;


print "Messages from truncating and repopulating ara_comm\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run
#**********************************************************************************************
print "****Starting ara_caus bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_cause
go
exit
EOF
bcp test_cmf..ara_cause in /tmp/ara_caus.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_caus.fmt -Q
`;


print "Messages from truncating and repopulating ara_caus\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run
#**********************************************************************************************
print "****Starting ara_clrk bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_clerk
go
exit
EOF
bcp test_cmf..ara_clerk in /tmp/ara_clrk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_clrk.fmt -Q
`;


print "Messages from truncating and repopulating ara_clrk\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run

#**********************************************************************************************
print "****Starting cparf06i bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06i') AND name='cust_org_amt_nc')
BEGIN
DROP INDEX cparf06i.cust_org_amt_nc
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06i') AND name='cust_org_amt_nc')
PRINT '<<< FAILED DROPPING INDEX dbo.cparf06i.cust_org_amt_nc >>>'
ELSE
PRINT '<<< DROPPED INDEX dbo.cparf06i.cust_org_amt_nc >>>'
END
go   
truncate table cparf06i
go
exit
EOF
bcp test_cmf..cparf06i in /tmp/cparf06i.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cparf06i.fmt -m0 -b10000 -Q
`;

$sqlError1 = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
CREATE NONCLUSTERED INDEX cust_org_amt_nc
ON dbo.cparf06i(customer,original_amt)
go   
exit
EOF
`;

print "$sqlError1\n";
print "Messages from truncating and repopulating cparf06i\n\n$sqlError\n\n";
#**********************************************************************************************
#} # eof dont run

#**********************************************************************************************
print "****Starting cparf06p bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06p') AND name='cust_nc')
BEGIN
DROP INDEX cparf06p.cust_nc
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID('dbo.cparf06p') AND name='cust_nc')
PRINT '<<< FAILED DROPPING INDEX dbo.cparf06p.cust_nc >>>'
ELSE
PRINT '<<< DROPPED INDEX dbo.cparf06p.cust_nc >>>'
END
go   
truncate table cparf06p
go
exit
EOF
bcp test_cmf..cparf06p in /tmp/cparf06p.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cparf06p.fmt -m0 -b10000 -Q
`;

$sqlError1 = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
CREATE NONCLUSTERED INDEX cust_nc
ON dbo.cparf06p(customer,invoice_date)
go   
exit
EOF
`;

print "$sqlError1\n";

print "Messages from truncating and repopulating cparf06p\n\n$sqlError\n\n";
#**********************************************************************************************

if (1==2){ #The following tables does not need to run every day
#**************************Starting cmfrev98 bcp***********************#
print "*****Starting cmfrev98 bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfrev98 drop constraint web_cmfrev98_pkey
go
truncate table cmfrev98
go
exit
EOF
bcp test_cmf..cmfrev98 in /tmp/cmfrev98.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfrev98.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfrev98) > 1)
ALTER TABLE cmfrev98
ADD CONSTRAINT web_cmfrev98_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrev98"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrev98\n\n$sqlError\n\n";
#*************************************************************************************
#} #eof dont run
#**************************Starting cmfpcs03 bcp***********************#
print "******Starting cmfpcs03 bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfpcs03 drop constraint cmfpcs03_pkey
go
truncate table cmfpcs03
go
exit
EOF
bcp test_cmf..cmfpcs03 in /tmp/cmfpcs03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfpcs03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfpcs03) > 1)
ALTER TABLE cmfpcs03
ADD CONSTRAINT cmfpcs03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfpcs03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfpcs03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting cmfclm03 bcp***********************#
print "****Starting cmfclm03 bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfclm03 drop constraint cmfclm03_pkey
go
truncate table cmfclm03
go
exit
EOF
bcp test_cmf..cmfclm03 in /tmp/cmfclm03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfclm03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfclm03) > 1)
ALTER TABLE cmfclm03
ADD CONSTRAINT cmfclm03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfclm03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfclm03\n\n$sqlError\n\n";
#***************************************************************************

#**************************Starting cmforv03 bcp***********************#
print "****Starting cmforv03 bcp****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmforv03 drop constraint cmforv03_pkey
go
truncate table cmforv03
go
exit
EOF
bcp test_cmf..cmforv03 in /tmp/cmforv03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmforv03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmforv03) > 1)
ALTER TABLE cmforv03
ADD CONSTRAINT cmforv03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmforv03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmforv03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting cmfrev03 bcp***********************#
print "*****Starting cmfrev03 bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmfrev03 drop constraint web_cmfrev03_pkey
go
truncate table cmfrev03
go
exit
EOF
bcp test_cmf..cmfrev03 in /tmp/cmfrev03.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfrev03.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmfrev03) > 1)
ALTER TABLE cmfrev03
ADD CONSTRAINT web_cmfrev03_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmfrev03"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmfrev03\n\n$sqlError\n\n";
#**********************************************************************************************

#**************************Starting flashf00 bcp***********************#
print "*****Starting flashf00 bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table flashf00
go
exit
EOF
bcp test_cmf..flashf00 in /tmp/flashf00.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/flashf00.fmt -Q
`;

print "Messages from truncating and repopulating flashf00\n\n$sqlError\n\n";
#**********************************************************************************************
#}#eof dont run

#**************************Starting flashtbl bcp***********************#
print "*****Starting flashtbl bcp******\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table flashtbl
go
exit
EOF
bcp test_cmf..flashtbl in /tmp/flashtbl.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/flashtbl.fmt -Q
`;

print "Messages from truncating and repopulating flashtbl\n\n$sqlError\n\n";
#**********************************************************************************************
}#eof dont run...The tables above do not need to be loaded every day!!!

#**********************************************************************************************
print "****Starting rurpers bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table rurpers
go
exit
EOF
bcp test_cmf..rurpers in /tmp/rurpers.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rurpers.fmt -Q
`;

print "Messages from truncating and repopulating rurpers\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run
#**********************************************************************************************
print "****Starting cmf_baudit_hdr bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmf_baudit_hdr
go
exit
EOF
bcp test_cmf..cmf_baudit_hdr in /tmp/cmf_baudit_hdr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmf_baudit_hdr.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating cmf_baudit_hdr\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run
#**************************Starting rc_rates bcp***********************#
print "****Starting rc_rates bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table rc_rates drop constraint rc_rates_pk
go
truncate table rc_rates
go
exit
EOF
bcp test_cmf..rc_rates in /tmp/rc_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rc_rates.fmt -m0 -b10000 -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from rc_rates) > 1)
ALTER TABLE rc_rates
ADD CONSTRAINT rc_rates_pk
PRIMARY KEY CLUSTERED (rate_name,KorL,version,weight,sm_flag,zone)
else
select "No data in table: rc_rates"
go
exit
EOF
`;

print "Messages from truncating and repopulating rc_rates\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting cmf_baudit_dtls bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmf_baudit_dtls
go
exit
EOF
bcp test_cmf..cmf_baudit_dtls in /tmp/cmf_baudit_dtls.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmf_baudit_dtls.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating cmf_baudit_dtls\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting cmf_change_reqs bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmf_change_reqs
go
exit
EOF
bcp test_cmf..cmf_change_reqs in /tmp/cmf_change_reqs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmf_change_reqs.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating cmf_change_reqs\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting cmf_security bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmf_security
go
exit
EOF
bcp test_cmf..cmf_security in /tmp/cmf_security.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmf_security.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating cmf_security\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tddate bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tddate
go
exit
EOF
bcp test_cmf..tddate in /tmp/tddate.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tddate.fmt -m0 -b10000 -Q > /tmp/tddate.out
`;

print "Messages from truncating and repopulating tddate\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tmtrace bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tmtrace
go
exit
EOF
bcp test_cmf..tmtrace in /tmp/tmtrace.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tmtrace.fmt -m100 -b1000 -Q
`;

print "Messages from truncating and repopulating tmtrace\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tyclaim bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tyclaim
go
exit
EOF
bcp test_cmf..tyclaim in /tmp/tyclaim.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tyclaim.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tyclaim\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tppack bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tppack
go
exit
EOF
bcp test_cmf..tppack in /tmp/tppack.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tppack.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tppack\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tmtraceadd bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tmtraceadd
go
exit
EOF
bcp test_cmf..tmtraceadd in /tmp/tmtraceadd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tmtraceadd.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tmtraceadd\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting txpost bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table txpost
go
exit
EOF
bcp test_cmf..txpost in /tmp/txpost.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/txpost.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating txpost\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tbcall bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tbcall
go
exit
EOF
bcp test_cmf..tbcall in /tmp/tbcall.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tbcall.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating tbcall\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting t3rdprt bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table t3rdprt
go
exit
EOF
bcp test_cmf..t3rdprt in /tmp/t3rdprt.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/t3rdprt.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating t3rdprt\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting trace_operator bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table trace_operator
go
exit
EOF
bcp test_cmf..trace_operator in /tmp/trace_operator.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/trace_operator.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating trace_operator\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting trcl_comments bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table trcl_comments
go
exit
EOF
bcp test_cmf..trcl_comments in /tmp/trcl_comments.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/trcl_comments.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating trcl_comments\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting tspecil bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table tspecil
go
exit
EOF
bcp test_cmf..tspecil in /tmp/tspecil.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/tspecil.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating tspecil\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting flash_master bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table flash_master
go
exit
EOF
bcp test_cmf..flash_master in /tmp/flash_master.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/flash_master.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating flash_master\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting rsaltlnk bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table rsaltlnk
go
exit
EOF
bcp test_cmf..rsaltlnk in /tmp/rsaltlnk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rsaltlnk.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating rsaltlnk\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run

#**********************************************************************************************
print "****Starting rateschd bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table rateschd
go
exit
EOF
bcp test_cmf..rateschd in /tmp/rateschd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rateschd.fmt -m0 -b1 -Q
`;

print "Messages from truncating and repopulating rateschd\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting sales_commitment bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table sales_commitment
go
exit
EOF
bcp test_cmf..sales_commitment in /tmp/sales_commitment.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/sales_commitment.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating sales_commitment\n\n$sqlError\n\n";
#**********************************************************************************************
#} #eof dont run
#**************************Starting rc_zwdisc bcp***********************#
print "****Starting rc_zwdisc bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table rc_zwdisc drop constraint rc_zwdisc_pk
go
truncate table rc_zwdisc
go
exit
EOF
bcp test_cmf..rc_zwdisc in /tmp/rc_zwdisc.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rc_zwdisc.fmt -m0 -b30000 -Q > /tmp/rc_zwdisc.out
tail -2 /tmp/rc_zwdisc.out
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from rc_zwdisc) > 1)
ALTER TABLE rc_zwdisc
ADD CONSTRAINT rc_zwdisc_pk
PRIMARY KEY CLUSTERED (rate_name,version,weight,sm_flag,zone)
else
select "No data in table: rc_zwdisc"
go
exit
EOF
`;

print "Messages from truncating and repopulating rc_zwdisc\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ara_mstr bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ara_mstr
go
exit
EOF
bcp test_cmf..ara_mstr in /tmp/ara_mstr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ara_mstr.fmt -Q -m0 -b1000
`;


print "Messages from truncating and repopulating ara_mstr\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting cmfextra2 bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmfextra2
go
exit
EOF
bcp test_cmf..cmfextra2 in /tmp/cmfextra2.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfextra2.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating cmfextra2\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting corporate_lines bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table corporate_lines
go
exit
EOF
bcp test_cmf..corporate_lines in /tmp/corporate_lines.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/corporate_lines.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating corporate_lines\n\n$sqlError\n\n";
#**********************************************************************************************
##**********************************************************************************************
#print "****Starting costing_residential bcp*****\n";
#
#open (BCPFILE,">/tmp/costing_residential.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/test_cmf/asa/COSTING_RESI.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
#
##   $_ =~ s/^\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
#use test_cmf
#go
#truncate table costing_residential
#go
#exit
#EOF
#bcp test_cmf..costing_residential in /tmp/costing_residential.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/costing_residential.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating costing_residential\n\n$sqlError\n\n";
##**********************************************************************************************

##**********************************************************************************************
#print "****Starting costing_import_list bcp*****\n";
#
#open (BCPFILE,">/tmp/costing_import_list.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/test_cmf/asa/COSTING_IMP_LIST.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
#
##   $_ =~ s/^\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
#use test_cmf
#go
#truncate table costing_import_list
#go
#exit
#EOF
#bcp test_cmf..costing_import_list in /tmp/costing_import_list.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/costing_import_list.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating costing_import_list\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting qmaparms bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table qmaparms
go
exit
EOF
bcp test_cmf..qmaparms in /tmp/qmaparms.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/qmaparms.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating qmaparms\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting quotater and qt_period bcp*****\n";

#Truncating tables
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table quotater
go
truncate table qt_period
go
exit
EOF
bcp test_cmf..quotater in /tmp/quotater.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/quotater.fmt -m0 -b100 -Q
bcp test_cmf..qt_period in /tmp/qt_period.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/qt_period.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating quotater\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
#print "****Starting interline_costs bcp*****\n";
#
#open (BCPFILE,">/tmp/interline_costs.dat") || print "cannot create $!\n";
#open (INFILE,"</opt/sybase/test_cmf/IL_COSTS.TXT") || print "cannot open: $!\n";
#
#while (<INFILE>){
##last;
##   $_ =~ s/^\d\d\d,//;
#   $_ =~ s/\0/ /g; #Control characters to be taken out
#   $_ =~ s/\r$//;
#   $_ =~ s/\n$//;
#   $_ =~ s/\r/ /g;
#   $_ =~ s/\n/ /g;
#   $_ = $_."\n";
#
#
#####################################################
#
#print BCPFILE $_;
#
#}#eof while loop
#
#close BCPFILE;
#close INFILE;
#
##Truncating table
#$sqlError = `isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
#use test_cmf
#go
#truncate table interline_costs
#go
#exit
#EOF
#bcp test_cmf..interline_costs in /tmp/interline_costs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/interline_costs.fmt -m0 -b100 -Q
#`;
#
#print "Messages from truncating and repopulating interline_costs\n\n$sqlError\n\n";
#**********************************************************************************

#**********************************************************************************************
print "****Starting interline_carriers bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table interline_carriers
go
exit
EOF
bcp test_cmf..interline_carriers in /tmp/interline_carriers.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/interline_carriers.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating interline_carriers\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting misc_charges_hist bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table misc_charges_hist
go
exit
EOF
bcp test_cmf..misc_charges_hist in /tmp/misc_charges_hist.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/misc_charges_hist.fmt -m0 -b10000 -Q
`;

print "Messages from truncating and repopulating misc_charges_hist\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting rsaltlnk bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table rsaltlnk
go
exit
EOF
bcp test_cmf..rsaltlnk in /tmp/rsaltlnk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/rsaltlnk.fmt -m0 -b100 -Q
`;

print "Messages from truncating and repopulating rsaltlnk\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting ZWDISCG bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table ZWDISCG
go
exit
EOF
bcp test_cmf..ZWDISCG in /tmp/ZWDISCG.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/ZWDISCG.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating ZWDISCG\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting cmfstore bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmfstore
go
exit
EOF
bcp test_cmf..cmfstore in /tmp/cmfstore.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmfstore.fmt -m0 -b1000 -Q
`;

print "Messages from truncating and repopulating cmfstore\n\n$sqlError\n\n";
#**********************************************************************************************

#**********************************************************************************************
print "****Starting cmforgnl bcp*****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
truncate table cmforgnl
go
exit
EOF
bcp test_cmf..cmforgnl in /tmp/cmforgnl.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmforgnl.fmt -m2 -b1 -Q -e./errfile
`;

print "Messages from truncating and repopulating cmforgnl\n\n$sqlError\n\n";
#**********************************************************************************************

#Truncating table 
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
drop index cmnnotes.cmnnotes_idx_1
go
truncate table cmnnotes
go
exit
EOF
bcp test_cmf..cmnnotes in /tmp/cmnnotes.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnnotes.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnnotes) > 1)
CREATE INDEX cmnnotes_idx_1
ON cmnnotes(customer_num,note_group,note_date_time)
else
select "No data in table: cmnnotes"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnnotes\n\n$sqlError\n\n";
#****************************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnprice drop constraint cmnprice_pkey
go
truncate table cmnprice
go
exit
EOF
bcp test_cmf..cmnprice in /tmp/cmnprice.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnprice.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnprice) > 1)
ALTER TABLE cmnprice
ADD CONSTRAINT cmnprice_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnprice"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnprice\n\n$sqlError\n\n";
#*****************************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnrates drop constraint web_cmnrates_pkey
go
truncate table cmnrates
go
exit
EOF
bcp test_cmf..cmnrates in /tmp/cmnrates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnrates.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnrates) > 1)
ALTER TABLE cmnrates
ADD CONSTRAINT web_cmnrates_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnrates"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnrates\n\n$sqlError\n\n";
#**********************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnservc drop constraint cmnservc_pkey
go
truncate table cmnservc
go
exit
EOF
bcp test_cmf..cmnservc in /tmp/cmnservc.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnservc.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnservc) > 1)
ALTER TABLE cmnservc
ADD CONSTRAINT cmnservc_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnservc"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnservc\n\n$sqlError\n\n";
#**********************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnshipr drop constraint web_cmnshipr_pkey
go
truncate table cmnshipr
go
exit
EOF
bcp test_cmf..cmnshipr in /tmp/cmnshipr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnshipr.fmt -m0 -b1 -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnshipr) > 1)
ALTER TABLE cmnshipr
ADD CONSTRAINT web_cmnshipr_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnshipr"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnshipr\n\n$sqlError\n\n";
#*****************************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnbilto drop constraint cmnbilto_pkey
go
truncate table cmnbilto
go
exit
EOF
bcp test_cmf..cmnbilto in /tmp/cmnbilto.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnbilto.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnbilto) > 1)
ALTER TABLE cmnbilto
ADD CONSTRAINT cmnbilto_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnbilto"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnbilto\n\n$sqlError\n\n";
#***************************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnsales drop constraint cmnsales_pkey
go
truncate table cmnsales
go
exit
EOF
bcp test_cmf..cmnsales in /tmp/cmnsales.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnsales.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnsales) > 1)
ALTER TABLE cmnsales
ADD CONSTRAINT cmnsales_pkey
PRIMARY KEY NONCLUSTERED (customer_num)
else
select "No data in table: cmnsales"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnsales\n\n$sqlError\n\n";
#******************************************************************************#

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
alter table cmnndata drop constraint cmnndata_pkey
go
truncate table cmnndata
go
exit
EOF
bcp test_cmf..cmnndata in /tmp/cmnndata.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -f/opt/sybase/bcp_data/test_cmf/cmnndata.fmt -Q
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
if((select count(*) from cmnndata) > 1)
ALTER TABLE cmnndata
ADD CONSTRAINT cmnndata_pkey
PRIMARY KEY NONCLUSTERED (customer)
else
select "No data in table: cmnndata"
go
exit
EOF
`;

print "Messages from truncating and repopulating cmnndata\n\n$sqlError\n\n";
#***************************************************************************#

print "\n=======Enabling triggers now======".localtime()."==============\n\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -w300 <<EOF 2>&1
use test_cmf
go
exec toggle_triggers 'e'
go
exit
EOF
`;

print "\n\ntest_cmf conversion and load to test_cmf completed...".localtime()."\n\n";

#**********************************************************************************************

