#!/usr/bin/perl -w

##############################################################################
#Script:   This script checks SVP URL delays                                 #
#                                                                            #
#Author:	Rafael Bahia												     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Oct 24 2018	Rafael Bahia	Created										 #
##############################################################################

$database = $ARGV[0];
$table = $ARGV[1]; 
$mail = $ARGV[2]; 

#Usage Restrictions
use Sys::Hostname;
$prodserver = 'CPSYBTEST';

#$deleteoldfiles =`find /opt/sap/db_backups/ -mindepth 1 -mtime +7 -delete`;

$bcpError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/bcp_r $database..$table out /opt/sap/db_backups/$database\_$table\_backup.dat -n -V -S$prodserver`;

if ($bcpError =~ /Error/ || $bcpError =~ /Msg/){
print $bcpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_data_to_test at $finTime

$bcpError
EOF
`;
die;
}

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver <<EOF 2>&1
use $database
go
truncate table $table
go
exit
EOF
`;
if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - dump_databases_to_test at $finTime

$sqlError
EOF
`;
die;
}

$bcpError=`. /opt/sap/SYBASE.sh 
/opt/sap/OCS-16_0/bin/bcp_r $database..$table in /opt/sap/db_backups/$database\_$table.dat -n -V -S$prodserver`;

if ($bcpError =~ /Error/ || $bcpError =~ /Msg/){
print $bcpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: Errors - copy_data_to_test at $finTime

$bcpError
EOF
`;
die;
}