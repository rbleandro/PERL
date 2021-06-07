#! usr/bin/perl

package Validation;
use Sys::Hostname;
use strict;
use warnings;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT_OK = qw( send_alert checkProcessByName showDefaultHelp isProd );
our @EXPORT = qw( send_alert );

sub send_alert
{
	my $error = shift;
	my $pattern = shift;
	my $fsmail = shift;
	my $mail = shift;
	my $scriptname = shift;
	my $phase = shift;
	my $finTime=localtime();
	my $log = $scriptname;
	my @ar = split (/\//,$scriptname);
	my $sname = $ar[-1];
	
	$log =~ s/(\w+).pl$/cron_logs\/$1.log/g;
	
	if ($error =~ /$pattern/){
		$finTime=localtime();
		print "$error\n\nPhase: $phase\n\n";
		$error =~ s/\n/<\/br>/g;
		
		if ($fsmail == 0){
			open(MAIL, "|/usr/sbin/sendmail -t");
            print MAIL "To: $mail\@canpar.com\n";
            print MAIL "From: sybase\@canpar.com\n";
            print MAIL "Subject: Sybase ASE job $sname failed during $phase phase.\n";
            print MAIL "Content-Type: text/html\n";
            print MAIL "MIME-Version: 1.0\n\n";
            print MAIL "<p>$error</p><p>Script path: perl $scriptname</p><p>Script log path: cat $log</p>";
            close(MAIL);
		
            die "Email sent at $finTime\n";
		}
		die "Aborting due to previous errors at $finTime\n";
	}
}

sub checkProcessByName
{
	my $checkProcessRunning = shift;
	
	if ($checkProcessRunning){
		my $filename = shift;
		
		my $my_pid = getppid();
		
		my $isProcessRunning =`ps -ef|grep sybase|grep "$filename"|grep -v grep|grep -v $my_pid`;
		
		if ($isProcessRunning){
			die "Aborting! Previous process $isProcessRunning is still running. To skip this check, execute the script with -p 0 \n";
		}else{
			print "No Previous process is running. Proceeding...\n";
		}
	}
}

sub isProd{
	my $skipcheckprod=shift;
	my @prodline;
	
	if ($skipcheckprod == 0){
		open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
		while (<PROD>){
			@prodline = split(/\t/, $_);
			$prodline[1] =~ s/\n//g;
		}
		close PROD;
		if ($prodline[1] eq "0" ){
			die "Aborting! This is a stand by server. Execute the script with -s 1 to force the execution here. \n";
		}else{
			print "Good, we're allowed to run in this server. Proceeding... \n";
		}
	}
}

sub showDefaultHelp{
	my $defhelp = shift;
	my $scriptname = shift;
	
	if ($defhelp){
	print "\nUsage: $scriptname --skipcheckprod|-s 0 --to|-r crazybob --dbserver|-ds <server> --noalert --skipcheckprocess --help|-h\n\nSwitches explanation:\n\n--skipcheckprod: \n\tSkips the server check, allowing you to run the program on servers that are not production\n\n--skipcheckprocess:\n\tThe script will not check for other executions of the same script (search by file name).This will enable multiple instances to run.\n\n\tCaution: parallel executions can have undesired effects.\n\n--to: \n\tChanges the destination of the alerts to the email specified. Type in only the text before the @ sign. ie: if your email is xyz\@xpto.com, type only xyz for this parameter\n\n--noalert:\n\tInstructs the script to skip sending mail alerts. It will still print any error or messages to the client.\n\n--help:\n\tShows this help\n\n--dbserver:\n\tServer the script should point at when running database queries\n\n\tThe switches above are optional. This script might contain other parameters for thresholds and other behavior changes (most monitor scripts do and won't work properly without valid values for those parameters). Check the script's source for more details.\n\n";
	exit;
	}
}
1;