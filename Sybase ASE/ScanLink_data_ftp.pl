#Setting Time
#use lib 'C:\strawberry\perl\lib';

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

#Milisecs Inclusion
use lib 'C:\strawberry\perl\lib';
use Time::HiRes qw(gettimeofday);
# get seconds and microseconds since the epoch
($s, $usec) = gettimeofday();
$msec = sprintf('%03d',int($usec/1000));

print "Milli: $msec \n";

# Check if the file is empty, if it is, then abort
$file_check = `wc.exe -m "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\MTRL_Scan_Link"`;
$file_check =~ s/\s//g; # Clean all spaces from line

@file_lines = split("C:",$file_check);
print "CharCount: $file_lines[0] \n";

#Save line count for max record check
$line_check = `wc.exe -l "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\MTRL_Scan_Link"`;
@file_recs = split("C:",$line_check);

print "LineCount: $file_recs[0] \n";

if ($file_lines[0] < 20){ # There is no data to send
$ren_file=`rm C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\MTRL_Scan_Link 2>&1`;
print "Rename: $ren_file \n";
#$mv_file=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C:/IBM/InformationServer/Server/Projects/loomis/NOScanLink\* C:/loomis_ftp_scripts/Sort_Data_bkp/ScanLink_Data_bkp/MTRL 2>&1`;
#print "Move File: $mv_file \n But No Data To Send \n";
exit(0);
}

print "ScanLink File created: ScanLink$year$mon$mday$hour$min$sec$msec.TXT \n";
$ren_file = rename "C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\MTRL_Scan_Link","C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\ScanLink$year$mon$mday$hour$min$sec$msec.TXT";
print "Renaming file to ScanLink File... $ren_file \n";


  if ($ren_file =~ /cannot/i) {
    #print 
    die("!!Dying miserably!! \n MTRL_Scan_Link file is not there, not continuing...\n");
  }
  
  $ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\jobs\\Sort_Data\\Loomis\\MTRL\\ScanLink_data_ftp.txt 10.133.117.32 2>&1`;
  print $ftp_msg;

  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)
  { 
  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
  print MAIL "From: DataStage <admin\@datastage.com>\n";
  print MAIL "Subject: Scanlink FTP Errors!! \n\n";

  print MAIL "FTP msgs: $ftp_msg \n";
  close (MAIL);
  
  die "UP file not sent!! \n"; }

##Move UP files to backup folder...
$mv_msg=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C:/IBM/InformationServer/Server/Projects/loomis/ScanLink\* C:/loomis_ftp_scripts/Sort_Data_bkp/ScanLink_Data_bkp/MTRL 2>&1`;
print "Moving file to backup folder: $mv_msg \n";
