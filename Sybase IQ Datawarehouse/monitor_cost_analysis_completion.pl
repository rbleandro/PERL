#!/usr/bin/perl

###################################################################################
#Script:   This script synchronizes tttl_ev_event data on regular scheduled basis #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#April 13,2005  Amer Khan       Originally created                                #
#March 5, 2007 Ahsan Ahmed      Modified
#                                                                                 #
###################################################################################

$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit /opt/sybase/cron_scripts/sql/IQ_cost_analysis_scan.sql 2>&1`;


if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: akhan\@canpar.com,aahmed\@canpar.com
Subject: COST Analysis Page error

$dbsqlOut
EOF
`;
die;
}

@infoArr = split(/\n/,$dbsqlOut);


foreach $line (@infoArr){
   if ($line =~ /email_add/){
      $count += 2;
      last;
   }else{
      $count += 1;
   }
}

@lineArr = split(/\s+/,$infoArr[$count]);

if ($#lineArr == -1){
die;
}else{
print "Working on: @lineArr \n";
}

$email = $lineArr[0];
$date1 = $lineArr[1]." ".$lineArr[2];
$date2 = $lineArr[3]." ".$lineArr[4];
$sample = $lineArr[5];

#`/usr/sbin/sendmail -FCost_Analysis -t -i <<EOF
#To: akhan\@canpar.com,$email\@canpar.com
#Subject: Load of cost_analysis in CPIQ is complete
#
#Period Processed: $date1 to $date2
#Records Processed: $rec_cnt
#
#Note: Please do not reply to this email, this is a machine generated email.
#
#Thanks
#Amer
#EOF
#`;

`/usr/sbin/sendmail -FCost_Analysis -t -i <<EOF
To: akhan\@canpar.com,$email\@canpar.com
Subject: Load\/Recalc of cost_analysis in CPIQ is complete for Sample: $sample

Note: Please do not reply to this email, this is a machine generated email.

Thanks
Amer
EOF
`;


$dbsqlOut = `. /opt/sybase/IQ-15_4/IQ-15_4.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "delete cost_analysis_notify where email_add = \'$email\'" 2>&1`;

print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "Messages From sync...\n";
      print "$dbsqlOut\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: akhan\@canpar.com,aahmed\@canpar.com
Subject: COST Analysis Page error 

$dbsqlOut
EOF
`;
die;
}

