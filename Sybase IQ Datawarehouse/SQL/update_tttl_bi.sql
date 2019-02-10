select * into #tttl_bi_upd from tttl_bi_bulk_inbound where 1=2;

LOAD into table #tttl_bi_upd
(   conv_time_date       '|:|',
    employee_num         '|:|',
    trailer_num          '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    terminal_num         '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_bi_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_bi_bulk_inbound
set 
    	t.conv_time_date       = upd.conv_time_date,
        t.employee_num         = upd.employee_num,
        t.trailer_num          = upd.trailer_num,
        t.num_packages_scanned = upd.num_packages_scanned,
        t.num_cod_scanned      = upd.num_cod_scanned,
        t.num_select_scanned   = upd.num_select_scanned,
        t.terminal_num         = upd.terminal_num,
    	t.updated_on_cons      = upd.updated_on_cons

from tttl_bi_bulk_inbound t, #tttl_bi_upd upd
where t.conv_time_date      = upd.conv_time_date and
      t.employee_num       = upd.employee_num;
