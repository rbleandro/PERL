truncate table ara_departments;
LOAD into table ara_departments
(
dept_id          '|:|',
dept_description '|:|',
active		 '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_departments_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

