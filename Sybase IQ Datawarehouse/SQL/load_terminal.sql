truncate table terminal;
LOAD into table terminal
(
terminal_num         '|:|',
terminal_name        '|:|',
sales_region         '|:|',
operating_region     '|:|',
inserted_on_cons     '|:|',
updated_on_cons      '|:|',
time_zone_adjustment '\n'
)
from '/opt/sybase/bcp_data/cpscan/terminal_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
