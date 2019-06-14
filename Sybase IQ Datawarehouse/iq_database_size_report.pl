#!/usr/bin/perl -w

# The procedure below must be installed on the IQ database for this script to work

#create procedure dbo.myspace()
#begin
#  declare mt unsigned bigint;
#  declare mu unsigned bigint;
#  declare tt unsigned bigint;
#  declare tu unsigned bigint;
#  call sp_iqspaceused(mt,mu,tt,tu);
#  select cast(mt/1024 as unsigned bigint) as mainMB,
#         cast(mu/1024 as unsigned bigint) as mainusedMB,
#        mu*100/mt as mainPerCent,
#        cast(tt/1024 as unsigned bigint) as tempMB,
#         cast(tu/1024 as unsigned bigint) as tempusedMB,
#        tu*100/tt as tempPerCent;
#end
#go

$dbsqlOut=`. /opt/sybase/IQ-16_0/IQ-16_0.sh
dbisql -c "uid=DBA;pwd=\`/opt/sybase/cron_scripts/getpass.pl DBA\`" -host localhost -port 2638 -nogui -onerror exit '
set option isql_print_result_set=ALL
go
set option isql_show_multiple_result_sets=On
go
execute myspace' > /opt/sybase/cron_scripts/iqdbsize.txt`;

if ($dbsqlOut =~ /Error/ || $dbsqlOut =~ /error/){
      print "Messages From iq_database_size_report.pl...\n";
      print "$dbsqlOut\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR: IQ iq_database_size_report.pl - call procedure stage...ABORTED!!

$dbsqlOut
EOF
`;
die "\n\n*** IQ iq_database_size_report.pl...Aborting Now!!***\n\n";
}

$catout=`cat /opt/sybase/cron_scripts/iqdbsize.txt | egrep -v '\\-\\-\\-' | egrep -v 'main|temp|rows\\)|econds' | awk '{ print \$3 " " \$6 } ' | sort -n`;
$catout =~ s/\s\s//g;
@dbLine=split(/\s/,$catout);
$mainSpace = sprintf("%.2f", $dbLine[0]);
$tempSpace = sprintf("%.2f", $dbLine[1]);

if ($mainSpace > 75){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Warning. IQ database crossed the space threshold for the main database!!

Main database space is $mainSpace% full. Check the file /opt/sybase/cron_scripts/table_size_list.txt to see the table sizes. To refresh the information or to generate the file, in case it is not there, run the script /opt/sybase/cron_scripts/iq_table_size_list.pl.
EOF
`;
}

if ($tempSpace > 85){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Warning. IQ database crossed the space threshold for the temp database!!

Main database space is $tempSpace% full.
EOF
`;
}

#printf $catout;

`rm /opt/sybase/cron_scripts/iqdbsize.txt`;
