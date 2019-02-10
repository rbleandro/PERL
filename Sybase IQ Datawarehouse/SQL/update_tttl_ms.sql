select * into #tttl_ms_upd from tttl_ms_missorts where 1=2;

LOAD into table #tttl_ms_upd
(   service_type     '|:|',
    reference_num    '|:|',
    shipper_num      '|:|',
    scan_time_date   '|:|',
    employee_num     '|:|',
    city             '|:|',
    FSA              '|:|',
    prov             '|:|',
    origin_trm       '|:|',
    trailer_num      '|:|',
    small_sort       '|:|',
    double_label     '|:|',
    bad_code         '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ms_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ms_missorts
set         
    t.scan_time_date   = upd.scan_time_date,
    t.employee_num     = upd.employee_num,
    t.city             = upd.city,
    t.FSA              = upd.FSA,
    t.prov             = upd.prov,
    t.origin_trm       = upd.origin_trm,
    t.trailer_num      = upd.trailer_num,
    t.small_sort       = upd.small_sort,
    t.double_label     = upd.double_label,
    t.bad_code         = upd.bad_code  ,
    t.updated_on_cons  = upd.updated_on_cons
    
from tttl_ms_missorts t, #tttl_ms_upd upd
where   t.service_type     = upd.service_type and
    	t.reference_num    = upd.reference_num and
    	t.shipper_num      = upd.shipper_num;
