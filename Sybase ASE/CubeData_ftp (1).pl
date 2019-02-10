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
$file_check = `wc.exe -m "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\JCC_Cube_Data"`;
$file_check =~ s/\s//g; # Clean all spaces from line

@file_lines = split("C:",$file_check);
print "CharCount: $file_lines[0] \n";

#Save line count for max record check
$line_check = `wc.exe -l "C:\\IBM\\InformationServer\\Server\\Projects\\loomis\\JCC_Cube_Data"`;
@file_recs = split("C:",$line_check);

print "LineCount: $file_recs[0] \n";

if ($file_lines[0] < 20){ # There is no data to send
$ren_file=`rm C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\JCC_Cube_Data 2>&1`;
print "Rename: $ren_file \n";
#$mv_file=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C:/IBM/InformationServer/Server/Projects/loomis/NORD\* C:/loomis_ftp_scripts/Sort_Data_bkp/Cube_Data_bkp/JCC 2>&1`;
#print "Move File: $mv_file \n But No Data To Send \n";
exit(0);
}

print "CubeData File created: RD$mday$hour$min$sec.TXT \n";
$ren_file = rename "C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\JCC_Cube_Data","C\:\\IBM\\InformationServer\\Server\\Projects\\loomis\\RD$mday$hour$min$sec.TXT";
print "Renaming file to CubeData File... $ren_file \n";


  if ($ren_file =~ /cannot/i) {
    #print 
    die("!!Dying miserably!! \n JCC_Cube_Data file is not there, not continuing...\n");
  }
 
  $ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\jobs\\Sort_Data\\Loomis\\JCC\\CubeData_ftp.txt hqvlmsgeoftp1.loomisexpress.com 2>&1`;

  print $ftp_msg;

  if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)
  { 
  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
  print MAIL "From: DataStage <admin\@datastage.com>\n";
  print MAIL "Subject: FTP Errors from JCC Cube data!! \n\n";

  print MAIL "FTP msgs: $ftp_msg \n";
  close (MAIL);
  
  die "CubeData file not sent!! \n"; }

##Move CubeData files to backup folder...
$mv_msg=`"c:\\Program Files (x86)\\MKS Toolkit\\mksnt\\mv.exe" C:/IBM/InformationServer/Server/Projects/loomis/RD\* C:/loomis_ftp_scripts/Sort_Data_bkp/Cube_Data_bkp/JCC 2>&1`;
print "Moving file to backup folder: $mv_msg \n";
