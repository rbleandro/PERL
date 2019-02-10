select * into #tttl_ev_upd from tttl_ev_event where 1=2;

LOAD into table #tttl_ev_upd
(   reference_num         '|:|',
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
    updated_on_cons       '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ev_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ev_event
set     	           
        t.status                = upd.status,
        t.scan_time_date        = upd.scan_time_date,
        t.terminal_num          = upd.terminal_num,
        t.pickup_shipper_num    = upd.pickup_shipper_num,
        t.postal_code           = upd.postal_code,
        t.additional_serv_flag  = upd.additional_serv_flag,
        t.mod10b_fail_flag      = upd.mod10b_fail_flag,
        t.multiple_barcode_flag = upd.multiple_barcode_flag,
        t.multiple_shipper_flag = upd.multiple_shipper_flag,
        t.comments_flag         = upd.comments_flag,
    	t.updated_on_cons       = upd.updated_on_cons

from tttl_ev_event t, #tttl_ev_upd upd
where   t.reference_num         = upd.reference_num and
        t.service_type          = upd.service_type and
        t.shipper_num           = upd.shipper_num and
        t.conv_time_date        = upd.conv_time_date and
        t.employee_num          = upd.employee_num;
