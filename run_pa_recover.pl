#!/usr/bin/perl -w

##############################################################################
#Script:   #
#                                                                            #
#Note:     This script create view pa_view from  tttl_pa_parcel  table       #
#          where last_conv_time_date between 2 spcefied dates                #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2004/12/06                     Originally created                           #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

#print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute liberty_update

$start_date="  2:59:59:999PM";
$min = 1;
$i = 0;
while ($min != 0 && $start_date =~ /^.+2/){
undef @sql_arr;
$end_date=substr($start_date,0,16);

if ($start_date =~ /^.+2\:(..)\:(..)\:(...)/){ #####Change here
#   print "Minute: $1\nSecond: $2\nMsec: $3\n";
   if ($3 != 0){
	$msec = $3 - 50;
	if($msec < 0){ $msec = 0;}
   }else{$msec = $3;}
   $msec=sprintf('%03d',$msec);
   if($3 == 0 && $2 != 0){
	$msec=999;
	$sec = $2 - 1;
	if($sec < 0){ $sec = 0;}
   }else{ $sec = $2;}
   if($3 == 0 && $2 == 0 && $1 != 0){
	$sec=59;
	$msec=999;
	$min=$1 - 1;
	if($min < 0){ $min = 0;}
   }else{ $min = $1;}

   $msec=sprintf('%03d',$msec);
   $sec=sprintf('%02d',$sec);
   $min=sprintf('%02d',$min);

#   print "New: $min:$sec:$msec\n";
   $msec=$msec."PM";
   
}
if ($min == 0) {die "End of the hour";}


$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPDB1 -b -n -Dcpscan<<EOF 2>&1
select *,convert(varchar,last_conv_time_date,109) from tttl_pa_parcel
where last_conv_time_date between 'Jun  8 2005' and 'Jun  8 2005  2:$min:$sec:$msec'
order by last_conv_time_date desc
go
exit
EOF
`;
#print $sqlError."\n";

@sql_arr=split(/Jun\s\s8\s2005/,$sqlError);

if ($sql_arr[$#sql_arr] !~ /2:/){  #####Change here
$start_date = "  2:$min:$sec:$msec";  ###Change here
$data_found = 0;
$vw_start_date=substr($start_date,0,16);
}
else{
$data_found = 1;
$start_date=$sql_arr[$#sql_arr];
$vw_start_date=substr($start_date,0,16);
}

print "New start date...$vw_start_date\n";

$i++;

if ($i == 50000){die;}

if ($data_found == 1){
$vw_start_date =~ s/^\s//g;
$end_date =~ s/^\s//g;

print "View start:$vw_start_date...end date:$end_date\n";

$cr_vw=`isql -Usa -Psybase -SCPDB1 -b -n -e<<EOF 2>&1
use cpscan
go  
IF OBJECT_ID('dbo.pa_view') IS NOT NULL
BEGIN    
    DROP VIEW dbo.pa_view     
END     
go   
create view pa_view as select * from tttl_pa_parcel where last_conv_time_date between 'Jun  8 2005 $vw_start_date'
and 'Jun  8 2005 $end_date'
go
exit
EOF
`;

if ($cr_vw =~ /Incorrect/){die "view error\n";}

print "***************Create view error...$cr_vw\n";
;
$bcp_err=`bcp cpscan..pa_view out pa_test.dat -Usa -Psybase -SCPDB1 -c -t"|:|" -r"\n"`;

print "Bcp out errors...$bcp_err\n";

$bcp_in_err=`bcp tempdb..tttl_pa_parcel in pa_test.dat -Usa -Psybase -SCPDATA2 -c -t"|:|" -r"\n" -b1`;

print "BCP In error...$bcp_in_err\n";

$data_found = 0;
}

} #eof while


die;
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: It was done at $finTime 

$sqlError
EOF
`;

