truncate table StatisticClass_mtl;
LOAD into table StatisticClass_mtl
(
	StatClassID '|:|',
	Description '|:|',
	UpdateRate '|:|',
	TimeStaticFlag '|:|',
	Width '\n'
)

from '/opt/sybase/bcp_data/mtldb/StatisticClass.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

