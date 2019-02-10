#!/usr/bin/perl -w

###################################################################################
#Script:   This script monitors sybase server errorlog for critical and fatal     #
#          errors. It is designed to run every minute and scan the errorlog and   #
#          send messages when errors are found. It also monitors whether the      #
#          $server server and Backup server is up                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#01/07/04       Amer Khan       Originally created                                #
#                                                                                 #
#02/23/06      Ahsan Ahmed      Modified for email to DBA's and documentation     #  
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage: monitor_errorlog.pl $server \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Saving argument
$server = $ARGV[0];

open(ERRORLOG,"</opt/sybase/ASE-15_0/install/$server.log") or die "Can't open the file /opt/sybase/ASE-15_0/install/$server.log: $!\n\n";

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute
#what if the minute is 00, the result would be -1 instead of 59, correcting that
if($currMin == "-1"){
   $currMin = "59";
}
#Prunning monitor script log every 24 hours at 00:00
if($currHour == "00" && $currMin == "00"){
   `cat /dev/null > /opt/sybase/cron_scripts/cron_logs/monitor_errorlog_$server.log`;
}

print "Errorlog Checked: $currDate\-$currHour\:$currMin\n";

#Scanning the errorlog...
$getNextLine = 0;
$tooManyErrors = 0;
while (<ERRORLOG>){
   if($getNextLine == 1){
      $tooManyErrors += 1;
      $secondLine = $_;
      print "$firstLine$secondLine\n";
      if(($tooManyErrors < 5 ) && ($firstLine !~ /Deadlock/)){
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $server Error Alert

Errors Found In $server Errorlog!!!
$firstLine$secondLine
EOF
`;
print "*********\nMail Sent To DBAs\@canpar.com\n*********\n";
      }else{
         if($tooManyErrors == 5){
         `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: $server Error Alert

Errors Found In $server Errorlog!!!
!!!!!!!!!!!!Too Many Errors Logged At $currDate\--$currHour\:$currMin!!!!!!!!!!!!!!!!!
EOF
`;
print "*********\nMail Sent To DBAs\@canpar.com\n*********\n";
         }
      }
      $getNextLine = 0;
      next;
   }
   if(/$currDate/){
      if (/$currHour\:$currMin\:/){
         if((/cease/ || /webtest/ || /Error/ || /sleeping/i || /critically/i || /failed/i || /degradation/i || /deadlock/i || /stack trace/i || /fatal/i || /critical/i || /severity\: [10..26]/i)&&(!/1608/ && !/Ct-library/)){
	    $firstLine = $_;
            $getNextLine = 1;
         }
      }
   }
}

close ERRORLOG;
#Check if the server is still up
$isServerUp =`ps -ef|grep sybase|grep dataserver|grep $server`;
if($isServerUp){
#   print "server is running ".$isServerUp."\n";
`echo 0 > /tmp/asesrvcnt`;
}else{
   $ASEINITSRVCNT = `cat /tmp/asesrvcnt`;  # ASE INITial SRV CNT
   if ($ASEINITSRVCNT == 3 ){
      print "!!!Not notifying any one, but ASE Server Is STILL Down!!!\n";
   }else{
      $ASEINITSRVCNT = $ASEINITSRVCNT + 1;
      `echo $ASEINITSRVCNT > /tmp/asesrvcnt`;
      print "\n\n***!!!Server Is Down...!!!***\n\n";
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: $server IS DOWN!!!

\*\*\*\!\!\!Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

`mail -s "$server IS DOWN!!!" \`cat /opt/sybase/sybmail/SYB_DEV_GROUP\` <<EOF
\*\*\*\!\!\!Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

   }
}

#Check if the backup server is still up
undef $isServerUp;
$isServerUp =`ps -ef|grep sybase|grep backupserver|grep $server`;
if($isServerUp){
#   print "\nserver is running ".$isServerUp."\n";
`echo 0 > /tmp/bsrvcnt`;
}else{
   $BINITSRVCNT = `cat /tmp/bsrvcnt`;
   if ($BINITSRVCNT == 2){
      print "!!!Not notifying any one, but Backup Server Is STILL Down!!!\n";
   }else{
      $BINITSRVCNT = $BINITSRVCNT + 1;
      `echo $BINITSRVCNT > /tmp/bsrvcnt`;
      print "\n\n***!!!Backup Server Is Down!!!***\n\n";
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $server Backup Server IS DOWN!!!

\*\*\*\!\!\!Backup Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;
   }
}
