LOAD into table tot
(   tot_id      '|:|',
    description '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
