truncate table STATS_RATE;
LOAD into table STATS_RATE
(
	Rate_Time '|:|',
	Bags_Scanned '|:|',
	No_Reads '|:|',
	Sorts '|:|',
	Failed_Diverts '|:|',
	System_ID '|:|',
	GUID '\n'
)

from '/opt/sybase/bcp_data/ssdb/STATS_RATE.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

