#!/usr/bin/perl -w

###################################################################################
#Script:   This script checks whether all servers are running after a reboot      #
#          It checks for Sybase ASE (CPDATA1), Sybase Backup Server and SQL Any-  #
#          where Mobilink Server                                                  #
#          server is up                                                           #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#01/12/04       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
use Sys::Hostname;
$prodserver = hostname();

#Saving argument
#Check if the server is up
$isServerUp =`ps -ef|grep sybase|grep dataserver|grep $prodserver`;
if($isServerUp){
   print "Sybase server $prodserver is running\n\n";
sleep(1);
}else{
   print "\n\n***!!!Sybase Server $prodserver  Is Down!!!***\n\n";
}

#Check if the Backup Server is up
$isServerUp =`ps -ef|grep sybase|grep backupserver |grep $prodserver`;
if($isServerUp){
   print "Sybase backup server is running\n\n";
   sleep(1);
}else{
   print "\n\n***!!!Sybase Backup Server Is Down!!!***\n\n";
}

#Check is the Mobilink Server is up
$isServerUp =`ps -ef|grep asa|grep dbmlsrv9`;
if($isServerUp){
   print "Mobilink Server is running\n\n";
   sleep(1);
}else{
   print "\n\n***!!!Mobilink Server Is Down!!!***\n\n";
}
