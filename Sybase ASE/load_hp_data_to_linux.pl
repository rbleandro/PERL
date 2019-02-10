#!/usr/bin/perl -w

###################################################################################
#Script:   This script recovers hp sybase data through sybase dumps and saves it  #
#          back to tape in bcp format, so that it may be used in linux            #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#12/30/03	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Setting Sybase environment is set properly

require "/opt/sybase/cron_scripts/set_sybase_env.pl";

print "\n\n*******************************\n\n";
print "You Are Now Starting Recovery Process...\n";
print "\n\n*******************************\n";
print "\nPlease read instructions carefully before entering information\n\n";
print "*********************************\n\n";
sleep(2);

$email_add = '';
STARTOVER:

print "\nPlease enter the name of the tape you are recovering: ";
while (<STDIN>){
   if (/^\n/){
      print "Please enter the name of the tape you are recovering: ";
   }else{
      $_ =~ s/\n//;
      $_ =~ s/\s//;
      $dirname = $_;
      print "You entered: $dirname\nIs this correct?(y/n):";
      while (<STDIN>){
         if (/y/){
            $redo = 0;
            print "I will use $dirname to create the directory\n";
            last;
         }else{
	    $redo = 1;
            #print "Redo dirname: $redo\n";
            last;
         }
      }
      if ($redo == 1){
         print "Please enter the name again: ";
         next;
      }else{
         last;
      }
   }
}

print "\n\nPlease insert the tape in the HP Tape drive and hit enter...";
while (<STDIN>){
   if (/^\n/){
      print "\n\nI shall now proceed with the recovery...\n";
      sleep(1);
      last;
   }else{
      print "\nPlease hit enter only if you have already inserted the tape...";
   }
}

print "Is this the first tape being recovered for the DLT tape in Linux?(y/n) ";
while (<STDIN>){
   if (/^y/){
      $first_tape = 'y';
      last;
   }else{
      $first_tape = 'n';
      last;
   }
}


print "\n\nCreating directory for the current tape...\n\n";
`rm -fr /tmp/$dirname`;
$mkdir = `mkdir /tmp/$dirname`;
if ($mkdir !~ //){
   print "Unable to create directory: $mkdir\n";
}else{
   print "Created dir $dirname for bcp process...\n\n";
}

print "Please enter the email address \nwhere you would like to be notified when the load is complete: ";
while (<STDIN>){
   if (/^\n/ && $email_add eq ''){
      print "Please enter the email address where you would like to be notified: ";
   }else{
      if ($email_add ne ''){
         print "Should I use this same email address: (".$email_add.")?(y/n):";
      }else{
      $_ =~ s/\n//;
      $email_add_saved = $_;
      print "You entered: $email_add_saved\nIs this correct?(y/n):";
      }
      while (<STDIN>){
         if (/y/){
            $redo = 0;
            $email_add = $email_add_saved;
            print "\nA notification will be sent to this email address ($email_add) when the load process completes\n";
            sleep(2);
            last;
         }else{
	    $redo = 1;
            #print "Redo dirname: $redo\n";
            last;
         }
      }
      if ($redo == 1){
         print "Please try again: ";
         next;
      }else{
         last;
      }
   }
}

print "\n\n***Loading purge_data database from the tape to HP sybase...\n";
print "\n\n***This may take 15-20 minutes...Please stand by\n";

$load_error = `isql -Usa -P -SBCTT <<EOF 2>&1
load database purge_data from \"/dev/rmt/0mn\" capacity=4000000,
dumpvolume=\"p_urge\" with unload
go
online database purge_data
go
exit
EOF
`;
print "\n***\n$load_error\n***\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $email_add
Subject: Load Process Completed

Please check for errors and then hit enter to proceed or CTRL-C to cancel
*****************
$load_error
*****************
EOF
`;

print "\n\nPlease check for errors in the load process and hit enter to proceed or CTRL-C to cancel...";
while (<STDIN>){
   if (/^\n/){
      print "\n\nI shall now proceed with the bcp...\n";
      last;
   }else{
      print "Please hit enter only if no errors were found in the load...";
   }
}

print "Recovering purge_cp...\n";
`bcp purge_data..purge_cp out /tmp/$dirname/purge_cp.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_ct...\n";
`bcp purge_data..purge_ct out /tmp/$dirname/purge_ct.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_dc...\n";
`bcp purge_data..purge_dc out /tmp/$dirname/purge_dc.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_dr...\n";
`bcp purge_data..purge_dr out /tmp/$dirname/purge_dr.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_dt...\n";
`bcp purge_data..purge_dt out /tmp/$dirname/purge_dt.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_mb...\n";
`bcp purge_data..purge_mb out /tmp/$dirname/purge_mb.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_pa...\n";
`bcp purge_data..purge_pa out /tmp/$dirname/purge_pa.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_pr...\n";
`bcp purge_data..purge_pr out /tmp/$dirname/purge_pr.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_ps...\n";
`bcp purge_data..purge_ps out /tmp/$dirname/purge_ps.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_ev...\n";
`bcp purge_data..purge_ev out /tmp/$dirname/purge_ev.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;
print "Done.\nRecovering purge_hvr...\n";
`bcp purge_data..purge_hvr out /tmp/$dirname/purge_hvr.dat -Usa -P -SBCTT -c -t"|:|" -r"\n"`;

print "\nbcp of all tables is complete...\nProceeding with archiving data back into DLT tape...\n";

if($first_tape eq 'y'){
   `tar -cvf /dev/st0 /tmp/$dirname`;
}else{
   `tar -rvf /dev/st0 /tmp/$dirname`;
}

print "\n\n******************************Recovery complete!********************************\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: $email_add
Subject: Recovery Process Completed For This Tape

Please review the recovery results and start the process for the next tape or exit the program.
EOF
`;

print "Would you like to Start over with a new tape?(y/n) ";
while(<STDIN>){
   if(/y/){
     $start_over = 1;
     last; 
   }else{
     $start_over = 0;
     last;
   }
}

if ($start_over == 1){
   goto STARTOVER;
}else{
   print "Please type exit at the prompt to finish\n";
}


