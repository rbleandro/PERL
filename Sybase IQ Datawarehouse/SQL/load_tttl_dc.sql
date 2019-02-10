truncate table tttl_dc_delivery_comment;
LOAD into table tttl_dc_delivery_comment 
(
    scan_time_date   '|:|',
    employee_num     '|:|',
    status           '|:|',
    comments         '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_dc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
