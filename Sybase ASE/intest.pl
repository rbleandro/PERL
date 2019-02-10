#!/usr/bin/perl

###################################################################################
#Script:   This script purges tables that record any inserts, updates or deletes  #
#          in event and parcel tables                                             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#May 9,05	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################



$startMin=sprintf('%02d',((localtime())[1]));
$Min = int($startMin);

if ($Min > 30){
$sleep_for = (59 - $Min + 1); #Minutes
sleep($sleep_for*60);
}else{
$sleep_for = (30 - $Min); #Minutes
sleep($sleep_for*60);
}
