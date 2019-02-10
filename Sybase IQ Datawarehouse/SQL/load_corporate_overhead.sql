truncate table corporate_overhead;
LOAD into table corporate_overhead
(
    terminal  '|:|',
    corpline  '|:|',
    region    '|:|',
    group_num '|:|',
    amount    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/corporate_overhead_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

