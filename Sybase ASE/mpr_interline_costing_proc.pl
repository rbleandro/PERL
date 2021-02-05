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

print "mpr_interline_costing_proc StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==0){
   unless (-e "/tmp/mpr_route_proc_done" && -e "/tmp/hmi_jcc_load_done" && -e "/tmp/hmi_mtl_load_done"){ 
      sleep(5);
   }else{
      last;
   }
}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
execute mpr_interline_costing_proc
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
Subject: ERROR - updating mpr_interline_costing_proc

Following status was received during mpr_interline_costing_proc that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_interline_costing_proc at $currTime \n";
}

$currTime = localtime();
print "mpr_interline_costing_proc FinTime: $currTime\n";

`touch /tmp/mpr_interline_costing_proc_done`;

