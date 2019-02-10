#!/usr/bin/perl

###################################################################################
#Script:   CPIQ Server Heart Beat Monitor                                         #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#04/20/04       Amer Khan       Originally created                                #
#06/04/04       Amer Khan	Modified to bring server up automatically         #
#                               Modified sendmail to send server up & down        #
#                                                                                 #
###################################################################################

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1])); #Subtract one to check the past minute
#what if the minute is 00, the result would be -1 instead of 59, correcting that
if($currMin == "-1"){
   $currMin = "59";
}
#sleep 100;
#Skip checking at 5:30AM for purge job
print "Current hour: $currHour...Curr Min: ". ($currMin - 1) ."\n";
if($currMin eq "38" && $currHour eq "09"){
   die "\nSkipping monitoring for purge schedule\n";
}

$isProcessRunning=`ps -ef|grep purge|grep IQ|grep -v sh`;
if($isProcessRunning){
   die "Process already running";
}
#Check if the server is still up
$isServerUp =`ps -ef|grep sybase|grep asiqsrv12|grep cpiq1|grep -v sh`;
if($isServerUp){
   #print "server is running \n";
   $ASIQINITSRVCNT = `cat /tmp/asasrvcnt`;
   if ($ASIQINITSRVCNT != 0){
   print "Sending mail for server up\n";
   `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: IQ SERVER ON CPIQ IS BACKUP NOW!!!

\*\*\*\!\!\!Server Is Back Up Now\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

   }
`echo 0 > /tmp/asasrvcnt`;
}else{
   print "Attempting to restart the server...\n";
   $ASIQINITSRVCNT = `cat /tmp/asasrvcnt`;  # ASA INITial SRV CNT
   if ($ASIQINITSRVCNT == 2 ){
      print "!!!Not notifying any one, but IQ Server Is STILL Down!!!\n";
   }else{
      print "Sending mail for server down\n";
      $ASIQINITSRVCNT = $ASIQINITSRVCNT + 1;
      `echo $ASIQINITSRVCNT > /tmp/asasrvcnt`;
      print "\n\n***!!!IQ Server Is Down...!!!***\n\n";
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: IQ SERVER ON NEW CPIQ IS DOWN!!!

\*\*\*\!\!\!Server Is Down\!\!\!\*\*\*

Dated: $currDate\--$currHour\:$currMin
EOF
`;

   }
   exec("/opt/sybase/cron_scripts/purge_IQ_server.sh &");
}

