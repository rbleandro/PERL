#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

use strict;
use warnings;
use lib '/opt/sybase/perl5/lib/perl5'; #this is necessary to make sure cron sees the XLSX package
use Spreadsheet::XLSX;

if (-e "/opt/sybase/bcp_data/Book1.xlsx"){
	my $excel = Spreadsheet::XLSX -> new ('/opt/sybase/bcp_data/Book1.xlsx');
	my $line;
	my $numcols = 1;
	
	foreach my $sheet (@{$excel -> {Worksheet}}) {
		#printf("Sheet: %s\n", $sheet->{Name});
		$sheet -> {MaxRow} ||= $sheet -> {MinRow};
		$numcols = $sheet -> {MaxCol} + 1; #setup the number of columns in the sheet for later use
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
	}

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit 'update eng_temp_control set numcols=$numcols' 2>&1`;

#print "$dbsqlOut\n";
if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
     print "Messages From update eng_temp_control.pl...\n";
     print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: rleandro\@canpar.com
Subject: ERROR: IQ excel_to_csv.pl...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ excel_to_csv.pl...Aborting Now!!***\n\n";
}	
}
else{ 
	die "no file found";
}

