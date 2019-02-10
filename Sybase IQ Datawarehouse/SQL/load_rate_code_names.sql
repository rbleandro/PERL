LOAD into table rate_code_names 
(
    ratecode     '|:|',
    short_name   '|:|',
    long_name    '|:|',
    service_type '|:|',
    kg_or_lb     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rate_code_names_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
