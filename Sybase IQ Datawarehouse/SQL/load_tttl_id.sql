truncate table tttl_id_driver_route_id;
LOAD into table tttl_id_driver_route_id 
(
    conv_date        '|:|',
    employee_num     '|:|',
    route_num        '|:|',
    terminal_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_id_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
