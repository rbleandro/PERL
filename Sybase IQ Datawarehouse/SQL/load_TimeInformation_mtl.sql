truncate table TimeInformation_mtl;
LOAD into table TimeInformation_mtl
(
	TimeID '|:|',
	TimeCategoryID '|:|',
	StartTime '|:|',
	EndTime '|:|',
	Pending '\n'
)

from '/opt/sybase/bcp_data/mtldb/TimeInformation.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

