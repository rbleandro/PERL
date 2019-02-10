select * into #tttl_hc_upd from tttl_hc_hub_cod where 1=2;

LOAD into table #tttl_hc_upd
(   reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    scan_time_date   '|:|',
    employee_num     '|:|',
    interline_id     '|:|',
    status           '|:|',
    city             '|:|',
    postal_code      '|:|',
    cod_label_amount '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_hc_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_hc_hub_cod
set     	   
    t.scan_time_date   = upd.scan_time_date,
    t.employee_num     = upd.employee_num,
    t.interline_id     = upd.interline_id,
    t.status           = upd.status,
    t.city             = upd.city,
    t.postal_code      = upd.postal_code,
    t.cod_label_amount = upd.cod_label_amount,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_hc_hub_cod t, #tttl_hc_upd upd
where   t.reference_num    = upd.reference_num and
    	t.service_type     = upd.service_type and
    	t.shipper_num      = upd.shipper_num;
