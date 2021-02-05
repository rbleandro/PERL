#!/usr/bin/perl -w

##############################################################################
#Script:   This script run every day                                         #
#                                                                            #
#                                                                            #
#Author:   Ahsan Ahmed
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#10/10/2012      Ahsan Ahmed      Created
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

#Setting Sybase environment is set properly

require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute  sp_updRbc_cmf_scandates

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data
go
execute sp_updRbc_cmf_scandates
go
exit
EOF
`;
print $sqlError."\n";

 if ($sqlError =~ /Error/i || $sqlError =~ /no/i || $sqlError =~ /message/i){
      print "Messages From sp_updRbc_cmf_scandates...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,fqi\@canpar.com
Subject: sp_updRbc_cmf_scandates errors --   not processed!!

$sqlError
EOF
`;
}else{
#...

}
