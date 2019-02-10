#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 28 2008	Amer Khan 	Originally created                           #
###'Oct 24 2008'                                                                            #
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

print "mpr_pnd_wtd_and_notd StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   unless (-e "/tmp/netistix_load_done" && -e "/tmp/emp_time_load_done"){ 
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
execute mpr_pnd_load_proc 
go
if (\@\@error = 0)
execute mpr_stop_time_with_no_td
else
select "Something went wrong in the previous mpr_pnd_load_proc, not running mpr_stop_time_with_no_td", getdate()
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
Subject: ERROR - updating mpr_pnd_wtd_and_notd

Following status was received during mpr_pnd_wtd_and_notd that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_pnd_wtd_and_notd at $currTime \n";
}

$currTime = localtime();
print "mpr_pnd_wtd_and_notd FinTime: $currTime\n";

`touch /tmp/mpr_pnd_wtd_and_notd_done`;

