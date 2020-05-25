#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

#if the operations folder is not mounted, use the command below to do so
#sudo mount "//10.3.1.186/Department/Information Technology/DevDump/operations" /opt/sybase/bcp_data/operations -o username=em_process1,password=Canpar_2001,domain=canparnt

use strict;
use warnings;
use lib '/opt/sybase/perl5/lib/perl5'; #this is necessary to make sure cron sees the XLSX package
use Spreadsheet::XLSX;

if (not -e "/opt/sybase/bcp_data/Book1.xlsx"){ 
	die "no file found";
}

my $numcols = 1;
my $line;
my $excel = Spreadsheet::XLSX -> new ('/opt/sybase/bcp_data/Book1.xlsx');

foreach my $sheet (@{$excel -> {Worksheet}}) {
	#printf("Sheet: %s\n", $sheet->{Name});
	$sheet -> {MaxRow} ||= $sheet -> {MinRow};
	$numcols = $sheet -> {MaxCol} + 1;
	foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
		$sheet -> {MaxCol} ||= $sheet -> {MinCol};
		foreach my $col ($sheet -> {MinCol} ..  $sheet -> {MaxCol}) {
			my $cell = $sheet -> {Cells} [$row] [$col];
			if ($cell) {
				$line .= $cell -> {Val};
				$line .= ",";
			}
		}
		chomp($line);
		print "$line";
		$line = ''; #reset the line
	}
	last;
}

my $dbsqlOut="";
#print "\n$numcols\n";

$dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'update DBA.eng_temp_control set numcols=$numcols' 2>&1`;

#print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
     print "Messages From update eng_temp_control.pl...\n";
     print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ excel_to_csv.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ excel_to_csv.pl...Aborting Now!!***\n\n";
}
