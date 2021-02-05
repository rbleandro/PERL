#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

#if the operations folder is not mounted, use the command below to do so
#sudo mount "//10.3.1.186/Department/Information Technology/DevDump/operations" C:\Users\rafael_leandro\Downloads/operations -o username=em_process1,password=Canpar_2001,domain=canparnt

use strict;
use warnings;
#use lib '/opt/sybase/perl5/lib/perl5'; #this is necessary to make sure cron sees the XLSX package
use Spreadsheet::XLSX;

if (not -e "C:\\temp\\Book1.xlsx"){ 
	die "no file found";
}

my $numcols = 1;
my $line;
my $excel = Spreadsheet::XLSX -> new ('C:\\temp\\Book1.xlsx');

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
