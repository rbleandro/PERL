select * into #tttl_pt_upd from tttl_pt_pickup_totals where 1=2;

LOAD into table #tttl_pt_upd
(   conv_time_date       '|:|',
    employee_num         '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    num_hvr_scanned      '|:|',
    totals_no_match_flag '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pt_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_pt_pickup_totals
set                
    t.num_packages_scanned = upd.num_packages_scanned,
    t.num_cod_scanned      = upd.num_cod_scanned,
    t.num_select_scanned   = upd.num_select_scanned,
    t.num_hvr_scanned      = upd.num_hvr_scanned,
    t.totals_no_match_flag = upd.totals_no_match_flag,
    t.updated_on_cons      = upd.updated_on_cons
    
from tttl_pt_pickup_totals t, #tttl_pt_upd upd
where   t.conv_time_date       = upd.conv_time_date and
    	t.employee_num         = upd.employee_num;
