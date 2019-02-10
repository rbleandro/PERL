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

$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis syb_inv_row_counts 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis syb_inv_row_counts 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis syb_inv_row_counts 2>&1`;

print "Generation Msg: $reset_msg \n $run_msg \n Job Info: $job_info \n";

$while_cnt = 1;
while ($job_info =~ /NoInvRec/ && $while_cnt < 145){ #While_cnt of 144 means that the job will wait for 12 hours before failing.
print "Still waiting\n";
sleep(300);
$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis syb_inv_row_counts 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis syb_inv_row_counts 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis syb_inv_row_counts 2>&1`;
print "Job Info: $job_info \n";

$while_cnt++;
}

if ($job_info =~ /NoInvRec/){
print "No Inv Record available after 12 hours of waiting. Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <amer_khan\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: No Invoice Record Found Messages\n\n";

print MAIL "We did not get the Inv status record from Sybase Invoicing \n\n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);
}else{ #We have record, moving on to send invoice data to PMS...
	$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis invoice_to_PMS 2>&1`;
	$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis invoice_to_PMS 2>&1`;
	$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis invoice_to_PMS 2>&1`;

	if ($job_info =~ /Finished with warnings/ || $job_info =~ /aborted/ || $job_info =~ /Error running job/){
		print "Errors Found. Emailing Now \n";
		open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

		print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
		#print MAIL "To: Sybase DBA <amer_khan\@canpar.com>\n";
		print MAIL "From: DataStage <admin\@datastage.com>\n";
		print MAIL "Subject: invoice_to_PMS error Messages\n\n";

		print MAIL "Looks like error are reported. \n\n";
		print MAIL "$job_info \n";
		#print MAIL "This is line 2\n";
		close (MAIL);
	}

}

$inv_job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis syb_inv_row_counts 2>&1`;

if ($inv_job_info =~ /Finished with warnings/ || $inv_job_info =~ /aborted/ || $inv_job_info =~ /Error running job/){
print "Errors Found. Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
#print MAIL "To: Sybase DBA <amer_khan\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: syb_inv_row_counts error Messages\n\n";

print MAIL "Looks like error are reported. \n\n";
print MAIL "$inv_job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);
}
