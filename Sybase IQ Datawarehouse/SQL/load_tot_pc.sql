LOAD into table tot_pc
(   postal_code '|:|',
    territory   '|:|',
    terminal    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_pc.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
