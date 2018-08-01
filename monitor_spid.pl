#!/usr/bin/perl

###################################################################################
#Script:   This script monitors spid and tries to record its actions              #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars

#Cleanup previous files...
$startHour=sprintf('%02d',((localtime())[2]));
$currTime = localtime();

#Execute IO Monitoring 

$error = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$prodserver -n -b<<EOF 2>&1
set nocount on
set rowcount 1
execute trace_spid
go    
exit
EOF
`;

if ($error =~ /FOUND IT/){
print $error;

$error =~ s/\s//g;
$error =~ s/\t//g;

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: SPID Found!!!

Spid Found!!  at $currTime 
******
$error
******
EOF
`;
}else{ print "Nothing Yet\n"; }
