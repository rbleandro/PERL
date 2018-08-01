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
print "Deleting sc_data.out, in case if it was left by some previous half run process \n";
$del_file=`rm 'C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\sc_data\.out' 2>&1`;
print "$currDate:: $del_file \n";

#print "Suspending now \n";
#$ren_file=`
#C\:\/Sybase\/OCS-15_0\/bin\/isql.exe \-Usa \-w200 \-Ps9b2s3 \-Shqvsybrep2 \-b \-Jroman8 <<EOF 2>&1
#suspend connection to CPDB1.lm_stage   
#go
#suspend connection to CPDB2.lm_stage   
#go
#exit
#EOF
#`;
}else{
print "Resuming Now \n";
$ren_file=`
C\:\/Sybase\/OCS-15_0\/bin\/isql.exe \-Usa \-w200 \-Ps9b2s3 \-Shqvsybrep2 \-b \-Jroman8 <<EOF 2>&1
resume connection to CPDB1.lm_stage   
go
resume connection to CPDB2.lm_stage   
go
exit
EOF
`;
}
print "$currDate:: $ren_file \n";
if ($ren_file =~ /Failed/i || $ren_file =~ /already suspended/ || $ren_file =~ /not/){
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis sc_data_jobs_seq 2>&1`;

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
