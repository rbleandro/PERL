#!/usr/bin/perl
#############################################################
#	This script is used to split large UP files which       #
#	exceed the loomis required length of 10,000 records     #
#                                                           #
#Author:		Amer Khan                                   #
#Date Created:	Jul 12, 2013                                #
#############################################################

###
# Get starting file name sequence
###
if ($#ARGV < "0"){
   die "Must provide starting UP sequence \n";
}
print "Input cnt: $#ARGV \n";
$UP_src = $ARGV[0];
print "Starting UP: $UP_src \n";

$UP_cntr = 1;
$line_cntr = 0;
$offset = 9500; # Change this to the max of the file limit
$nxt_cntr = $offset;

open (SRCFILE,"<virtuals/$UP_src") || print "Cannot open src file: $! \n";

my @UP_recs = <SRCFILE>;

close (SRCFILE);

print "Length: $#UP_recs \n";

while ($line_cntr < $#UP_recs){

   #Set Destination UP filename now...
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time + (60 * $UP_cntr));

   $year += 1900;
   $mon += 1;

   $mon=sprintf('%02d',$mon);
   $mday=sprintf('%02d',$mday);
   $min=sprintf('%02d',$min);
   $hour=sprintf('%02d',$hour);
   $sec=sprintf('%02d',$sec);

   $date_flag = "$wday $mon-$mday-$year $hour:$min:$sec";
   $lm_day=80      +$wday;

   print "UP file name: UP$lm_day$hour$min \n ";

   #Increment counter now...
   $UP_cntr += 1;

   open(DESTFILE,">C:\\loomis_ftp_scripts\\UP_files_bkp\\UP_Repush\\virtuals\\UP$lm_day$hour$min") || "Cannot create Destination UP file: $! \n";
   print DESTFILE "***START \n";
   while ($line_cntr < $nxt_cntr){
      if($UP_recs[$line_cntr] =~ /^\*\*\*/){
       $line_cntr += 1;
       next;
      }
      print DESTFILE $UP_recs[$line_cntr];
      $line_cntr += 1;

   }
   print DESTFILE "***END \n";
   close (DESTFILE);
   #Save next batch
    $nxt_cntr = $line_cntr - 1 + $offset;

}

#Now that we are done splitting... We need to wait until the last hour and min of the last UP file name has passed...
$last_hour = $hour;
$last_min = $min;
$last_lm_day = $lm_day;

while (1==1){

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);

$lm_day=80      +$wday;

last if ($lm_day > $last_lm_day);
last if ($hour > $last_hour);
last if ($min > $last_min);

sleep(120);
}
