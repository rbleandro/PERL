#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 28 2008	Amer Khan 	Originally created                           #
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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "mpr_init_all_flags StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   unless (-e "/tmp/mpr_pnd_wtd_and_notd_done" && -e "/tmp/mpr_hub_preload_costs_done" && -e "/tmp/mpr_linehaul_cost_load_proc_done" && -e "/tmp/mpr_interline_costing_proc_done")
{ 
      sleep(5);
   }else{
      last;
   }
}


$rm_output = `rm /tmp/svp_eput_proc_done /tmp/svp_parcel_proc_done /tmp/netistix_load_done /tmp/emp_time_load_done /tmp/hmi_jcc_load_done /tmp/hmi_mtl_load_done /tmp/mpr_bcxref_work_update_lod_procs_done /tmp/mpr_pnd_wtd_and_notd_done /tmp/mpr_work_move_proc_done /tmp/mpr_route_proc_done /tmp/mpr_hub_preload_costs_done /tmp/mpr_linehaul_cost_load_proc_done /tmp/mpr_interline_costing_proc_done`;

print "$rm_output\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_init_all_flags

Following status was received during mpr_init_all_flags that started on $currTime
$rm_output
EOF
`;


$currTime = localtime();
print "mpr_init_all_flags FinTime: $currTime\n";

`touch /tmp/mpr_init_all_flags_done`;

