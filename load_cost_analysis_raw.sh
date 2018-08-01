#!/bin/bash
####################################################################
#Description	This script scans the /tmp folder every second     #
#		for recalc_done. If found it initiates the process #
#		to download data from cost_analysis in CPDB2 and   #
#		upload it to CPIQ                                  #
#                                                                  #
#Dated:		10/05/04                                           #
#Created By:	Amer Khan                                          #
####################################################################

if [ -a /tmp/recalc_done ]
then
rm /tmp/recalc_done
ssh cpiq.canpar.com /opt/sybase/cron_scripts/load_cost_analysis_raw.pl CPDATA2
fi
