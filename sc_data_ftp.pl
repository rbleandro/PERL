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

# All went ok, resume replication and move on with pushing data to Loomis now...
print "Resuming Connection Now...";
#$resume_rep=`perl C\:\\\\loomis_ftp_scripts\\\\rep_control.pl 2>&1`;
print $resume_rep;

# Check if the file is empty, if it is, then abort
$file_check = `wc.exe -m "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\sc_data.out"`;
$file_check =~ s/\s//g; # Clean all spaces from line

$date_flag = "$wday $mon-$mday-$year $hour:$min:$sec";
$lm_day=73	+$wday;
#$lm_day=75	+$wday;
print "lm_day: $lm_day and wday: $wday \n";

@file_lines = split("C:",$file_check);
print "CharCount: $file_lines[0] \n";

#Save line count for max record check
$line_check = `wc.exe -l "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\sc_data.out"`;
@file_recs = split("C:",$line_check);

print "LineCount: $file_recs[0] \n";

if ($file_lines[0] < 20){ # There is no data to send
$ren_file=`ren C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\sc_data\.out NOUP$lm_day$hour$min 2>&1`;
print "Rename: $ren_file \n";
$mv_file=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\NOUP\* C:\\loomis_ftp_scripts\\NOUP_files_bkp 2>&1`;
print "Move File: $mv_file \n";
print "No Data To Send";
exit();
}

print "UP File created: UP$lm_day$hour$min \n";
$ren_file=`ren C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\sc_data\.out UP$lm_day$hour$min 2>&1`;
print "Renaming file to UP... $ren_file \n";

#Check if the line count is over 10000, PMS will reject it over 10000
if ($file_recs[0] > 9999){
 print "UP File exceeded max records limits \n";
 print "File has to be split for PMS to accept it \n";
 print "Trying to split file now \n";

 $split_file = `perl C\:\\loomis_ftp_scripts\\UP_file_split\.pl UP$lm_day$hour$min 2>&1`;
 print "Split Messages: $split_file \n";
 $ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\repush_ftp.txt 10.133.22.5 2>&1`;
  print $ftp_msg;

  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)# || $ftp_msg !~ /Successful/i)
  { print "UP file not sent!! \n"; exit; }
 
 ##Move UP files to backup folder...
 $mv_msg=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C:\\loomis_ftp_scripts\\UP_files_bkp\\UP_Repush\\UP\* C:\\loomis_ftp_scripts\\UP_files_bkp 2>&1`;
 print "Moving file to backup folder: $mv_msg \n";
 
 
 ##open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

 ##print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
 ##print MAIL "From: DataStage <admin\@datastage.com>\n";
 ##print MAIL "Subject: UP File size exceeded!! \n\n";

 ##print MAIL "Trying to split file and then send\n";
 ##print MAIL "File Name: $ren_file \n";
 ##print MAIL "Results from splitting files: $split_file \n";
 ##close (MAIL);

}else{

  if ($ren_file =~ /cannot/i) {
    #print 
    exit("!!Dying miserably!! \nsc_data.out file is not there, not continuing...\n");
  }
  #exit; # added for test
  $ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\ftp.txt 10.133.22.5 2>&1`;
  print $ftp_msg;

  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)# || $ftp_msg !~ /Successful/i)
  { 
  if ($wday == '0' || $wday == '6'){exit;}

  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
  print MAIL "From: DataStage <admin\@datastage.com>\n";
  print MAIL "Subject: FTP Errors!! \n\n";

  print MAIL "FTP msgs: $ftp_msg \n";
  close (MAIL);
  
  exit "UP file not sent!! \n"; }
}
##Move UP files to backup folder...
$mv_msg=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\UP\* C:\\loomis_ftp_scripts\\UP_files_bkp 2>&1`;
print "Moving file to backup folder: $mv_msg \n";
