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
$offset = 9590;

open (SRCFILE,"<$UP_src") || print "Cannot open src file: $! \n";

my @UP_recs = split('\s\s\s\s',`wc -l $UP_src`);


print "Totals Rows to Process: $UP_recs[0] \n";

print "We will be waiting for ".($UP_recs[0]/$offset+1)." minutes\n";
$secsToWait = (($UP_recs[0]/$offset)+1)*60;
#print "Seconds to wait $secsToWait \n";

my $rowcnt = 1;
FILE_LABEL: while (<SRCFILE>){
	if ($rowcnt == 1){
	my @file_array;
	}
	push @file_array, $_;
	$rowcnt += 1;
	next FILE_LABEL if $rowcnt < $offset;

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
	   $lm_day=73      +$wday;

	   print "UP file name: UP$lm_day$hour$min \n ";

	   #Increment counter now...
	   $UP_cntr += 1;

	   open(DESTFILE,">C:\\loomis_ftp_scripts\\UP_files_bkp\\UP_Repush\\UP$lm_day$hour$min") || "Cannot create Destination UP file: $! \n";
	   print DESTFILE "***START \n";
UP_FILE_LABEL: while ($line_cntr <= $#file_array){ 
		  if($file_array[$line_cntr] =~ /^\*\*\*/){
		   $line_cntr += 1;
		   next UP_FILE_LABEL;
		  }
		  print DESTFILE $file_array[$line_cntr];
		  $line_cntr += 1;

	   }
	   print DESTFILE "***END \n";
	   close (DESTFILE);

	   $line_cntr = 0;
	   undef @file_array;
	   $rowcnt = 1;
}
if ($rowcnt > 0 && $rowcnt < $offset){ #This is needed for the last remaining records that do not add up to full 9950
print "Last Rowcount $rowcnt \n";
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
	   $lm_day=73      +$wday;

	   print "UP file name: UP$lm_day$hour$min \n ";

	   #Increment counter now...
	   $UP_cntr += 1;

	   open(DESTFILE,">C:\\loomis_ftp_scripts\\UP_files_bkp\\UP_Repush\\UP$lm_day$hour$min") || "Cannot create Destination UP file: $! \n";
	   print DESTFILE "***START \n";
UP_FILE_LABEL2: while ($line_cntr <= $#file_array){ 
		  if($file_array[$line_cntr] =~ /^\*\*\*/){
		   $line_cntr += 1;
		   next UP_FILE_LABEL2;
		  }
		  print DESTFILE $file_array[$line_cntr];
		  $line_cntr += 1;

	   }
	   print DESTFILE "***END \n";
	   close (DESTFILE);

	   $line_cntr = 0;
	   undef @file_array;
	   $rowcnt = 1;

}
#Now that we are done splitting... We need to wait until the last hour and min of the last UP file name has passed...

print "Waiting for $secsToWait seconds\n";
#$secsToWait = 5;
sleep($secsToWait);

print "Wait's Over: ".localtime()." \n";
