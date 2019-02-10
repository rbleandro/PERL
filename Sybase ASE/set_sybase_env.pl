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

$ENV{"SYBASE_ASE"}="ASE-15_0";
$PATH .=":/opt/sybase/ASE-15_0/bin:/opt/sybase/ASE-15_0/install";
$LD_LIBRARY_PATH .=":/opt/sybase/ASE-15_0/lib";
$ENV{"SYBASE_JRE"}="/opt/sybase/shared-1_0/JRE-1_3";
$PATH .=":/opt/sybase/JS-15_0/bin";
$PATH .=":/opt/sybase/RPL-15_0/bin";
$LD_LIBRARY_PATH .=":/opt/sybase/SQLRemote/lib";
$ENV{"SYBASE"}="/opt/sybase";
$ENV{"SYBASE_OCS"}="OCS-15_0";
$PATH .=":/opt/sybase/OCS-15_0/bin";
$LD_LIBRARY_PATH .=":/opt/sybase/OCS-15_0/lib:/opt/sybase/OCS-15_0/lib3p";
$ENV{"SYBASE_SYSAM"}="SYSAM-1_0";
$ENV{"LM_LICENSE_FILE"}="/opt/sybase/SYSAM-1_0/licenses/license.dat";
$LANG="en_US";

