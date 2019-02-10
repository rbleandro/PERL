truncate table flash_adjustments;
LOAD into table flash_adjustments
(   
artificial_id           '|:|',
employee_num            '|:|',
terminal_num            '|:|',
conv_time_date          '|:|',
supervisor_employee_num '|:|',
table_name              '|:|',
column_name             '|:|',
old_value               '|:|',
new_value               '|:|',
comments                '|:|',
inserted_on_cons        '|:|',
updated_on_cons		'\n'
)
from '/opt/sybase/bcp_data/cpscan/flash_adjustments_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
