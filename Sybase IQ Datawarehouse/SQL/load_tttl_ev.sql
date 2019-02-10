LOAD into table tttl_ev_event_2008 
(
    reference_num         '|:|',
    service_type          '|:|',
    shipper_num           '|:|',
    conv_time_date        '|:|',
    employee_num          '|:|',
    status                '|:|',
    scan_time_date        '|:|',
    terminal_num          '|:|',
    pickup_shipper_num    '|:|',
    postal_code           '|:|',
    additional_serv_flag  '|:|',
    mod10b_fail_flag      '|:|',
    multiple_barcode_flag '|:|',
    multiple_shipper_flag '|:|',
    comments_flag         '|:|',
    inserted_on_cons      '|:|',
    updated_on_cons       '||\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ev_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;
