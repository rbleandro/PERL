#!/usr/bin/perl -w

###################################################################################
#Script:   This script kills all processes logged into the specified database, so #
#          that the load process can be initiated which requires every one to be  #
#          logged out of that database being loaded                               #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/30/03	Amer Khan	Originally created                                #
#01/19/04	Amer Khan	Modified to be used with all dbs		  #
#                                                                                 #
###################################################################################

#Usage Restrictions

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
#print "@spid\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: Test to the mobile (page)  and DBA group email

Following status was received after during email test
EOF
`;
