#!/usr/bin/perl -w

###################################################################################
#Script:   This script sets up the sybase environment for sybase user             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#12/30/03       Amer Khan       Originally created                                #
#                                                                                 #
###################################################################################

use Env;

$ENV{"ASDIR"}="/opt/sybase/ASIQ-12_6";
$ENV{"LD_LIBRARY_PATH"}="/opt/sybase/ASE-12_6/lib";
$ENV{"SYBASE_JRE"}="/opt/sybase/shared-1_0/JRE-1_3";
$ENV{"SYBASE"}="/opt/sybase";
$ENV{"SYBASE_OCS"}="OCS-12_5";
$PATH .=":/opt/sybase/OCS-12_5/bin:/opt/sybase/ASIQ-12_6/bin32";
$ENV{"LD_LIBRARY_PATH_64"} .=":/opt/sybase/ASIQ-12_6/lib32:/opt/sybase/ASIQ-12_6/lib:/opt/sybase/OCS-12_5/lib";

