#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

use strict;
use warnings;
use Spreadsheet::XLSX;
 
if (-e "C:\\temp\\Book1.xlsx"){
	my $excel = Spreadsheet::XLSX -> new ('C\Book1.xlsx');
	my $line;
	foreach my $sheet (@{$excel -> {Worksheet}}) {
		#printf("Sheet: %s\n", $sheet->{Name});
		$sheet -> {MaxRow} ||= $sheet -> {MinRow};
		foreach my $row ($sheet -> {MinRow} .. $sheet -> {MaxRow}) {
			$sheet -> {MaxCol} ||= $sheet -> {MinCol};
			foreach my $col ($sheet -> {MinCol} ..  $sheet -> {MaxCol}) {
				my $cell = $sheet -> {Cells} [$row] [$col];
				if ($cell) {
					#$line .= "\"".$cell -> {Val}."\",";
					$line .= $cell -> {Val};
					#if ($col != $sheet -> {MaxCol})
					#{
						$line .= ",";
					#}
				}
			}
			chomp($line);
			print "$line\n";
			$line = '';
		}
	}
}
#print "\n";