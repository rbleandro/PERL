#!/usr/bin/perl -w

###################################################################################
#Script:   This script reloads data into shipper tables from cmf and dispatch     #
#          tables                                                                 #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#03/31/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage: reload_shipper_onto_cpscan.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];

#Execute reload_shipper_onto_cpscan

print "\n###Running reload_shipper_onto_cpscan on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating reload_shipper_onto_cpscan At:".localtime()."***\n";
#$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usybmaint -P\`/opt/sybase/cron_scripts/getpass.pl sybmaint\` -S$server -b -n<<EOF 2>&1
#exit
#EOF
#`;
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -b -n -i/opt/sybase/cron_scripts/sql/reload_shipper_onto_cpscan`;
print $sqlError."\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "Messages From reload_shipper_onto_cpscan...\n";
      print "$sqlError\n";
}
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: reload_shipper_onto_cpscan: $database

$sqlError
EOF
`;
