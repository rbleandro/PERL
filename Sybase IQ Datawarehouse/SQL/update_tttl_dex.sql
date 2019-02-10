select * into #tttl_dex_upd from tttl_dex_dlry_cross_ref where 1=2;

LOAD into table #tttl_dex_upd
(   reference_num    '|:|',
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
from '/opt/sybase/bcp_data/cpscan/tttl_dex_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_dex_dlry_cross_ref
set     	
    
    t.scan_time_date   = upd.scan_time_date,
    t.terminal_num     = upd.terminal_num,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_dex_dlry_cross_ref t, #tttl_dex_upd upd
where   t.reference_num    = upd.reference_num and
    	t.service_type     = upd.service_type and
    	t.shipper_num      = upd.shipper_num and
    	t.conv_time_date   = upd.conv_time_date and
    	t.employee_num     = upd.employee_num and
    	t.status           = upd.status;
