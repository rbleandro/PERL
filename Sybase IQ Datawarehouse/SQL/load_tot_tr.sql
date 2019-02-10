LOAD into table tot_tr
(   trace_reason '|:|',
    description  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_tr.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
