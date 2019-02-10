select * into #tttl_fl_upd from tttl_fl_fuel where 1=2;

LOAD into table #tttl_fl_upd
(   conv_time_date   '|:|',
    employee_num     '|:|',
    truck_id         '|:|',
    litres           '|:|',
    odometer         '|:|',
    cost_per_litre   '|:|',
    fuel_type        '|:|',
    terminal_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_fl_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_fl_fuel
set     	   
    
    t.litres           = upd.litres,
    t.odometer         = upd.odometer,
    t.cost_per_litre   = upd.cost_per_litre,
    t.fuel_type        = upd.fuel_type,
    t.terminal_num     = upd.terminal_num,
    t.updated_on_cons  = upd.updated_on_cons

from tttl_fl_fuel t, #tttl_fl_upd upd
where   t.conv_time_date   = upd.conv_time_date and
    	t.employee_num     = upd.employee_num and
    	t.truck_id         = upd.truck_id;
