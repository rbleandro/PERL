#!/usr/bin/perl -w

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "lmscan_purge_tttl_batchdown StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
truncate table eng_temp
go
LOAD TABLE eng_temp
( col_text_1)
FROM '/opt/sybase/bcp_data/eng_temp.csv'
DELIMITED BY 0x2c
ROW DELIMITED BY 0x0d0a
ESCAPES OFF 
QUOTES ON
FORMAT ASCII
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - cmf_data_lm_purge_pr_waybills_log

Following status was received during lmscan_purge_tttl_batchdown that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "lmscan_purge_tttl_batchdown FinTime: $currTime\n";

