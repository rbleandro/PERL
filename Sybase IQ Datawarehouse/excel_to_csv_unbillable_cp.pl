#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

use strict;
use warnings;
use lib '/opt/sybase/perl5/lib/perl5'; #this is necessary to make sure cron sees the XLSX package
use Spreadsheet::XLSX;

if (-e "/opt/sybase/bcp_data/svb_unbillable.xlsx"){
	my $excel = Spreadsheet::XLSX -> new ('/opt/sybase/bcp_data/svb_unbillable.xlsx');
	my $line;
	my $value;
	#$sheet -> {MaxRow}
	foreach my $sheet (@{$excel -> {Worksheet}}) {
		$sheet -> {MaxRow} ||= $sheet -> {MinRow};
		foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
			$sheet -> {MaxCol} ||= $sheet -> {MinCol};
			foreach my $col ($sheet -> {MinCol} .. 11) {
				my $cell = $sheet -> {Cells} [$row] [$col];
				if ($cell) {
					$value = $cell -> {Val};
					$value =~ s/,/;/g; #replacing commas since this is the char separator used when loading data to IQ
					$line .= $value;
					$line .= ",";
				}else{
				$line .= ",";
				}
			}
			chomp($line);
			print "$line";
			$line = ''; #reset the line
		}
	}

}
else{ 
	die "no file found";
}

