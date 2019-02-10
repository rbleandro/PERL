#!/usr/bin/perl -w

###################################################################################
#Script:   This script updates ACprocessing information in liberty_db             #
#                                                                                 #
#Author:   Ahsan Ahmed                                                            #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#24/02/11	Ahsan ahmed	Originally created                                #
#                                                                                 #
#25/02/11      Ahsan Ahmed      Modified
###################################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
use Sys::Hostname;
$prodserver = "hqvsybtest";

#Usage Restrictions

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$database = "cmf_data";

#Execute update now

print "\n###Running update on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating update At:".localtime()."***\n";
$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use $database
go
update cmfshipr set customer_name='A' where customer_num='42065940'
go
update cmfshipr set customer_name='B' where customer_num='42299001'
go
update cmfshipr set customer_name='C' where customer_num='43804400'
go
update cmfshipr set customer_name='D' where customer_num='45306024'
go
update cmfshipr set customer_name='E' where customer_num='46400600'
go
update cmfshipr set customer_name='F' where customer_num='51400145'
go
update cmfshipr set customer_name='G' where customer_num='55600003'
go
update cmfshipr set customer_name='H' where customer_num='55600033'
go
update cmfshipr set customer_name='I' where customer_num='55607720'
go
update cmfshipr set customer_name='J' where customer_num='55611273'
go
update cmfshipr set customer_name='K' where customer_num='55610770'
go
update cmfshipr set customer_name='L' where customer_num='55610775'
go
update cmfshipr set customer_name='M' where customer_num='55610944'
go
insert into rc_zones values ('16912', 'A', 'A0A', 'Z9Z', 'A0A', 'Z9Z', 1, 'K', '0')
go
insert into rc_zones values ('SELPR', 'A', 'A0A', 'Z9Z', 'A0A', 'Z9Z', 1, 'K', '0')
go
insert into rc_zones values ('USZON', 'A', 'A0A', 'Z9Z', 'A0A', 'Z9Z', 1, 'K', '0')
go
update cmfprice set extra_care_active='Y', service_charge_active='Y', pd10am_activated='Y', pdnoon_activated='Y', chainofsig_activated='Y', dangerousgoods_activated='Y', saturdaydel_activated='Y', ruraldel_activated='Y' where customer_num in ('42065940','42299001','43804400','45306024','46400600','51400145','55600003','55600033','55607720','55607720','55610770','55610775','55610944','55611273','43804607','45307077','55630436','55630597','55630598','55630659')
go
update points_no_ranges set service_10am='Y', service_noon='Y', service_saturday='Y' where postal_code in ('A0M1C0','A1B1W3','A1E1B5','A1E4N1','A1N5B8','A1V2H2','A1Y1B3','A2H3C5','A2H6L8','B0E1W0','B0P1N0','B0S1P0','B2N5B6','B2N5N2','B3B1G6','B3K5J7','B3M4C5','B3S1B3','C0A1H0','C1A1H9','C1A7N4','C1A8R8','C1E1E3','C1E1E8','C1E1H6','C1N6M6','E2E2N6','E2J3W9','E2J4K2','E2L3P3','E2L4W3','E2M3X4','E3A5G8','E3B3Z2','E5N1B5','G0A4V0','G1C4N4','G1V4M6','G4R2H7','G5R5M9','H2N1P6','H2T1T3','H4S1C9','H9J3K1','J7V5V5','K0M2K0','L4V1R5','L4X2J6','L5C4R9','M1S5A2','M2J1P6','M3J2L5','M7A1W4','M8Z2X3','M8Z4X3','M8Z4X6','M8Z5T6','N2Z2X6','P1B9E6','P5N2Y3','P7B1A2','R2C0A6','R2L1S4','R2X1G8','R3A1T1','R3B1X8','R3G0H4','R3G1M9','R3M2A6','R3M2T4','S0G3N0','S4A2B4','S4N5H4','S4N6L1','S4P0T2','S4P2S4','S4P3X1','S4R1K1','S4S3R2','S4S3R9','S4S6H8','T0G2A4','T1H2S8','T2A6N8','T2C2B4','T2H0W3','T2H0X4','T2H1K3','T2H2E1','T2H2S3','T2P0L6','T6E5X4','T6P1W2','T8A4G4','V0N1B1','V2Y1M8','V3K6G3','V3N4A3','V5E1G3','V5L3K7','V6J1M8','V6T2G6','V6V1N6','V7R4J1')
go
update points_no_ranges set service_10am='Y', service_noon='Y', service_saturday='Y' where postal_code in (select postal_zip from cmfshipr where customer_num in ('42065940','42299001','43804400','45306024','46400600','51400145','55600003','55600033','55607720','55607720','55610770','55610775','55610944','55611273','43804607','45307077','55630436','55630597','55630598','55630659'))
go
exit
EOF
`;
print "$error\n";
   if ($error =~ /not/){
      print "Messages From cpsybtest...\n";
      print "$error\n";
`/usr/sbin/sendmail -t -i <<EOF
To:  CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Updated cmf_data for Drydn

$error
EOF
`;
   }#end of if messages received

