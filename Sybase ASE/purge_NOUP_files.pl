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

$del_file=`del C:\\loomis_ftp_scripts\\NOUP_files_bkp\\NOUP\* 2>&1`;
print "Purge NOUP Messages: $del_file \n";

if ($del_file =~ /cannot/i) {
   #print 
   die("!!Dying miserably!! \n something went wrong in deleting NOUP files...\n");
}
