#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan                                                        #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Feb 13 2012    Amer Khan       Originally created                           #
#                                                                            #
##############################################################################

use Date::Calc qw/Delta_Days/;;
use POSIX;

my $file = "./purge_old_files.pl";

my $ftime = POSIX::strftime(
             "%y,%m,%d",
             localtime(
                 ( stat $file )[9]
                 )
             );
@ftime = split(/\,/,$ftime);

my $currtime = POSIX::strftime("%y,%m,%d", localtime());

@currtime = split(/\,/,$currtime);

print "@ftime \n";
print "@currtime \n";


$Dd = Delta_Days(@currtime,@ftime);

print "Delta $Dd \n";
