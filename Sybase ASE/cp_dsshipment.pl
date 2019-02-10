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

$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis cp_dsshipment_sequence 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis cp_dsshipment_sequence 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis cp_dsshipment_sequence 2>&1`;

print "Generation Msg: $reset_msg \n $run_msg \n Job Info: $job_info \n";

if ($job_info =~ /Finished with warnings/ || $job_info =~ /abort/i || $job_info =~ /Error running job/){
 if ($job_info !~ /No row was found/){
	print "Emailing Now \n";
	open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

	print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
	print MAIL "From: DataStage <admin\@datastage.com>\n";
	print MAIL "Subject: rev_hist\\cp_dsshipment_sequence Messages\n\n";

	print MAIL "Keyword searched -- Finished with warnings, Aborted, Error running job \n\n";
	print MAIL "$job_info \n";
	#print MAIL "This is line 2\n";
	close (MAIL);
 }
}