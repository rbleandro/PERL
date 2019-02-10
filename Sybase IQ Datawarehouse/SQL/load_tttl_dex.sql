truncate table tttl_dex_dlry_cross_ref;
LOAD into table tttl_dex_dlry_cross_ref 
(
    reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    conv_time_date   '|:|',
    employee_num     '|:|',
    status           '|:|',
    scan_time_date   '|:|',
    terminal_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_dex_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
