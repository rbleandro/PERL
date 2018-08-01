#!/usr/bin/perl -w

##############################################################################
#Description	Spread CPU load evenly across both cores.                    #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 7 2013	Amer Khan 	Originally created                           #
#                                                                            #
##############################################################################

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "set CPU Affinity: StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Check to see if all engines are up
$engine_count=`ps -eo start,user,etime,psr,cmd | grep sybase | grep dataserver | grep ASE-15 | wc -l`;
if ($engine_count < 8) # Using a number that is less than 12, since we are supposed to have 12 engines running. If you have atleast 8 running, then you can safely assume that 12 would be running
{
 $engine_count =~ s/\n//;
print "Only $engine_count engines are up, waiting for more to come online... \n";
$remove = `rm /tmp/engine_cpu_taskset_done`;
print "Remove Msg: $remove \n";
die;
}

if (-e "/tmp/engine_cpu_taskset_done")
{
 print "Engines Already Set \n";
 die;
}


#Store output
$engines = `ps -ef | grep sybase | grep ASE-15_0 | grep dataserver | awk \'{ printf \$2\" \" }\'`;

print "Engines PIDs: $engines \n";

@engine_array=split(/\s/,$engines);

$cpu=0;

foreach(@engine_array)
{
 print "$_ assign to $cpu \n";
 $assign=`taskset -pc $cpu $_`;
 print "Assignment Log: $assign \n";
 $cpu++; $cpu++;
}

$touchme = `touch /tmp/engine_cpu_taskset_done`;
print "Touch Msg: $touchme \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: CPUs to Engines Taskset Completed.

$currTime
=====================================
Engine Count Found Initially... $engine_count
All engines found in the end ... $engines
=====================================
Completed.
EOF
`;

