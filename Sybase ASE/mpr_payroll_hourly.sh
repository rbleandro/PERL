#!/bin/bash
A="2019-04-08"
B=$(date +'%Y-%m-%d')
C=$(( ($(date -d $B +%s) - $(date -d $A +%s)) / 86400 ))
D=$(($C % 14))

ignoreDate='0'

while getopts 'd' option; do
	case "${option}" in
	d) ignoreDate='1' ;;
	esac
done
shift $(( OPTIND - 1 ))

file="/opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx"

if [ $D == 0 ] || [ "$ignoreDate" == "1" ]; then
	if [ -f "$file" ]; then
		perl /opt/sap/cron_scripts/convert_to_csv.pl > /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv
		perl -pe 's#(\d{2})/(\d{2})/(\d{4})#$2/$1/$3#g' /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv > /opt/sap/bcp_data/MPR_Export_Hourly_Payroll_regex.csv
		perl /opt/sap/cron_scripts/mpr_payroll_hourly.pl
		sudo rm /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv
	else
		echo "mpr_payroll_hourly.sh message: file MPR_Export_Hourly_Payroll.xlsx not available." | sendmail -v CANPARDatabaseAdministratorsStaffList\@canpar.com
	fi
else
	echo "mpr_payroll_hourly.sh message: Not the right day! Run \"mpr_payroll_hourly.sh -d\" to ignore the date validation." #| sendmail -v rleandro\@canpar.com
fi
