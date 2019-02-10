#!/usr/bin/perl -w

##############################################################################
#Script:   This script loads data into fedexresult table for last two        #
#          weeks every night                                                 #
#                                                                            #
#Author:   Ahsan Ahmed
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute audit_thresh

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use sybsecurity    
go   
execute audit_thresh   
go    
exit
EOF
bcp sybsecurity..audit_report_vw out /tmp/audit_report_vw.dat -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -c -t"|:|" -r"||\n"
`;
print $sqlError."\n";

open (BCPFILE,">/tmp/audit_report_vw.dat1") || print "cannot create $!\n";
open (INFILE,"</tmp/audit_report_vw.dat") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\|\|\n$/||/;
   $_ =~ s/\0/ /g; #Control characters to be taken out
   $_ =~ s/\r/ /g;
   $_ =~ s/\n/ /g;
   $_ =~ s/\t//g;

chomp;

print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

open (BCPFILE,">/tmp/audit_report_vw.dat2") || print "cannot create $!\n";
open (INFILE,"</tmp/audit_report_vw.dat1") || print "cannot open: $!\n";

while (<INFILE>){
#last;
   $_ =~ s/\|\|/\n/g;
   $_ =~ s/\|\:\|/\t/g;

print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;

open (BCPFILE,">/tmp/audit_report_vw.tdl") || print "cannot create $!\n";
open (INFILE,"</tmp/audit_report_vw.dat2") || print "cannot open: $!\n";

while (<INFILE>){
#last;

   if (/\#\w/){ #Remove any temporary tables statments...
#      print "Skipping This: $_\n";
      next;
   }
#   print "Keeping This: $_\n";
print BCPFILE $_;
}#eof while loop

close BCPFILE;
close INFILE;


#$finTime = localtime();

#$currDay=sprintf('%02d',((localtime())[6]));

#if ($currDay eq '01'){

`/usr/bin/mutt -s "Weekly Audit Report"  "frank_orourke\@canpar.com,jim_pepper\@canpar.com,dharmesh.kelawala\@loomis-express.com,rshan\@canpar.com" -a /tmp/audit_report_vw.tdl <<EOF
Here is your weekly audit report.

Thanks,
Amer
EOF
`;
#}else{
#print "Not emailing, because today is not Monday \n";
#}
