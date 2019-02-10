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


#Start replication setup on 0 or 30th minute so that it won't kick off a page...
$startMin=sprintf('%02d',((localtime())[1]));
$Min = int($startMin);

if ($Min >= 22 && $Min < 52){
$sleep_for = (52 - $Min); #Minutes
sleep($sleep_for*60);
}
if ($Min >= 52){
$sleep_for = ((60 - $Min) + 22); #Minutes
sleep($sleep_for*60);
}
if ($Min >= 0 && $Min < 22){
$sleep_for = (22 - $Min); #Minutes
sleep($sleep_for*60);
}

print "!!".`date`."!!\n";

