select * into #tttl_dc_upd from tttl_dc_delivery_comment where 1=2;

LOAD into table #tttl_dc_upd
(   scan_time_date   '|:|',
    employee_num     '|:|',
    status           '|:|',
    comments         '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_dc_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_dc_delivery_comment
set     	
    t.status           = upd.status,
    t.comments         = upd.comments,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_dc_delivery_comment t, #tttl_dc_upd upd
where   t.scan_time_date            = upd.scan_time_date and
    	t.employee_num              = upd.employee_num;
