#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Jul 14 2008	Amer Khan 	Originally created                           #
#                                                                            #
##############################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "Mounting folder, if it is already not done yet...\n";

$mount_msgs = `sudo mount cpcluster.canpar.com:/Prodpoll/XNET/MANAGER/MAN/service-now /opt/sybase/service_now_mount 2>&1`;

print "Any mounting messages, alread mounted messages can be ignored:\n\n $mount_msgs\n";

print "Service-Now LDAP Extract StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sybase/SYBASE.sh
bcp cmf_data..vw_svc_now_ext_cust_ldap out /opt/sybase/service_now_mount/sybase_cmf_cust_list.tdl -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"\t" -r"\r\n" 
`;

print $sqlError."\n";

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - Service-Now LDAP Extract

Following status was received during Service-Now LDAP Extract that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "Service-Now LDAP Extract FinTime: $currTime\n";

