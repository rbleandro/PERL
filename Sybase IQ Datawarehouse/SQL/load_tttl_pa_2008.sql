truncate table tttl_pa_2008;
LOAD into table tttl_pa_2008
(   reference_num          '|:|',
    service_type           '|:|',
    shipper_num            '|:|',
    pickup_conv_time_date  '|:|',
    pickup_employee_num    '|:|',
    last_conv_time_date    '|:|',
    last_employee_num      '|:|',
    last_scanned_time_date '|:|',
    last_status            '|:|',
    last_terminal_num      '|:|',
    postal_code            '|:|',
    mod10b_fail_flag       '|:|',
    multiple_barcode_flag  '|:|',
    multiple_shipper_flag  '|:|',
    comments_flag          '|:|',
    additional_serv_flag   '|:|',
    pickup_shipper_num     '|:|',
    inserted_on_cons       '|:|',
    updated_on_cons        '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pa_live_2008_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
