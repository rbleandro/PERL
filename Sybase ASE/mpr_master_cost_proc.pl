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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "mpr_master_cost_proc StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   unless (-e "/tmp/mpr_pnd_wtd_and_notd_done" && -e "/tmp/mpr_hub_preload_costs_done" && -e "/tmp/mpr_linehaul_cost_load_proc_done" && -e "/tmp/mpr_interline_costing_proc_done"){ 
      sleep(5);
   }else{
      last;
   }
}

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
set replication off
go
execute mpr_master_cost_proc
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_master_cost_proc

Following status was received during mpr_master_cost_proc that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_master_cost_proc at $currTime \n";
}

$currTime = localtime();
print "mpr_master_cost_proc FinTime: $currTime\n";

`touch /tmp/mpr_master_cost_proc_done`;

