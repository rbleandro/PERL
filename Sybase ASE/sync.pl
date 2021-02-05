#!/usr/bin/perl
###################################################################################
#Script:   This script will count the rows in Production & IQ tables.             #
#          It will send an email if there is sync issue between                   #
#          Production and IQ Tables                                               #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date   Sep 6, 2006           Name               Description                      #
#---------------------------------------------------------------------------------#
#11/01/07      Ahsan Ahmed      Modified                                          #
###################################################################################

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

#if (1==2){
#######################################################
#    tttl_ac_address_correction
#######################################################
$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ac_address_correction'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prac = $list[1];

print "Here is the record_count: $prac  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ac_address_correction
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqac = $list[1];

print "Here is the IQ record_count: $iqac  \n";

##################################################
#    tttl_batchdown
##################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_batchdown'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prbd = $list[1];

print "Here is the record_count: $prbd  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_batchdown
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqbd = $list[1];

print "Here is the IQ record_count: $iqbd  \n";

#####################################################
#        tttl_bi_bulk_inbound
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_bi_bulk_inbound'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prbi = $list[1];

print "Here is the record_count: $prbi  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_bi_bulk_inbound
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqbi = $list[1];

print "Here is the IQ record_count: $iqbi  \n";

#####################################################
#        tttl_cp_cod_package
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_cp_cod_package'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prcp = $list[1];

print "Here is the record_count: $prbi  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_cp_cod_package
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqcp = $list[1];

print "Here is the IQ record_count: $iqbi  \n";

#####################################################
#        tttl_ct_cod_totals
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ct_cod_totals'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prct = $list[1];

print "Here is the record_count: $prct  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ct_cod_totals
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqct = $list[1];

print "Here is the IQ record_count: $iqct  \n";

#####################################################
#        tttl_dc_delivery_comment
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_dc_delivery_comment'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdc = $list[1];

print "Here is the record_count: $prdc  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_dc_delivery_comment
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdc = $list[1];

print "Here is the IQ record_count: $iqdc  \n";

#####################################################
#        tttl_dex_dlry_cross_ref
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_dex_dlry_cross_ref'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdex = $list[1];

print "Here is the record_count: $prdex  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_dex_dlry_cross_ref
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdex = $list[1];

print "Here is the IQ record_count: $iqdex  \n";

#####################################################
#        tttl_dr_delivery_record
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_dr_delivery_record'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdr = $list[1];

print "Here is the record_count: $prdr  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_dr_delivery_record
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdr = $list[1];

print "Here is the IQ record_count: $iqdr \n";

#####################################################
#        tttl_ev_event
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ev_event'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prev = $list[1];

print "Here is the record_count: $prev  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ev_event  WHERE updated_on_cons > 'Jan 1 2006 00:00:00'
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqev = $list[1];

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ev_event_inserts
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqevin = $list[1];

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ev_event_deletes
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqevde = $list[1];

$iqevtotal=$iqev+$iqevin-$iqevde;
print "Here is the IQ tttl_ev_events record_count: $iqev \n";
#####################################################
#        tttl_ex_exception_comment
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ex_exception_comment'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prex = $list[1];

print "Here is the record_count: $prex  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ex_exception_comment
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqex = $list[1];

print "Here is the IQ record_count: $iqex \n";

#####################################################
#        tttl_fl_fuel
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_fl_fuel'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prfl = $list[1];

print "Here is the record_count: $prfl  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_fl_fuel
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqfl = $list[1];

print "Here is the IQ record_count: $iqfl \n";

#####################################################
#         tttl_hc_hub_cod
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_hc_hub_cod'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhc = $list[1];

print "Here is the record_count: $prhc  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_hc_hub_cod
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhc = $list[1];

print "Here is the IQ record_count: $iqhc \n";

#####################################################
#        tttl_hv_high_value
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_hv_high_value'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhv = $list[1];

print "Here is the record_count: $prhv  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_hv_high_value
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhv = $list[1];

print "Here is the IQ record_count: $iqhv \n";

#####################################################
#        tttl_id_driver_route_id
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_id_driver_route_id'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prid = $list[1];

print "Here is the record_count: $prid  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_id_driver_route_id
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqid = $list[1];

print "Here is the IQ record_count: $iqid \n";

#####################################################
#        tttl_ii_interline_inbound
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ii_interline_inbound'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prii = $list[1];

print "Here is the record_count: $prii  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ii_interline_inbound
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqii = $list[1];

print "Here is the IQ record_count: $iqii \n";

#####################################################
#        tttl_incompat
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_incompat'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$princompat = $list[1];

print "Here is the record_count: $princompat  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_incompat
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqincompat = $list[1];

print "Here is the IQ record_count: $iqincompat \n";

#####################################################
#        tttl_io_interline_outbound
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_io_interline_outbound'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prio = $list[1];

print "Here is the record_count: $prio  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_io_interline_outbound
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqio = $list[1];

print "Here is the IQ record_count: $iqio \n";

#####################################################
#        tttl_lo_linehaul_outbound
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_lo_linehaul_outbound'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prlo = $list[1];

print "Here is the record_count: $prlo  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_lo_linehaul_outbound
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqlo = $list[1];

print "Here is the IQ record_count: $iqlo \n";


#####################################################
#        tttl_ma_COD
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ma_COD'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmac = $list[1];

print "Here is the record_count: $prmac  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_COD
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmac = $list[1];

print "Here is the IQ record_count: $iqmac \n";


#####################################################
#        tttl_ma_barcode
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ma_barcode'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmab = $list[1];

print "Here is the record_count: $prmab  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_barcode
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmab = $list[1];

print "Here is the IQ record_count: $iqmab \n";

#####################################################
#        tttl_ma_document
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ma_document'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmad = $list[1];

print "Here is the record_count: $prmad  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_document
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmad = $list[1];

print "Here is the IQ record_count: $iqmad \n";

#####################################################
#        tttl_ma_manifest
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select count(*) from tttl_ma_insert_live_iq_vw
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmam = $list[1];

print "Here is the record_count: $prmam  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_live
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmam = $list[1];

print "Here is the IQ record_count: $iqmam \n";

#####################################################
#        tttl_ma_other
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ma_other'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmao = $list[1];

print "Here is the record_count: $prmam  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_other
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmao = $list[1];

print "Here is the IQ record_count: $iqmao \n";

#####################################################
#        tttl_ma_shipment
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ma_shipment'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmas = $list[1];

print "Here is the record_count: $prmas  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ma_shipment
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmas = $list[1];

print "Here is the IQ record_count: $iqmas \n";
#####################################################
#        tttl_mb_multiple_barcodes
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_mb_multiple_barcodes'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmb = $list[1];

print "Here is the record_count: $prmb  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_mb_multiple_barcodes
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmb = $list[1];

print "Here is the IQ record_count: $iqmb \n";

#####################################################
#        tttl_ms_missorts
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ms_missorts'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prms = $list[1];

print "Here is the record_count: $prms  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ms_missorts
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqms = $list[1];

print "Here is the IQ record_count: $iqms \n";

#####################################################
#        tttl_or
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_or'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$pror = $list[1];

print "Here is the record_count: $pror  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_or
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqor = $list[1];

print "Here is the IQ record_count: $iqor \n";
#} # eof dont run
#####################################################
#        tttl_pa_parcel
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_pa_parcel'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prpa = $list[1];

print "Here is the record_count: $prpa  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_pa_parcel
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpa = $list[1];
$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_pa_parcel_inserts
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpain = $list[1];

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_pa_parcel_deletes
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpade = $list[1];

$iqpatotal=$iqpa+$iqpain-$iqpade;
print "Here is the IQ tttl_pa_parcel record_count: \n";
print "***************************************************
tttl_pa_parcel              (Prod): $prpa
                              (IQ): $iqpatotal
***************************************************

#\n";
#die;
#####################################################
#        tttl_pr_pickup_record
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_pr_pickup_record'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prpr = $list[1];

print "Here is the record_count: $prpr  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_pr_pickup_record
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpr = $list[1];

print "Here is the IQ record_count: $iqpr \n";

#####################################################
#        tttl_ps_pickup_shipper
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_ps_pickup_shipper'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prps = $list[1];

print "Here is the record_count: $prps  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_ps_pickup_shipper
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqps = $list[1];

print "Here is the IQ record_count: $iqps \n";

#####################################################
#        tttl_pt_pickup_totals
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_pt_pickup_totals'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prpt = $list[1];

print "Here is the record_count: $prpt  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_pt_pickup_totals
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpt = $list[1];

print "Here is the IQ record_count: $iqpt \n";

#####################################################
#        tttl_se_search
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_se_search'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prse = $list[1];

print "Here is the record_count: $prse  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_se_search
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqse = $list[1];

print "Here is the IQ record_count: $iqse \n";

#####################################################
#        tttl_sortation
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_sortation'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prsort = $list[1];

print "Here is the record_count: $prsort  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_sortation
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqsort = $list[1];

print "Here is the IQ record_count: $iqsort \n";

#####################################################
#        tttl_up_US_parcels
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_up_US_parcels'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prup = $list[1];

print "Here is the record_count: $prup  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_up_US_parcels
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqup = $list[1];

print "Here is the IQ record_count: $iqup \n";

#####################################################
#        tttl_us
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('tttl_us'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prus = $list[1];

print "Here is the record_count: $prus  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from tttl_us
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqus = $list[1];

print "Here is the IQ record_count: $iqus \n";

####################################################
#             bcxref
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('bcxref'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prxref = $list[1];

print "Here is the record_count: $prxref  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from bcxref
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqxref = $list[1];

print "Here is the IQ record_count: $iqxref \n";
####################################################
#             cwparcel
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('cwparcel_live'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prparcel = $list[1];

print "Here is the record_count: $prparcel  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from cwparcel
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqparcel = $list[1];

print "Here is the IQ record_count: $iqparcel \n";
####################################################
#             cwshipment
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('cwshipment'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prship = $list[1];

print "Here is the record_count: $prship  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from cwshipment
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqship = $list[1];

print "Here is the IQ record_count: $iqship \n";

####################################################
#             cwstudy
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('cwstudy'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prstudy = $list[1];

print "Here is the record_count: $prstudy  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from cwstudy
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqstudy = $list[1];

print "Here is the IQ record_count: $iqstudy \n";


####################################################
#             dimweight
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dimweight'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prweight = $list[1];

print "Here is the record_count: $prweight  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dimweight
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqweight = $list[1];

print "Here is the IQ record_count: $iqweight \n";

####################################################
#             revhstd
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstd'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstd = $list[1];

print "Here is the record_count: $prhstd  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstd
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstd = $list[1];

print "Here is the IQ record_count: $iqhstd \n";

####################################################
#             revhstd1
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstd1'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstd1 = $list[1];

print "Here is the record_count: $prhstd1  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstd1
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstd1 = $list[1];

print "Here is the IQ record_count: $iqhstd1 \n";

####################################################
#             revhstf
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstf'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstf = $list[1];

print "Here is the record_count: $prhstf  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstf
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstf = $list[1];

print "Here is the IQ record_count: $iqhstf \n";

####################################################
#             revhstf1
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstf1'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstf1 = $list[1];

print "Here is the record_count: $prhstf1  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstf1
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstf1 = $list[1];

print "Here is the IQ record_count: $iqhstf1 \n";


####################################################
#             revhsth
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhsth'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhsth = $list[1];

print "Here is the record_count: $prhsth  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhsth
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhsth = $list[1];

print "Here is the IQ record_count: $iqhsth \n";


####################################################
#             revhstm
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstm'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstm = $list[1];

print "Here is the record_count: $prhstm  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstm
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstm = $list[1];

print "Here is the IQ record_count: $iqhstm \n";

####################################################
#             revhstr
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstr'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstr = $list[1];

print "Here is the record_count: $prhstr  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstr
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstr = $list[1];

print "Here is the IQ record_count: $iqhstr \n";

####################################################
#             revhsts
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhsts'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhsts = $list[1];

print "Here is the record_count: $prhsts  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhsts
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhsts = $list[1];

print "Here is the IQ record_count: $iqhsts \n";

####################################################
#             revhstz
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('revhstz'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prhstz = $list[1];

print "Here is the record_count: $prhstz  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from revhstz
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqhstz = $list[1];

print "Here is the IQ record_count: $iqhstz \n";


#####################################################
#        cmfextra2
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('cmfextra2'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prex2 = $list[1];

print "Here is the record_count: $prex2  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from cmfextra2
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqex2 = $list[1];

print "Here is the IQ record_count: $iqex2  \n";

#####################################################
#         driver_stats
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('driver_stats'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdrs = $list[1];

print "Here is the record_count: $prdrs  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from driver_stats
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdrs = $list[1];

print "Here is the IQ record_count: $iqdrs \n";

#####################################################
#        flash_adjustments
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('flash_adjustments'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prfla = $list[1];

print "Here is the record_count: $prfla  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from flash_adjustments
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqfla = $list[1];

print "Here is the IQ record_count: $iqfla \n";

#####################################################
#        manifest_detail
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('manifest_detail'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmnd = $list[1];

print "Here is the record_count: $prmnd  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from manifest_detail
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmnd = $list[1];

print "Here is the IQ record_count: $iqmnd \n";

#####################################################
#        manifest_header
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('manifest_header'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prmnh = $list[1];

print "Here is the record_count: $prmnh  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from manifest_header
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqmnh = $list[1];

print "Here is the IQ record_count: $iqmnh \n";

#####################################################
#        points
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('points'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prpnt = $list[1];

print "Here is the record_count: $prpnt  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from points
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqpnt = $list[1];

print "Here is the IQ record_count: $iqpnt \n";

#####################################################
#        srvc_times_select
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('srvc_times_select'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prsrs = $list[1];

print "Here is the record_count: $prsrs  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from srvc_times_select
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqsrs = $list[1];

print "Here is the IQ record_count: $iqsrs \n";

#####################################################
#        srvc_times_ground
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('srvc_times_ground'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prsrg = $list[1];

print "Here is the record_count: $prsrg  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from srvc_times_ground
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqsrg = $list[1];

print "Here is the IQ record_count: $iqsrg \n";
#} # eof dont run
#####################################################
#        can_cost
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('can_cost'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prcac = $list[1];

print "Here is the record_count: $prcac  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from can_cost
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqcac = $list[1];
$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from can_cost
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqcac = $list[1];

print "Here is the IQ record_count: $iqcac \n";

#\n";
#die;

#####################################################
#        cost_master
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('cost_master'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prcam = $list[1];

print "Here is the record_count: $prcam  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from cost_master
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqcam = $list[1];

print "Here is the IQ record_count: $iqcam \n";

#####################################################
#        employee
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('employee'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$premp = $list[1];

print "Here is the record_count: $premp  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from employee
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqemp = $list[1];

print "Here is the IQ record_count: $iqemp \n";

#####################################################
#        rurpers
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('rurpers'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prrup = $list[1];

print "Here is the record_count: $prrup  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from rurpers
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqrup = $list[1];

print "Here is the IQ record_count: $iqrup \n";

#####################################################
#        terminal
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('terminal'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prtrm = $list[1];

print "Here is the record_count: $prtrm  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from terminal
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqtrm = $list[1];

print "Here is the IQ record_count: $iqtrm \n";

#####################################################
#        truck_stats
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cpscan
go
select row_count(db_id(),object_id('truck_stats'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prtrs = $list[1];

print "Here is the record_count: $prtrs  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from truck_stats
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqtrs = $list[1];


print "Here is the IQ record_count: $iqtrs \n";

#####################################################
#       dsshipment 
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsshipment'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdss = $list[1];

print "Here is the record_count: $prdss  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsshipment
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdss = $list[1];


print "Here is the IQ record_count: $iqdss \n";

#####################################################
#       dsshipment_orig
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsshipment_orig'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdso = $list[1];

print "Here is the record_count: $prdso  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsshipment_orig
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdso = $list[1];


print "Here is the IQ record_count: $iqdso \n";

#####################################################
#       dsshipment_trail
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsshipment_trail'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdst = $list[1];

print "Here is the record_count: $prdst  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsshipment_trail
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdst = $list[1];


print "Here is the IQ record_count: $iqdst \n";

#####################################################
#       dsbarcode
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsbarcode'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdsb = $list[1];

print "Here is the record_count: $prdsb  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsbarcode
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdsb = $list[1];


print "Here is the IQ record_count: $iqdsb \n";

#####################################################
#       dsbarcode_orig
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsbarcode_orig'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdbo = $list[1];

print "Here is the record_count: $prdbo  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsbarcode_orig
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdbo = $list[1];


print "Here is the IQ record_count: $iqdbo \n";

#####################################################
#       dsbarcode_trail
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use rev_hist
go
select row_count(db_id(),object_id('dsbarcode_trail'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$prdbt = $list[1];

print "Here is the record_count: $prdbt  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from dsbarcode_trail
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqdbt = $list[1];


print "Here is the IQ record_count: $iqdbt \n";

#####################################################
#       qmaaudit
#####################################################

$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$prodserver -n -b -s'|'<<EOF 2>&1
use cmf_data
go
select row_count(db_id(),object_id('qmaaudit'))
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$praudit = $list[1];

print "Here is the record_count: $praudit  \n";

$error = `. /opt/sybase/SYBASE.sh
isql -UDBA -Pspeed -Scpiq1 -n -b -s'|'<<EOF 2>&1
use cpiq1
go
select count(*) from qmaaudit
go
exit
EOF
`;
print $error;

$error =~ s/\s//g;
@list = split(/\|/,$error);
$iqaudit = $list[1];


print "Here is the IQ record_count: $iqaudit \n";


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject:  Production sync with IQ!!!

Following are the Production & IQ tables row count.

tttl_ac_address_correction  (Prod): $prac
                              (IQ): $iqac
***************************************************
tttl_batchdown              (Prod): $prbd
                              (IQ): $iqbd
***************************************************
tttl_bi_bulk_inbound        (Prod): $prbi
                              (IQ): $iqbi
***************************************************
tttl_cp_cod_package         (Prod): $prcp
                              (IQ): $iqcp
***************************************************
tttl_ct_cod_totals          (Prod): $prct
                              (IQ): $iqct
***************************************************
tttl_dc_delivery_comment    (Prod): $prdc
                              (IQ): $iqdc
***************************************************
tttl_dex_dlry_cross_ref     (Prod): $prdex
                              (IQ): $iqdex
***************************************************
tttl_dr_delivery_record     (Prod): $prdr
                              (IQ): $iqdr
***************************************************
tttl_ev_event               (Prod): $prev
                              (IQ): $iqevtotal
***************************************************
tttl_ex_exception_comment   (Prod): $prex
                              (IQ): $iqex
***************************************************
tttl_fl_fuel                (Prod): $prfl
                              (IQ): $iqfl
***************************************************
tttl_hc_hub_cod             (Prod): $prhc
                              (IQ): $iqhc
***************************************************
tttl_hv_high_value          (Prod): $prhv
                              (IQ): $iqhv
***************************************************
tttl_id_driver_route_id     (Prod): $prid
                              (IQ): $iqid
***************************************************
tttl_ii_interline_inbound   (Prod): $prii
                              (IQ): $iqii
***************************************************
tttl_incompat               (Prod): $princompat
                              (IQ): $iqincompat
***************************************************
tttl_io_interline_outbound  (Prod): $prio
                              (IQ): $iqio
***************************************************
tttl_lo_linehaul_outbound   (Prod): $prlo
                              (IQ): $iqlo
***************************************************
tttl_ma_COD             (Prod): $prmac
                              (IQ): $iqmac
***************************************************
tttl_ma_barcode             (Prod): $prmab
                              (IQ): $iqmab
***************************************************
tttl_ma_document             (Prod): $prmad
                              (IQ): $iqmad
***************************************************
tttl_ma_manifest             (Prod): $prmam
                              (IQ): $iqmam
***************************************************
tttl_ma_other             (Prod): $prmao
                              (IQ): $iqmao
***************************************************
tttl_ma_shipment             (Prod): $prmas
                              (IQ): $iqmas
***************************************************
tttl_mb_multiple_barcodes   (Prod): $prmb
                              (IQ): $iqmb
***************************************************
tttl_ms_missorts            (Prod): $prms
                              (IQ): $iqms
***************************************************
tttl_or                     (Prod): $pror
                              (IQ): $iqor
***************************************************
tttl_pa_parcel              (Prod): $prpa
                              (IQ): $iqpatotal
***************************************************
tttl_pr_pickup_record       (Prod): $prpr
                              (IQ): $iqpr
***************************************************
tttl_ps_pickup_shipper      (Prod): $prps
                              (IQ): $iqps
***************************************************
tttl_pt_pickup_totals      (Prod): $prpt
                              (IQ): $iqpt
***************************************************
tttl_se_search             (Prod): $prse
                              (IQ): $iqse
***************************************************
tttl_sortation              (Prod): $prsort
                              (IQ): $iqsort
***************************************************
tttl_up_US_parcels          (Prod): $prup
                              (IQ): $iqup
***************************************************
tttl_us                     (Prod): $prus
                              (IQ): $iqus
***************************************************
bcxref                      (Prod): $prxref
                              (IQ): $iqxref
***************************************************
cwparcel                    (Prod): $prparcel
                              (IQ): $iqparcel
***************************************************
cwshipment                  (Prod): $prship
                              (IQ): $iqship
***************************************************
cwstudy                     (Prod): $prstudy
                              (IQ): $iqstudy
***************************************************
dimweight                   (Prod): $prweight
                              (IQ): $iqweight
***************************************************
revhstd                     (Prod): $prhstd
                              (IQ): $iqhstd
***************************************************
revhstd1                    (Prod): $prhstd1
                              (IQ): $iqhstd1
***************************************************
revhstf                     (Prod): $prhstf
                              (IQ): $iqhstf
***************************************************
revhstf1                    (Prod): $prhstf1
                              (IQ): $iqhstf1
***************************************************
revhsth                    (Prod): $prhsth
                              (IQ): $iqhsth
***************************************************
revhstm                    (Prod): $prhstm
                              (IQ): $iqhstm
***************************************************
revhstr                    (Prod): $prhstr
                              (IQ): $iqhstr
***************************************************
revhsts                    (Prod): $prhsts
                              (IQ): $iqhsts
***************************************************
revhstz                     (Prod): $prhstz
                              (IQ): $iqhstz
***************************************************
cmfextra2                     (Prod): $prex2
                                (IQ): $iqex2
***************************************************
driver_stats                  (Prod): $prdrs
                                (IQ): $iqdrs
***************************************************
flash_adjustments             (Prod): $prfla
                                (IQ): $iqfla
***************************************************
manifest_detail               (Prod): $prmnd
                                (IQ): $iqmnd
**************************************************
manifest_header               (Prod): $prmnh
                                (IQ): $iqmnh
***************************************************
points                        (Prod): $prpnt
                                (IQ): $iqpnt
**************************************************
srvc_times_select             (Prod): $prsrs
                                (IQ): $iqsrs
***************************************************
srvc_times_ground             (Prod): $prsrg
                                (IQ): $iqsrg
**************************************************
can_cost                      (Prod): $prcac
                                (IQ): $iqcac
***************************************************
cost_master                   (Prod): $prcam
                                (IQ): $iqcam
***************************************************
employee                      (Prod): $premp
                                (IQ): $iqemp
***************************************************
rurpers                       (Prod): $prrup
                                (IQ): $iqrup
***************************************************
terminal                      (Prod): $prtrm
                                (IQ): $iqtrm
***************************************************
truck_stats                   (Prod): $prtrs
                                (IQ): $iqtrs
***************************************************
dsshipment                    (Prod): $prdss
                                (IQ): $iqdss
***************************************************
dsshipment_orig                 (Prod): $prdso
                                (IQ): $iqdso
***************************************************
dsshipment_trail                (Prod): $prdst
                                  (IQ): $iqdst
***************************************************
dsbarcode                       (Prod): $prdsb
                                  (IQ): $iqdsb
***************************************************
dsbarcode_orig                    (Prod): $prdbo
                                    (IQ): $iqdbo
***************************************************
dsbarcode_trail                   (Prod): $prdbt
                                    (IQ): $iqdbt
***************************************************
qmaaudit	                   (Prod): $praudit
                                    (IQ): $iqaudit
***************************************************

EOF
`;
