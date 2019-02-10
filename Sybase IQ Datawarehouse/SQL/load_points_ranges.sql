truncate table points_ranges;
LOAD into table points_ranges 
(

postal_code_from '|:|',
postal_code_to   '|:|',
Terminal         '|:|',
Interline        '|:|',
City             '|:|',
Delay            '|:|',
Service          '|:|',
Week1            '|:|',
Week2            '|:|',
Additional_Days  '|:|',
Sort_Terminal    '|:|',
Point_Served     '|:|',
province_code    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/points_ranges_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

