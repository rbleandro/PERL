#!/usr/bin/perl -w

########################################################################
#Script: This scripts retrieves passwords for logins from file named   #
#        passwords. It is only accessible by sybase                    #
#Author: Amer Khan                                                     #
#Revision:                                                             #
#Date		Name		Description                            #
#----------------------------------------------------------------------#
#12/19/03	Amer Khan	Originally created                     #
#                                                                      #
########################################################################

$login = $ARGV[0];
$login =~ s/\n//g;
open (PASS,"</opt/sybase/cron_scripts/passwords/passwords") or die "Can't Open password file: $!\n\n";

while (<PASS>){
   @passLine = split(/\t/,$_);
   $passLine[1] =~ s/\n//g;
   if ($login eq $passLine[0]){
      print "$passLine[1]";
   } 
}
