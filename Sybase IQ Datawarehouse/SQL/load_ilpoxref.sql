truncate table ilpoxref;
LOAD into table ilpoxref        
(
interline        '|:|',
    alpha        '|:|',
    extract_date '|:|',
    employee_num '|:|',
    ilinkage     '|:|',
    rate_version '|:|',
    area_version '|:|',
    ponumber     '\n'  
)
from '/opt/sybase/bcp_data/cmf_data/ilpoxref_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
