select * into #tttl_ex_upd from tttl_ex_exception_comment where 1=2;

LOAD into table #tttl_ex_upd
(   reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    scan_time_date   '|:|',
    employee_num     '|:|',
    status           '|:|',
    exception_data   '|:|',
    comments         '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ex_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ex_exception_comment
set     	   
    t.status           = upd.status,
    t.exception_data   = upd.exception_data,
    t.comments         = upd.comments,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_ex_exception_comment t, #tttl_ex_upd upd
where   t.reference_num    = upd.reference_num and
    	t.service_type     = upd.service_type and
    	t.shipper_num      = upd.shipper_num and
    	t.scan_time_date   = upd.scan_time_date and
    	t.employee_num     = upd.employee_num;
