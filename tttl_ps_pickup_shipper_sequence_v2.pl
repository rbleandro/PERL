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
$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis cp_tttl_ps_pickup_shipper_seq 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis cp_tttl_ps_pickup_shipper_seq 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis cp_tttl_ps_pickup_shipper_seq 2>&1`;
$job_step_info1=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis cp_tttl_ps_pickup_shipper_to_seq 2>&1`;
$job_step_info2=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis cp_tttl_ps_pickup_shipper_seq_to_arch 2>&1`;
$job_step_info3=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis cp_tttl_ps_pickup_shipper_deletes 2>&1`;

#print "Generation Msg: $gen_msg \n Job Info: $job_info \n";

if ($job_step_info1 =~ /Finished with warnings/ || $job_step_info1 =~ /aborted/ || $job_step_info1 =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Archive cp_tttl_ps_pickup_shipper_seq Messages\n\n";

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
print MAIL "Subject: Archive cp_tttl_ps_pickup_shipper_seq Messages\n\n";

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
print MAIL "Subject: Archive cp_tttl_ps_pickup_shipper_seq Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_step_info3 \n";
#print MAIL "This is line 2\n";
close (MAIL);
}

elsif ($job_info =~ /Finished with warnings/ || $job_info =~ /aborted/ || $job_info =~ /Not connected/){
print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <rleandro\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Archive cp_tttl_ps_pickup_shipper_seq Messages\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);
}