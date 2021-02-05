#!/bin/bash

file="/opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx"

if [ -f "$file" ]; then
	perl /opt/sap/cron_scripts/convert_to_csv.pl > /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv
	perl -pe 's#(\d{2})/(\d{2})/(\d{4})#$2/$1/$3#g' /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv > /opt/sap/bcp_data/MPR_Export_Hourly_Payroll_regex.csv
	perl /opt/sap/cron_scripts/mpr_payroll_hourly.pl
	sudo rm /opt/sap/bcp_data/MPR_Export_Hourly_Payroll.csv
else
	echo "mpr_payroll_hourly.sh message: file MPR_Export_Hourly_Payroll.xlsx not available." | sendmail -v CANPARDatabaseAdministratorsStaffList\@canpar.com
fi

