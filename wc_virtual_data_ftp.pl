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

# Check if the file is empty, if it is, then abort
$file_check = `wc.exe -m "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\virtuals_data.out"`;
$file_check =~ s/\s//g; # Clean all spaces from line

$date_flag = "$wday $mon-$mday-$year $hour:$min:$sec";
$lm_day=80	+$wday;
#$lm_day=75	+$wday;
print "lm_day: $lm_day and wday: $wday \n";

@file_lines = split("C:",$file_check);
print "CharCount: $file_lines[0] \n";

#Save line count for max record check
$line_check = `wc.exe -l "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\virtuals_data.out"`;
@file_recs = split("C:",$line_check);

print "LineCount: $file_recs[0] \n";

if ($file_lines[0] < 20){ # There is no data to send
$ren_file= rename "C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\virtuals_data\.out","C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\NOUP$lm_day$hour$min";
print "Rename: $ren_file \n";
$mv_file= `mv C:/IBM/InformationServer/Server/Projects/loomis/virtuals/NOUP$lm_day$hour$min C:/loomis_ftp_scripts/NOUP_files_bkp/ 2>&1`;
print "Move File: $mv_file \n";
print "No Data To Send";
}else{ #Got Data

	print "UP File created: UP$lm_day$hour$min \n";
	$ren_file=rename "C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\virtuals_data\.out","C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\virtuals\\UP$lm_day$hour$min";
	print "Renaming file to UP... $ren_file \n";

	#Check if the line count is over 10000, PMS will reject it over 10000
	if ($file_recs[0] > 9999){
	 print "VIRTUAL UP File exceeded max records limits \n";
	 print "File has to be split for PMS to accept it \n";
	 print "Trying to split file now \n";

	 $split_file = `perl C\:\\loomis_ftp_scripts\\jobs\\Sort_Data\\Loomis\\virtuals_UP_file_split\.pl UP$lm_day$hour$min 2>&1`;
	 $ftp_msg = `ftp -s:C:/loomis_ftp_scripts/jobs/Sort_Data/Loomis/virtuals_repush_ftp.txt 10.133.22.5 2>&1`;
	  print $ftp_msg;

	  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)# || $ftp_msg !~ /Successful/i)
	  { die "VIRTUAL UP file not sent!! \n"; }
	 
	 ##Move UP files to backup folder...
	 $mv_msg= `mv C:/loomis_ftp_scripts/UP_files_bkp/UP_Repush/virtuals/UP$lm_day$hour$min C:/loomis_ftp_scripts/UP_files_bkp/ 2>&1`;
	 print "Moving file to backup folder: $mv_msg \n";
	 
	 open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

	 print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
	 print MAIL "From: DataStage <admin\@datastage.com>\n";
	 print MAIL "Subject: VIRTUAL UP File size exceeded!! \n\n";

	 print MAIL "Trying to split file and then send\n";
	 print MAIL "File Name: $ren_file \n";
	 print MAIL "Results from splitting files: $split_file \n";
	 close (MAIL);

	}else{

	  if ($ren_file =~ /cannot/i) {
		#print 
		die("!!Dying miserably!! \nvirtuals_data.out file is not there, not continuing...\n");
	  }
	  #die; # added for test
	  $ftp_msg = `ftp -s:C:/loomis_ftp_scripts/jobs/Sort_Data/Loomis/virtuals_ftp.txt 10.133.22.5 2>&1`;
	  print $ftp_msg;

	  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)# || $ftp_msg !~ /Successful/i)
	  { 
	  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

	  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
	  print MAIL "From: DataStage <admin\@datastage.com>\n";
	  print MAIL "Subject: Loomis JCC VIRTUAL FTP Errors!! \n\n";

	  print MAIL "FTP msgs: $ftp_msg \n";
	  close (MAIL);
	  
	  die "UP file not sent!! \n"; }
	}

	##Move UP files to backup folder...
	$mv_msg= `mv C:/IBM/InformationServer/Server/Projects/loomis/virtuals/UP\* C:/loomis_ftp_scripts/UP_files_bkp/ 2>&1`;
	print "Moving file to backup folder: $mv_msg \n";

}# eof data found
