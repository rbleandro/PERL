#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

use strict;
use warnings;
use Spreadsheet::XLSX;
 
if (-e "C:\\temp\\Book1.xlsx"){
	my $excel = Spreadsheet::XLSX -> new ('C:\\temp\\Book1.xlsx');
	my $line;
	my $column;
	foreach my $sheet (@{$excel -> {Worksheet}}) {
		#printf("Sheet: %s\n", $sheet->{Name});
		#print $sheet -> {MaxCol};
		$sheet -> {MaxRow} ||= $sheet -> {MinRow};
		foreach my $row ($sheet -> {MinRow}+1 .. $sheet -> {MaxRow}) {
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
				else{
					$column = $col;
					if ($column == 8){
						$line .= "1990-01-01";
					}else{
						$line .= " ";
					}
					$line .= ",";
				}
			}
			chomp($line);
			print "$line";
			$line = '';
		}
	}
}
#print "\n";

#perl C:\Users\rafael_leandro\Dropbox\DBA\ScriptWH\Perl\CPDB1\excel_to_csv.pl > c:\temp\dataload.csv
#upload file to server
#run the LOAD TABLE command in IQ (you can grab it from the DBA.reload_eng_temp procedure. Don't forget to change the path to the file)

#LOAD TABLE eng_temp FROM '/opt/sybase/cron_scrips/dataload.csv'
#DELIMITED BY 0x2c 
#--ROW DELIMITED BY 0x0d0a
#ESCAPES OFF 
#QUOTES OFF 
#FORMAT ASCII
