#!/usr/bin/perl -w

###################################################################################
#Script:   This script monitors sybase server  cronjobs that are left             #
#          commented for some reason, which should be uncommented. An email will  #
#          also be sent to inform us if any job is  not running.                  # 
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#10/06/06       Ahsan Ahmed       Originally created                              #
#                                                                                 #
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Saving argument
$crontab = $ARGV[0];
$createcrontab =`crontab -l > /tmp/crontab.log`;
if($createcrontab){
   print "crontab log created ".$createcrontab."\n";
}
# Open the crontab.log file

$file = "/tmp/$crontab.log";		
open(INFO, $file);		# Open the file
#Scanning the crontab.log...
while (<INFO>) {
if (substr($_,0,2) ge '#0' and substr($_,0,2) le '#9')
{
$line[$i] = $_;
$i += 1;
}
}
close(INFO);                   # Close the file

if( $i > 0)
{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Comments found on $prodserver cronjob

Job(s) Commented out on CPDB2 cronjob.

@line
EOF
`;
}

`rm /tmp/$crontab.log`; 
