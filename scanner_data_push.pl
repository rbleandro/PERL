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

# All went ok, resume replication and move on with pushing data to Loomis now...
#print "Generating Loomis Data Now...$date_flag \n";
$reset_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run -mode RESET \-wait loomis sc_data_jobs_seq 2>&1`;
$gen_msg=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-run \-wait loomis sc_data_jobs_seq 2>&1`;
$job_info=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis sc_data_jobs_seq 2>&1`;
$job_info2=`C\:\/IBM\/InformationServer\/Server\/DSEngine\/bin\/dsjob.exe \-logdetail loomis db_flat_file 2>&1`;

print "Generation Msg: $gen_msg \n Job Info: $job_info \n";

if ($job_info =~ /Finished with warnings/ || $job_info =~ /did not finish ok/ || $job_info =~ /Aborted/ || $job_info =~ /Not connected/ || $job_info =~ /deadlock/){
	if ($wday eq '0' || $wday eq '6'){die;}
	if ($job_info2 =~ /0 Rows affected/){die;}

print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Scanner Data Push Messages on $wday day of the week\n\n";

print MAIL "Keyword searched -- Finished with warnings, aborted \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);
}