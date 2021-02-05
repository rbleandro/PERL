#!/usr/bin/perl -w

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

#perl /opt/sybase/cron_scripts/interco_import_from_iq.pl -c L -y 2020 -p 03

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $company="";
my $finTime = localtime();
my $year="";
my $period="";

GetOptions(
    'company|c=s' => \$company,
	'year|y=s' => \$year,
	'period|p=s' => \$period,
	'to|r=s' => \$mail
) or die "Usage: $0 --company|c L --year|y 2020 --period|p 03 --to|r rleandro\n";

if ($company eq "" || $year eq "" || $period eq ""){
	die "Usage: $0 --company|c L|C --year|y 2020 --period|p 03 --to|r rleandro\n";
}

my $dbsqlOut = `. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit "exec extract_interco_data \@company='$company', \@year='$year', \@period='$period'" 2>&1`;

#print "$dbsqlOut\n";

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/ || $dbsqlOut !~ /Execution/){
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR: extract_interco_data...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n***Errors found during execution. Aborting now.***\n\n";
}

#die "test iq proc ok";

my $prod_db = "";

if ($company eq "C"){
	$prod_db="mpr_data";
}elsif ($company eq "L"){
	$prod_db="mpr_data_lm";
}

my $error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -n -b<<EOF 2>&1
set nocount on
set proc_return_status off
go
delete from $prod_db..interco_charge_pieces_iq where fiscal_year="$year" and period_num="$period"
go
exit
EOF
`;
if($error =~ /no|not|Msg/)
{
`/usr/sbin/sendmail -t -i <<EOF
To: $mail\@canpar.com
Subject: ERROR - monitor_uss_connections.pl script.
$error
EOF
`;
die "Email sent";
}

print "Existing data deleted from Production. Now loading data from IQ!!\n";

$dbsqlOut = `. /opt/sybase/SYBASE.sh
/opt/sybase/OCS-16_0/bin/bcp $prod_db..interco_charge_pieces_iq in /opt/sybase/bcp_data/interco_extract.txt -c -t"," -S CPDB1 -U sa -P\`/opt/sybase/cron_scripts/getpass.pl sa\``;

print "Completed Successfully!!\n";

