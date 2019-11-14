#!/usr/bin/perl -w

####################################################################################################################################################################
#Script:   	Script to return the first seg block for the specified connection. This script relies on sqsh (an alternative for isql). Check sqsh to see the install 
#			procedure. 
#
#Author:   		Rafael Leandro
#Date           Name            Description
#---------------------------------------------------------------------------------
#Aug 08 2019    Rafael Leandro  Originally created
####################################################################################################################################################################

if ($#ARGV < 1){
   print "Usage: return_sqm_block.pl CPDB2 canshipws \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

my $server=$ARGV[0];
my $db=$ARGV[1];

$sqlError = `. /opt/sybase/SYBASE.sh
sqsh -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` <<EOF 2>&1
\\set style=vertical
admin who,sqm,$server,$db
go | grep "First"
exit
EOF
`;

@values = split(/:/,$sqlError);

print $values[1];
