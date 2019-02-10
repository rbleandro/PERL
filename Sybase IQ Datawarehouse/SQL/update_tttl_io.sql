select * into #tttl_io_upd from tttl_io_interline_outbound where 1=2;

LOAD into table #tttl_io_upd
(   conv_time_date       '|:|',
    employee_num         '|:|',
    interline_num        '|:|',
    unit_num             '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    terminal_num         '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_io_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_io_interline_outbound
set     	        
    t.interline_num        = upd.interline_num,
    t.unit_num             = upd.unit_num,
    t.num_packages_scanned = upd.num_packages_scanned,
    t.num_cod_scanned      = upd.num_cod_scanned,
    t.num_select_scanned   = upd.num_select_scanned,
    t.terminal_num         = upd.terminal_num,
    t.updated_on_cons      = upd.updated_on_cons
    
from tttl_io_interline_outbound t, #tttl_io_upd upd
where   t.conv_time_date   = upd.conv_time_date and
    	t.employee_num     = upd.employee_num;
