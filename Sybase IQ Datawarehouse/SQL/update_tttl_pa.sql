set option "PUBLIC".Bitmap_Options1 = 1;

select * into #tttl_pa_upd from tttl_pa_parcel where 1=2;

LOAD into table #tttl_pa_upd
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
from '/opt/sybase/bcp_data/cpscan/tttl_pa_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

set option query_temp_space_limit=0;
update tttl_pa_parcel
set t.pickup_conv_time_date  = upd.pickup_conv_time_date,
    t.pickup_employee_num    = upd.pickup_employee_num,
    t.last_conv_time_date    = upd.last_conv_time_date,
    t.last_employee_num      = upd.last_employee_num,
    t.last_scanned_time_date = upd.last_scanned_time_date,
    t.last_status            = upd.last_status,
    t.last_terminal_num      = upd.last_terminal_num,
    t.postal_code            = upd.postal_code,
    t.mod10b_fail_flag       = upd.mod10b_fail_flag,
    t.multiple_barcode_flag  = upd.multiple_barcode_flag,
    t.multiple_shipper_flag  = upd.multiple_shipper_flag,
    t.comments_flag          = upd.comments_flag,
    t.additional_serv_flag   = upd.additional_serv_flag,
    t.pickup_shipper_num     = upd.pickup_shipper_num,
    t.updated_on_cons        = upd.updated_on_cons

from tttl_pa_parcel t, #tttl_pa_upd upd
where 	t.reference_num          = upd.reference_num and
    	t.service_type           = upd.service_type and
    	t.shipper_num            = upd.shipper_num;
