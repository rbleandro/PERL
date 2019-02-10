truncate table tttl_ps_pickup_shipper;
LOAD into table tttl_ps_pickup_shipper 
(
    shipper_num           '|:|',
    conv_time_date        '|:|',
    employee_num          '|:|',
    multiple_shipper_flag '|:|',
    no_package_flag       '|:|',
    missed_pickup_flag    '|:|',
    manual_entry_flag     '|:|',
    terminal_num          '|:|',
    inserted_on_cons      '|:|',
    updated_on_cons       '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ps_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
