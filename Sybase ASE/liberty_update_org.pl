#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Note:     This script updates the Liberty Scanned Pickup Record database    #
#          tables 'F_PUPRoc_Data' and 'F_PUProc_Rec' from Revenue History    #
#          data                                                              #
#Author:   Frasier Bellam                                                    #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2004/12/06   Frasier Bellam  Originally created                           #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
#$startHour=sprintf('%02d',((localtime())[6]));
$startHour=substr($currTime,0,3);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute liberty_update
#
print "***Initiating liberty_update At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Urhload -P\`/opt/sybase/cron_scripts/getpass.pl rhload\` -SCPDB2 -b -n<<EOF 2>&1
execute liberty2
go
exit
EOF
`;
print $sqlError."\n";
#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "Messages From liberty_update...\n";
      print "$sqlError\n";
}
`/usr/sbin/sendmail -t -i <<EOF
To: frasier_bellam\@canpar.com
Subject: Liberty_update

$sqlError
EOF
`;

