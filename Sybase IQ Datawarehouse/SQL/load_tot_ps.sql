LOAD into table tot_ps
(   pickup_status '|:|',
    description   '|:|',
    charges       '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ps.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
