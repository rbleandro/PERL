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
#$action = $ARGV[0];

print "Moving data now \n";
$mv_file=`
C\:\/Sybase\/OCS-15_0\/bin\/isql.exe \-Ulm_data_loader \-w200 \-Psybase \-SCPDB1 \-b \-Jroman8 <<EOF 2>&1
use lmscan
go
execute lmscan_to_lm_stage_data_xfr
go
exit
EOF
`;
print "$currDate:: $mv_file \n";
if ($mv_file =~ /Failed/i || $mv_file =~ /Error/i || $mv_file =~ /not/){

print "Emailing Now \n";
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Sybase DBA <CANPARDatabaseAdministratorsStaffList\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Message From lmscan_to_lm_stage_data_xfr \n\n";

print MAIL "Keyword searched -- Failed, already suspended, not \n";
print MAIL "How To Look -- You can search for the keywords above to look for errors \n\n";
print MAIL "$mv_file \n";
print MAIL "$job_info \n";
#print MAIL "This is line 2\n";
close (MAIL);

}
