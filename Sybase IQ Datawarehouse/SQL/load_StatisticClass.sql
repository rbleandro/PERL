truncate table StatisticClass;
LOAD into table StatisticClass
(
	StatClassID '|:|',
	Description '|:|',
	UpdateRate '|:|',
	TimeStaticFlag '|:|',
	Width '\n'
)

from '/opt/sybase/bcp_data/ssdb/StatisticClass.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

