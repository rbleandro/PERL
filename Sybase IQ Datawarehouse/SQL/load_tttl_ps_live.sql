--truncate table tttl_ps_live;
LOAD into table tttl_ps_live 
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
from '/opt/sybase/bcp_data/cpscan/tttl_ps_live_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;
