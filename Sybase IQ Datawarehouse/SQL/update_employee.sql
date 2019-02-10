select * into #employee_upd from employee where 1=2;

LOAD into table #employee_upd
(   employee_num             '|:|',
    password                 '|:|',
    security_level           '|:|',
    employee_name            '|:|',
    current_terminal_num     '|:|',
    current_route_num        '|:|',
    inserted_on_cons         '|:|',
    updated_on_cons          '\n'
)
from '/opt/sybase/bcp_data/cpscan/employee_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update employee
set     	
        t.password 		= upd.password,
        t.security_level 	= upd.security_level,
        t.employee_name 	= upd.employee_name,
        t.current_terminal_num 	= upd.current_terminal_num,
        t.current_route_num 	= upd.current_route_num    ,   
    	t.updated_on_cons       = upd.updated_on_cons

from employee t, #employee_upd upd
where t.employee_num      = upd.employee_num;
