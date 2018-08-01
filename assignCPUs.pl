#!/usr/bin/perl -w

###################################################################################
#Script:   This script assigns sybase process to specific CPUs to prevent         #
#          resrouce hogging for example when a dump starts                        #
#                                                                                 #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jun 1,07	Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

use Sys::Hostname;
$prodserver = hostname();

# Grab the pid of the first engine...
$first_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "s$prodserver" | grep -v sh | gawk '{print \$2}'`;

$second_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "ONLINE:1" | grep -v sh | gawk '{print \$2}'`;

$third_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "ONLINE:2" | grep -v sh | gawk '{print \$2}'`;

$fourth_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "ONLINE:3" | grep -v sh | gawk '{print \$2}'`;

$fifth_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "ONLINE:4" | grep -v sh | gawk '{print \$2}'`;

$sixth_engine_pid = `ps -ef | grep sybase | grep \\/bin | grep "ONLINE:5" | grep -v sh | gawk '{print \$2}'`;

$first_engine_pid =~ s/\n//; $second_engine_pid =~ s/\n//; $third_engine_pid =~ s/\n//; $fourth_engine_pid =~ s/\n//; $fifth_engine_pid =~ s/\n//; $sixth_engine_pid =~ s/\n//;

#print "1: $first_engine_pid ... 2: $second_engine_pid ... 3: $third_engine_pid ... 4: $fourth_engine_pid ... 5: $fifth_engine_pid ... 6: $sixth_engine_pid \n";

# Assign task affinity to process id grabbed

# Assigning first engine to first CPU...

$assignMsg = "First Engine: ".`taskset 1 -p $first_engine_pid`;
#print "$assignMsg\n";

# Assigning second engine to second CPU...

$assignMsg .= "\nSecond Engine: ".`taskset 2 -p $second_engine_pid`;
#print "$assignMsg\n";

# Assigning third engine to third CPU...

$assignMsg .= "\nThird Engine: ".`taskset 4 -p $third_engine_pid`;
#print "$assignMsg\n";

# Assigning fourth engine to fourth CPU...

$assignMsg .= "\nFourth Engine: ".`taskset 8 -p $fourth_engine_pid`;
#print "$assignMsg\n";

# Assigning fifth engine to fifth CPU...

$assignMsg .= "\nFifth Engine: ".`taskset 16 -p $fifth_engine_pid`;
#print "$assignMsg\n";

# Assigning sixth engine to sixth CPU...

$assignMsg .= "\nSixth Engine: ".`taskset 32 -p $sixth_engine_pid`;
print "$assignMsg\n";

$currTime = localtime();

   if($assignMsg =~ /Report|usage|permission|denied|such/){
      print "TaskSet Errors!!...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: TASKSET ERRORS

Following status was received after taskset that started on $currTime
$assignMsg
EOF
`;
} 
