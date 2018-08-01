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

print "Milli: $msec \n"; #C:\loomis_ftp_scripts\Credentials\CA_OPEN.TXT

$ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\Credentials\\CredentialsData_ftp.txt lmscollect1.loomisexpress.com 2>&1`;

print $ftp_msg;

if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)
  { 
  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
  print MAIL "From: DataStage <admin\@datastage1.com>\n";
  print MAIL "Subject: FTP Errors from Credentials Data To LMSCOLLECT1!! \n\n";

  print MAIL "FTP msgs: $ftp_msg \n";
  close (MAIL);
  
  print "Credentials Data file not sent!! \n"; }

$ftp_msg = `ftp -s:C:\\loomis_ftp_scripts\\Credentials\\CredentialsData_ftp_to_prod.txt 10.4.96.85 2>&1`;

print $ftp_msg;

if ($ftp_msg =~ /Not connected/ || $ftp_msg =~ /Not/i)
  { 
  open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

  print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
  print MAIL "From: DataStage <admin\@datastage1.com>\n";
  print MAIL "Subject: FTP Errors from Credentials Data To Production!! \n\n";

  print MAIL "FTP msgs: $ftp_msg \n";
  close (MAIL);
  
  print "Credentials Data file not sent!! \n"; }
