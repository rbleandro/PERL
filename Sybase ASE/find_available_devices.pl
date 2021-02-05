#!/usr/bin/perl -w

###################################################################################
#Script:   This script looks for all available devices for increasing db          #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#08/27/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV < 0){
   print "\n\nUsage: find_available_devices.pl servername \n";
   print "\n\nExample: find_available_devices.pl CPDB1 \n";
   die "\n\nScript Executed With Wrong Number Of Arguments\n\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];

print "***Initiating device find At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Ucronmpr -P\`/opt/sybase/cron_scripts/getpass.pl cronmpr\` -S$server <<EOF 2>&1
USE cpscan
go
exec find_devices
go
exit
EOF
`;
   if ($error =~ /Msg/ || $error ne ''){
      print "$error\n";
}

print "\n Note:- Any device where the usedMB is 0, this device is fully available\n".
      "        You can use upto the full size of it listed in sizeMB. For others    \n".
      "        You can only use upto the size listed in the usedMB column (sizeMB - usedMB).     \n";
