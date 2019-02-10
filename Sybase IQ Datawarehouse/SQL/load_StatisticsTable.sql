truncate table StatisticsTable;
LOAD into table StatisticsTable
(
TimeFragmentID    '|:|',
StaticFragmentID    '|:|',
StatisticID    '|:|',
AttributeID    '|:|',
AttributeValue   '\n'
)

from '/opt/sybase/bcp_data/ssdb/StatisticsTable.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

