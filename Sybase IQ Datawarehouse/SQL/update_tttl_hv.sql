select * into #tttl_hv_upd from tttl_hv_high_value where 1=2;

LOAD into table #tttl_hv_upd
(   reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    conv_time_date   '|:|',
    employee_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_hv_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_hv_high_value
set     	    
    t.conv_time_date   = upd.conv_time_date,
    t.employee_num     = upd.employee_num,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_hv_high_value t, #tttl_hv_upd upd
where   t.reference_num    = upd.reference_num and
    	t.service_type     = upd.service_type and
    	t.shipper_num      = upd.shipper_num;
