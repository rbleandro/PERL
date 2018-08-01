#!/usr/bin/perl -w

###################################################################################
#Script:   This script will do when we transfer scripts from one server to        #
#          another and back, we won't have to changes names each time.            #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#12/08/06       Ahsan Ahmed       Originally created                              #
#                                                                                 #
#12/22/06      Ahsan Ahmed      Modified                                          #
###################################################################################

$hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);
$day=sprintf('%02d',((localtime())[6]));
$day= int($day);
print "Hour: $hour and Day is: $day \n";

while ($hour != 5 && $day != 0){
sleep(5);
$hour=sprintf('%02d',((localtime())[2]));
$hour = int($hour);
print "In hour : $hour\n";
}



