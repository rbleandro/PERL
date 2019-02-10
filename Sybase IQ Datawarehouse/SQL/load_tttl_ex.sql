truncate table tttl_ex_exception_comment;
LOAD into table tttl_ex_exception_comment 
(
    reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    scan_time_date   '|:|',
    employee_num     '|:|',
    status           '|:|',
    exception_data   '|:|',
    comments         '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ex_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
