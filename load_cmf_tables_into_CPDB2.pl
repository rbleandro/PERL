#!/usr/bin/perl 

###################################################################################
#Script:   This script converts cmf data from flat files into CPDATA2 cmf_data db #
#          Once the ETL process completes, dump is taken which gets loaded to     #
#          CPDB2, from where it gets loaded to IQ                                 #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#02/03/04       Amer Khan       Originally created                                #
#11/18/04       Amer Khan       Modified to unzip file that is now received       #
#                               directly from OPS3                                #
#10/12/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################
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
if ($prodserver eq "CPDB2" ) {
$standbyserver = "CPDB1"; 
}
else
{
$standbyserver = "CPDB2";
}

#if (1==2){ # sof do not run
#**********************************************************************************************
print "****Starting canada_post bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp canada_post..canada_post out /tmp/canada_post.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use canada_post
go
truncate table canada_post
go
exit
EOF
#Load data from prod
bcp canada_post..canada_post in /tmp/canada_post.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000 -E
`;

print "Messages from truncating and repopulating canada_post\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting cmfextra bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..cmfextra out /tmp/cmfextra.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table cmfextra
go
exit
EOF
#Load data from prod
bcp cmf_data..cmfextra in /tmp/cmfextra.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000 
`;

print "Messages from truncating and cmfextra\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting cmfprice bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..cmfprice out /tmp/cmfprice.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table cmfprice
go
exit
EOF
#Load data from prod
bcp cmf_data..cmfprice in /tmp/cmfprice.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and cmfprice\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting cmfrates bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..cmfrates out /tmp/cmfrates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table cmfrates
go
exit
EOF
#Load data from prod
bcp cmf_data..cmfrates in /tmp/cmfrates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and cmfrates\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting cmfshipr bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..cmfshipr out /tmp/cmfshipr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table cmfshipr
go
exit
EOF
#Load data from prod
bcp cmf_data..cmfshipr in /tmp/cmfshipr.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and cmfshipr\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting fuelpct bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..fuelpct out /tmp/fuelpct.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table fuelpct
go
exit
EOF
#Load data from prod
bcp cmf_data..fuelpct in /tmp/fuelpct.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and fuelpct\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting lh_matrix bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..lh_matrix out /tmp/lh_matrix.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table lh_matrix
go
exit
EOF
#Load data from prod
bcp cmf_data..lh_matrix in /tmp/lh_matrix.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and lh_matrix\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting points_no_ranges bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..points_no_ranges out /tmp/points_no_ranges.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table points_no_ranges
go
exit
EOF
#Load data from prod
bcp cmf_data..points_no_ranges in /tmp/points_no_ranges.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and points_no_ranges\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_ratecode bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_ratecode out /tmp/rc_ratecode.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_ratecode
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_ratecode in /tmp/rc_ratecode.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_ratecode\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_rates bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_rates out /tmp/rc_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_rates
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_rates in /tmp/rc_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_rates\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_rateschd bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_rateschd out /tmp/rc_rateschd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_rateschd
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_rateschd in /tmp/rc_rateschd.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_rateschd\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_rateshk bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_rateshk out /tmp/rc_rateshk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_rateshk
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_rateshk in /tmp/rc_rateshk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_rateshk\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_rsaltlnk bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_rsaltlnk out /tmp/rc_rsaltlnk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_rsaltlnk
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_rsaltlnk in /tmp/rc_rsaltlnk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_rsaltlnk\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_zones bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_zones out /tmp/rc_zones.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_zones
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_zones in /tmp/rc_zones.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_zones\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_zones_ea bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_zones_ea out /tmp/rc_zones_ea.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_zones_ea
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_zones_ea in /tmp/rc_zones_ea.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_zones_ea\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_zones6 bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_zones6 out /tmp/rc_zones6.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_zones6
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_zones6 in /tmp/rc_zones6.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_zones6\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_zonesi bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_zonesi out /tmp/rc_zonesi.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_zonesi
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_zonesi in /tmp/rc_zonesi.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_zonesi\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting rc_zwdischk bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..rc_zwdischk out /tmp/rc_zwdischk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table rc_zwdischk
go
exit
EOF
#Load data from prod
bcp cmf_data..rc_zwdischk in /tmp/rc_zwdischk.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and rc_zwdischk\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting resi_unitname_exclusion bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp rev_hist..resi_unitname_exclusion out /tmp/resi_unitname_exclusion.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use rev_hist
go
truncate table resi_unitname_exclusion
go
exit
EOF
#Load data from prod
bcp rev_hist..resi_unitname_exclusion in /tmp/resi_unitname_exclusion.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and resi_unitname_exclusion\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tax_postal_ranges bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tax_postal_ranges out /tmp/tax_postal_ranges.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tax_postal_ranges
go
exit
EOF
#Load data from prod
bcp cmf_data..tax_postal_ranges in /tmp/tax_postal_ranges.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tax_postal_ranges\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tax_rates bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tax_rates out /tmp/tax_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tax_rates
go
exit
EOF
#Load data from prod
bcp cmf_data..tax_rates in /tmp/tax_rates.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tax_rates\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tot_ch bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tot_ch out /tmp/tot_ch.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tot_ch
go
exit
EOF
#Load data from prod
bcp cmf_data..tot_ch in /tmp/tot_ch.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tot_ch\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tot_cn bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tot_cn out /tmp/tot_cn.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tot_cn
go
exit
EOF
#Load data from prod
bcp cmf_data..tot_cn in /tmp/tot_cn.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tot_cn\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tot_hs bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tot_hs out /tmp/tot_hs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tot_hs
go
exit
EOF
#Load data from prod
bcp cmf_data..tot_hs in /tmp/tot_hs.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tot_hs\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run
print "****Starting tot_tm bcp from $prodserver *****\n";

#Truncating table
$sqlError = `. /opt/sybase/SYBASE.sh

# Get data out from prod table
bcp cmf_data..tot_tm out /tmp/tot_tm.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"

#truncate table in source for reload
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -w300 <<EOF 2>&1
use cmf_data
go
truncate table tot_tm
go
exit
EOF
#Load data from prod
bcp cmf_data..tot_tm in /tmp/tot_tm.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -Sold_CPDB2 -c -t"|:|" -r"||\n" -b10000
`;

print "Messages from truncating and tot_tm\n\n$sqlError\n\n";

#**********************************************************************************************
#} # eof do not run


