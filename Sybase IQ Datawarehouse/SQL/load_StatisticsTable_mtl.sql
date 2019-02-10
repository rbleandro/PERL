truncate table StatisticsTable_mtl;
LOAD into table StatisticsTable_mtl
(
TimeFragmentID    '|:|',
StaticFragmentID    '|:|',
StatisticID    '|:|',
AttributeID    '|:|',
AttributeValue   '\n'
)

from '/opt/sybase/bcp_data/mtldb/StatisticsTable_MTL.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

