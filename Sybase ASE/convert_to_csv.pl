#!/usr/bin/perl

#This script converts an excel file to csv. Make sure the right PERL module (and its dependencies) are installed.
#Author: Rafael Bahia

use strict;
use warnings;
use Spreadsheet::XLSX;
 
if (-e "/opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx"){
	my $excel = Spreadsheet::XLSX -> new ('/opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx');
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
					if ($col != $sheet -> {MaxCol})
					{
						$line .= ",";
					}
				}
			}
			chomp($line);
			print "$line\n";
			$line = '';
		}
	}
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - mpr_payroll_hourly.pl - xlsx file unavailable

The file MPR_Export_Hourly_Payroll.xlsx is not available at /opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx yet. Please make sure it is generated and run the script mpr_payroll_hourly.sh again.

EOF
`;

die "File not available yet, dying\n\n";
}