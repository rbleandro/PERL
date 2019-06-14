#!/usr/bin/perl -w


#$hour=sprintf('%02d',((localtime())[2]));
#$hour = int($hour);
#$day=sprintf('%02d',((localtime())[6]));
#print $day;
#$day= int($day);
#print "Hour: $hour and Day is: $day \n";
#
#while ($hour != 5 && $day != 0){
#sleep(5);
#$hour=sprintf('%02d',((localtime())[2]));
#$hour = int($hour);
#print "In hour : $hour\n";
#}

#$minute=sprintf('%02d',((localtime())[1]));
#$hour=sprintf('%02d',((localtime())[2]));
#$what2=sprintf('%02d',((localtime())[3]));
#$what3=sprintf('%02d',((localtime())[4]));
#$what4=sprintf('%02d',((localtime())[5]));
#$day=sprintf('%02d',((localtime())[6]));
#
#print $minute;
#print $hour;
#print $what2;
#print $what3;
#print $what4;
#print $day;

#print $day;
#use Sys::Hostname;
#$prodserver = hostname();

#print $prodserver;

#my($day, $month, $year)=(localtime)[3,4,5];

#$today="$day-".($month+1)."-".($year+1900);
#print $today;



#$day=sprintf('%02d',((localtime())[6]));
#$day= int($day);
#
#print $day . "\n";
#
#if ($day eq 0){
#`/usr/sbin/sendmail -t -i <<EOF
#To:CANPARDatabaseAdministratorsStaffList\@canpar.com,jim_pepper\@canpar.com,Glenn.McFarlane\@loomis-express.com
#Subject: Reminder: adp_load_barcodes is still running.
#
#This is just to remind you that this is still running. Should we disable it?
#
#EOF
#`;
#}else{
#print "Not emailing, because today is not Sunday \n";
#}

#Setting Time
# $currTime = localtime();
# $startHour=sprintf('%02d',((localtime())[2]));
# $startMin=sprintf('%02d',((localtime())[1]));
# my($day, $month, $year)=(localtime)[3,4,5];
# #print "$day-".($month+1)."-".($year+1900)."\n";
# $today=($year+1900)."-".($month+1)."-".$day;
# $mv_msg = `sudo mv /opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx /opt/sap/bcp_data/mpr_data/mpr_payroll/backup/MPR_Export_Hourly_Payroll_$today.csv 2>&1`;

$scpError=`scp -p /home/sybase/db_backups/shippingws.dmp sybase\@10.3.1.165:/home/sybase/db_backups`;
#print "$scpError\n";

$scpError  = $? >> 8;
if ($scpError != 0) 
	{print "Sending of file NO\n";}
	else 
	{print "Sending of file DONE\n";}
	