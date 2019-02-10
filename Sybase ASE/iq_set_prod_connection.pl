#!/usr/bin/perl -w

##############################################################################
#Description	Suspends or resume sybrep2 iq_stage connection.              #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 2 2013	Amer Khan 	Originally created                           #
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
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1"; 
}
else
{
   $standbyserver = "CPDB2";
}

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

#Store inputs
$switch = $ARGV[0];

print "iq_set_connection: StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

if ($switch eq 'suspend'){#if input asks for suspend the connection
   $sqlerror = `. /opt/sybase/SYBASE.sh
isql -Usa -w200 -Ps9b2s3 -Ssybrep2 -b -Jroman8 <<EOF 2>&1
suspend connection to $prodserver.iq_stage   
go
exit
EOF
`;
}else{
   $sqlerror = `. /opt/sybase/SYBASE.sh
isql -Usa -w200 -Ps9b2s3 -Ssybrep2 -b -Jroman8 <<EOF 2>&1
resume connection to $prodserver.iq_stage   
go
exit
EOF
`;
}#Else resume it

print "$sqlerror\n";

if($sqlerror =~ /Msg/ || $sqlerror =~ /error/i){
print "Error Setting Connection\n";
print "$sqlerror\n\n";
}else{
print "Success!\n";
}

