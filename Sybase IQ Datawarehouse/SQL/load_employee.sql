truncate table employee;
LOAD into table employee 
(
    employee_num           '|:|',
    password               '|:|',
    security_level         '|:|',
    employee_name          '|:|',
    current_terminal_num   '|:|',
    current_route_num      '|:|',
    inserted_on_cons       '|:|',
    updated_on_cons        '\n'
)
from '/opt/sybase/bcp_data/cpscan/employee_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
