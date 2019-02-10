select * into #tttl_id_upd from tttl_id_driver_route_id where 1=2;

LOAD into table #tttl_id_upd
(   conv_date        '|:|',
    employee_num     '|:|',
    route_num        '|:|',
    terminal_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_id_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_id_driver_route_id
set     	    
    
    t.route_num        = upd.route_num,
    t.terminal_num     = upd.terminal_num,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_id_driver_route_id t, #tttl_id_upd upd
where   t.conv_date        = upd.conv_date and
    	t.employee_num     = upd.employee_num;
