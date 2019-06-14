#!/usr/bin/perl -w

#Script:   This script monitors sybase server errorlog for critical and fatal
#          errors. It is designed to run every minute and scan the errorlog and
#          send messages when errors are found. It also monitors whether the
#          CPDB1 server and Backup server is up
#
#Author:   Amer Khan
#Revision:
#Date           Name            Description
#------------------------------------------------------------------------------
#01/07/04       Amer Khan       Originally created
#
#02/23/06       Ahsan Ahmed      Modified for email to DBA's and documentation
#11/01/07       Ahsan Ahmed      Modified
#


open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

open(ERRORLOG,"</opt/sap/ASE-16_0/install/$prodserver.log") or die "Can't open the file /opt/sap/ASE-16_0/install/$prodserver.log: $!\n\n";
#open(ERRORLOG,"</opt/sap/ASE-16_0/install/CPDB2_last_night.log") or die "Can't open the file\n\n";

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
   `cat /dev/null > /opt/sap/cron_scripts/cron_logs/monitor_errorlog.log`;
}

#print "Errorlog Checked: $currDate\-$currHour\:$currMin\n";

if ($currHour == "02"  && $currMin == "00"){
`rm -fr /tmp/failedLogin/\*`;
}

#Scanning the errorlog...
$getNextLine = 0;
$tooManyErrors = 0;
while (<ERRORLOG>){
   if($getNextLine == 1){
      $tooManyErrors += 1;
      $secondLine = $_;
      print "$firstLine$secondLine\n";
      if(($tooManyErrors < 5 ) && ($firstLine !~ /Deadlock/) && ($firstLine !~ /Login failed/)){
      print "Error Found\n";

   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $prodserver Error Alert

Errors Found In $prodserver  Errorlog!!!
$firstLine$secondLine
EOF
`;
print "*********\nMail Sent To DBAs\@canpar.com\n*********\n";

      }else{
         if (($firstLine =~ /Login failed/)){
            #Send a message to Linux syslog about the failed login if login has failed more than 10 times within
			# an hour, irrespective of if there was a successful login within those failed logins in that hour
            $failedLogin = $firstLine;
            $failedLogin =~ s/(^.+User\:\s)(.+)(,.+$)(\n)/$2/;
            #print "My failed login:$failedLogin\n";

            if (-e "/tmp/failedLogin/$failedLogin"){
               $loginCheck = `cat /tmp/failedLogin/$failedLogin`;
               @loginArray = split(/\t/,$loginCheck);
               if ($loginArray[1] == 10 && $loginArray[2] == $currHour){
                  $log_msg = "$loginArray[0] has attempted at least 10 failed login in past hour";
                  #print "Sending message to syslog...$log_msg\n";
		  `/usr/bin/logger -t "Sybase ASE" $log_msg`;
		  $fileLine = "$failedLogin\t0\t$currHour";
		  `rm /tmp/failedLogin/$failedLogin`;
                  die "Incident Has Been Reported!!\n";
               }else{
                  $currCount = $loginArray[1];
                  if ($loginArray[2] == $currHour){
		     $currCount += 1;
		  }else{
		     $currCount = 1;
		  }
                  $fileLine = "$failedLogin\t$currCount\t$currHour";
                  `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
               }
            }else{
	       $currCount = 1;
               $fileLine = "$failedLogin\t$currCount\t$currHour";
               `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
            }

            #print "Sending message to syslog...$firstLine\n";
            #`/usr/bin/logger -t "Sybase ASE" $firstLine`;
         } # End of syslog logging

         if (($secondLine =~ /Login failed/)){
            #Send a message to Linux syslog about the failed login if login has failed more than 5 times in a row
            $failedLogin = $secondLine;
            $failedLogin =~ s/(^.+User\:\s)(.+)(,.+$)(\n)/$2/;
            #print "My failed login:$failedLogin\n";

            if (-e "/tmp/failedLogin/$failedLogin"){
               $loginCheck = `cat /tmp/failedLogin/$failedLogin`;
               @loginArray = split(/\t/,$loginCheck);
               if ($loginArray[1] == 10 && $loginArray[2] == $currHour){
                  $log_msg = "$loginArray[0] has attempted at least 10 failed login in past hour";
                  #print "Sending message to syslog...$log_msg\n";
                  `/usr/bin/logger -t "Sybase ASE" $log_msg`;
                  $fileLine = "$failedLogin\t0\t$currHour";
                  `rm /tmp/failedLogin/$failedLogin`;
                  die "Incident Has Been Reported!!\n";
               }else{
                  $currCount = $loginArray[1];
                  if ($loginArray[2] == $currHour){
                     $currCount += 1;
                  }else{
                     $currCount = 1;
                  }
                  $fileLine = "$failedLogin\t$currCount\t$currHour";
                  `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
               }
            }else{
               $currCount = 1;
               $fileLine = "$failedLogin\t$currCount\t$currHour";
               `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
            }

            #print "Sending message to syslog...$secondLine\n";
            #`/usr/bin/logger -t "Sybase ASE" $secondLine`;
         } # End of syslog logging



         if($tooManyErrors == 5 && ($firstLine !~ /Login failed/)){
         `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $prodserver Error Alert

Errors Found In $prodserver Errorlog!!!
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
            #print "Found it\n";
	    $firstLine = $_;
            $getNextLine = 1;
         }
      }
   }
}

# The following is needed in case the error is on the last line of the error log, because getnextline is only checked in the second line after the error is found.
if($getNextLine == 1){
      $tooManyErrors += 1;
      print "$firstLine\n";
      if(($tooManyErrors < 5)){#&& ($firstLine !~ /Deadlock/)){
      print "Error Found\n";
         if ($firstLine !~ /Login failed/){
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $prodserver Error Alert

Errors Found In $prodserver  Errorlog!!!
$firstLine
EOF
`;
print "*********\nMail Sent To DBAs\@canpar.com\n*********\n";
         }else{
            #Send a message to Linux syslog about the failed login if login has failed more than 5 times in a row
            $failedLogin = $firstLine;
            $failedLogin =~ s/(^.+User\:\s)(.+)(,.+$)(\n)/$2/;
            #print "My failed login:$failedLogin\n";

            if (-e "/tmp/failedLogin/$failedLogin"){
               $loginCheck = `cat /tmp/failedLogin/$failedLogin`;
               @loginArray = split(/\t/,$loginCheck);
               if ($loginArray[1] == 10 && $loginArray[2] == $currHour){
                  $log_msg = "$loginArray[0] has attempted at least 10 failed login in past hour";
                  #print "Sending message to syslog...$log_msg\n";
                  `/usr/bin/logger -t "Sybase ASE" $log_msg`;
                  $fileLine = "$failedLogin\t0\t$currHour";
                  `rm /tmp/failedLogin/$failedLogin`;
                  die "Incident Has Been Reported!!\n";
               }else{
                  $currCount = $loginArray[1];
                  if ($loginArray[2] == $currHour){
                     $currCount += 1;
                  }else{
                     $currCount = 1;
                  }
                  $fileLine = "$failedLogin\t$currCount\t$currHour";
                  `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
               }
            }else{
               $currCount = 1;
               $fileLine = "$failedLogin\t$currCount\t$currHour";
               `echo "$fileLine" > /tmp/failedLogin/$failedLogin`;
            }

            #print "Sending message to syslog...$firstLine\n";
            #`/usr/bin/logger -t "Sybase ASE" $firstLine`;

         } # End of syslog logging

      }else{
         if($tooManyErrors == 5 && ($firstLine !~ /Login failed/)){
         `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $prodserver Error Alert

Errors Found In $prodserver Errorlog!!!
!!!!!!!!!!!!Too Many Errors Logged At $currDate\--$currHour\:$currMin!!!!!!!!!!!!!!!!!
EOF
`;
print "*********\nMail Sent To DBAs\@canpar.com\n*********\n";
         }
      }
      $getNextLine = 0;
   }

close ERRORLOG;
#Check if the server is still up
$isServerUp =`ps -ef|grep sybase|grep dataserver|grep $prodserver`;
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
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: $prodserver IS DOWN!!!

\*\*\*\!\!\!Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

`mail -s "$prodserver IS DOWN!!!" \`cat /opt/sap/sybmail/SYB_DEV_GROUP\` <<EOF
\*\*\*\!\!\!Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

   }
}

#Check if the backup server is still up
undef $isServerUp;
$isServerUp =`ps -ef|grep sybase|grep backupserver|grep $prodserver`;
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
Subject: $prodserver Backup Server IS DOWN!!!

\*\*\*\!\!\!Backup Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;
   }
}
