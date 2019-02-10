#!/usr/bin/perl 

###################################################################################
#Script:   This script shuts down Sybase ASE, you must be a valid user belonging  #
#          sybase group in order to shutdown Sybase Servers.                      #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#01/12/04	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";

#Set starting variables
$currTime = localtime();
$server = 'CPDB1';

#Confirm before executing shutdown command
print "\n*******You Are About To Shutdown Sybase ASE CPDB1*********\n\n";
$key = '';
$inLine = "Are You Sure, you want to shutdown Sybase ASE CPDB1?(Y/N) > ";
while ($key ne 'y'){
syswrite(STDIN,$inLine,length($inLine));
sysread(STDIN,$key,1);
if($key =~ /y/i){
   last;
}else{
   die "Exiting...\n\n";
}
}

$error = '';
print "\n\n***Initiating Shutdown On CPDB1 at:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF 2>&1
shutdown
go
EOF
`;
if ($error =~ /disconnected/){}else{
print "\nServer May NOT Have Shutdown, Check The Following Errors...\n";
print "$error\n";
}
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Shutdown Process Initiated!!

Shutdown Process Initiated By \`whoami\` at $currTime On CPDB1
$error
EOF
`;

