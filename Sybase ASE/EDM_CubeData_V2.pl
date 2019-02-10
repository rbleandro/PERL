#! usr/bin/perl

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

$date_flag = "$mon-$mday-$year $hour:$min:$sec";

#print "Generating Loomis Data Now...$date_flag \n";
$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis EDM_DATABATCH_Data 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis EDM_DATABATCH_Data 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_DATABATCH_Data 2>&1`;
$job_step_info1=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_DATABATCH_to_sort_data 2>&1`;
$job_step_info2=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_DATABATCH_to_cube_seq 2>&1`;
$job_step_info3=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_seq_to_cube_file 2>&1`;
$job_step_info4=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_DATABATCH_to_scan_seq 2>&1`;
$job_step_info5=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_seq_to_121_scanlink_file 2>&1`;
$job_step_info6=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_seq_to_091_scanlink_file 2>&1`;
$job_step_info7=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis EDM_seq_to_DATABATCH 2>&1`;

print "Generation Msg: $gen_msg \n Job Info: $job_info \n";

if ($job_step_info1 =~ /Finished with warnings/ || $job_step_info1 =~ /aborted/ || $job_step_info1 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info1 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_step_info2 =~ /Finished with warnings/ || $job_step_info2 =~ /aborted/ || $job_step_info2 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info2 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_step_info3 =~ /Finished with warnings/ || $job_step_info3 =~ /aborted/ || $job_step_info3 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info3 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

if ($job_step_info4 =~ /Finished with warnings/ || $job_step_info4 =~ /aborted/ || $job_step_info4 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info4 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_step_info5 =~ /Finished with warnings/ || $job_step_info5 =~ /aborted/ || $job_step_info5 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info5 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_step_info6 =~ /Finished with warnings/ || $job_step_info6 =~ /aborted/ || $job_step_info6 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info6 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_step_info7 =~ /Finished with warnings/ || $job_step_info7 =~ /aborted/ || $job_step_info7 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info7 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_info =~ /Finished with warnings/ || $job_info =~ /abort/i || $job_info =~ /Not connected/){
if ($job_info =~ /Communication link failure/){ die; }
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Edmonton Sort Data Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);
}