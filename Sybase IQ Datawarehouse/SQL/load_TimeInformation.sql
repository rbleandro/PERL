truncate table TimeInformation;
LOAD into table TimeInformation
(
	TimeID '|:|',
	TimeCategoryID '|:|',
	StartTime '|:|',
	EndTime '|:|',
	Pending '\n'
)

from '/opt/sybase/bcp_data/ssdb/TimeInformation.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

