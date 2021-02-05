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

print "mpr_lm_bcxref_work_update_lod_procs StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   #unless (-e "/tmp/svp_eput_proc_done" && -e "/tmp/svp_parcel_proc_done"){
   unless (-e "/tmp/svp_parcel_proc_done"){ 
      sleep(5);
   }else{
      last;
   }
}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data_lm
go
select getdate() as starting, 'mpr_bcxref_load_proc' as running_proc
go
--execute mpr_bcxref_load_proc
select 'hi' --Dummy record, remove it when you uncomment the line above
go
if (\@\@error = 0)
begin
select getdate() as starting, 'mpr_work_update_proc' as running_proc
execute mpr_work_update_proc
end
else
select "Something went wrong in the previous, not running mpr_work_update_proc", getdate()
go
select getdate() as starting, 'mpr_work_move_proc' as running_proc
go
execute mpr_work_move_proc
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/ && $sqlError !~ /Duplicate/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_bcxref_work_update_lod_procs

Following status was received during mpr_bcxref_work_update_lod_procs that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_bcxref_work_update_lod_procs at $currTime \n";
}

$currTime = localtime();
print "mpr_lm_bcxref_work_update_lod_procs FinTime: $currTime\n";

`touch /tmp/mpr_lm_bcxref_work_update_lod_procs_done`;
