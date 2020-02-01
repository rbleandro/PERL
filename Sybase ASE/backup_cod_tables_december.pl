#!/usr/bin/perl -w

#Usage Restrictions
use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
my @prodline="";

my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $finTime = localtime();
my $skipcheckprod=0;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
    'to|r=s' => \$mail
) or die "Usage: $0 --skipcheckprod|s 0 --to|r rleandro\n";

if ($skipcheckprod == 0){
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
}

my $prodserver = hostname();
if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}


#Set starting variables
my $currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));

my $my_pid = getppid();
my $isProcessRunning =`ps -ef|grep sybase|grep backup_cod_tables_december.pl|grep -v grep|grep -v $my_pid|grep -v "vim backup_cod_tables_december.pl"|grep -v "less backup_cod_tables_december.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

my $sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use cmf_data
go
exec cmf_data..backup_cod_tables '20191224', ''
go
exit
EOF
`;

print "Any message from the proc execution...\n $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/ || $sqlError =~ /error/i){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To:$mail\@canpar.com
Subject: Error: backup_cod_tables_december at $finTime

$sqlError

EOF
`;
}

