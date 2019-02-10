LOAD into table tot_ct
(   claim_term   '|:|',
    description  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ct.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
