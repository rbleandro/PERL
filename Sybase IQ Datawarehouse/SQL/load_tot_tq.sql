LOAD into table tot_tq
(   trace_status '|:|',
    description  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_tq.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
