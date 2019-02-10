truncate table StatisticCD_mtl;
LOAD into table StatisticCD_mtl
(
	StatisticID '|:|',
	StatClassID '|:|',
	Description '\n'
)

from '/opt/sybase/bcp_data/mtldb/StatisticsCD.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

