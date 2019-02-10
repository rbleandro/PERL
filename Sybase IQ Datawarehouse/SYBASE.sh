#
# Sybase Product Environment variables
#
#
# Replace lib, lib3p, and lib3p64 with devlib, devlib3p, and devlib3p64 when debugging
#
PATH="/opt/sybase/COCKPIT-4/bin":$PATH
export PATH
LD_LIBRARY_PATH="/opt/sybase/DataAccess/ODBC/lib":$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
LD_LIBRARY_PATH="/opt/sybase/DataAccess64/ODBC/lib":$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
SYBASE_SAM_CAPACITY=PARTITION
export SYBASE_SAM_CAPACITY
SYBASE="/opt/sybase"
export SYBASE
SYBASE_OCS="OCS-16_0"
export SYBASE_OCS
INCLUDE="/opt/sybase/OCS-16_0/include":$INCLUDE
export INCLUDE
LIB="/opt/sybase/OCS-16_0/lib":$LIB
export LIB
PATH="/opt/sybase/OCS-16_0/bin":$PATH
export PATH
#
# Replace lib, lib3p, and lib3p64 with devlib, devlib3p, and devlib3p64 when debugging
#
LD_LIBRARY_PATH="/lib64/:/opt/sybase/OCS-16_0/lib:/opt/sybase/OCS-16_0/lib3p64:/opt/sybase/OCS-16_0/lib3p":$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
SAP_JRE7_32="/opt/sybase/shared/SAPJRE-7_1_015_32BIT"
export SAP_JRE7_32
SAP_JRE7="/opt/sybase/shared/SAPJRE-7_1_015_64BIT"
export SAP_JRE7
SAP_JRE7_64="/opt/sybase/shared/SAPJRE-7_1_015_64BIT"
export SAP_JRE7_64
SAP_JRE8_32="/opt/sybase/shared/SAPJRE-8_1_008_32BIT"
export SAP_JRE8_32
SAP_JRE8="/opt/sybase/shared/SAPJRE-8_1_008_64BIT"
export SAP_JRE8
SAP_JRE8_64="/opt/sybase/shared/SAPJRE-8_1_008_64BIT"
export SAP_JRE8_64
COCKPIT_JAVA_HOME="/opt/sybase/shared/SAPJRE-8_1_008_64BIT"
export COCKPIT_JAVA_HOME
