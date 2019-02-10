select * into #tttl_se_upd from tttl_se_search where 1=2;

LOAD into table #tttl_se_upd
(   reference_num      '|:|',
    service_type       '|:|',
    shipper_num        '|:|',
    trace_num          '|:|',
    trace_agent        '|:|',
    con_trace_agent    '|:|',
    postal_code        '|:|',
    start_search_date  '|:|',
    end_search_date    '|:|',
    found_date         '|:|',
    found_flag         '|:|',
    print_location     '|:|',
    con_print_location '|:|',
    inserted_on_cons   '|:|',
    updated_on_cons    '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_se_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_se_search
set                    
    t.trace_agent        = upd.trace_agent,
    t.con_trace_agent    = upd.con_trace_agent,
    t.postal_code        = upd.postal_code,
    t.start_search_date  = upd.start_search_date,
    t.end_search_date    = upd.end_search_date,
    t.found_date         = upd.found_date,
    t.found_flag         = upd.found_flag,
    t.print_location     = upd.print_location,
    t.con_print_location = upd.con_print_location,
    t.updated_on_cons    = upd.updated_on_cons
    
from tttl_se_search t, #tttl_se_upd upd
where   t.reference_num      = upd.reference_num and
    	t.service_type       = upd.service_type and
    	t.shipper_num        = upd.shipper_num and
    	t.trace_num          = upd.trace_num;
