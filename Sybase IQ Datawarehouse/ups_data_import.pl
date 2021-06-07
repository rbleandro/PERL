#!/usr/bin/perl

#if the operations folder is not mounted, use the command below to do so
#sudo mount "//10.3.1.186/Department/Information Technology/DevDump/operations" /opt/sybase/bcp_data/operations -o username=em_process1,password=Canpar_2001,domain=canparnt

use strict;
use warnings;
use lib '/opt/sybase/perl5/lib/perl5'; 

if (not -e "/opt/sybase/bcp_data/ups_shipment_load.csv"){ 
	die "no file found";
}

my $text=`cat /opt/sybase/bcp_data/ups_shipment_load.csv`;
my $record="";
my $tracking="";
my @results=();
my @line=();

@results = split(/\n/,$text);

#print $#results;
#exit;

for (my $i=1; $i <= $#results; $i++){
	@line = split(/,/,$results[$i]);
	$tracking = shift(@line);
	if ($tracking){
		$record = $results[$i];
		if ($i != $#results){
			$record .= ",";
		}
	}
	chomp($record);
	print "$record";
	$record = '';
}
