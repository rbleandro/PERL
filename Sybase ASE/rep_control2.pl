#Setting Time
$currDate=localtime();
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);
$action = $ARGV[0];

if ($action eq 'suspend')
{
print "Suspending now \n";
$ren_file=`
C\:\/\"Program Files \(x86\)\"\/\"MKS Toolkit\"\/bin\/ssh sybase\@cpdb1\.canpar\.com \'\'/opt/sybase/cron_scripts/lm_set_prod_connection.pl suspend\' \'
`;

}else{
print "Resuming Now \n";
#$ren_file=`
#C\:\/\"Program Files \(x86\)\"\/\"MKS Toolkit\"\/bin\/ssh sybase\@cpdb1\.canpar\.com \'\'/opt/sybase/cron_scripts/lm_set_prod_connection.pl #resume\' \'
#`;
}
print "Here is the msg: $currDate:: $ren_file \n";
if ($ren_file =~ /Failed/ || $ren_file =~ /already suspended/ || $ren_file =~ /not/){
#$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis sc_data_jobs_seq 2>&1`;

print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Message From Disabling/Enabling Replication \n\n";

print MAIL "Keyword searched -- Failed, already suspended, not \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$ren_file \n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);

$abort_job=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-stop loomis sc_data_jobs_seq 2>&1`;
}
