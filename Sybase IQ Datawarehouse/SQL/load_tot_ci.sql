LOAD into table tot_ci
(   collector_id     '|:|',
    collector_name   '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ci.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
