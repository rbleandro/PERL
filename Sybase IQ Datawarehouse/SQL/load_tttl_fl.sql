truncate table tttl_fl_fuel;
LOAD into table tttl_fl_fuel 
(
    conv_time_date   '|:|',
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
from '/opt/sybase/bcp_data/cpscan/tttl_fl_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
