LOAD into table tot_rg
(   region         '|:|',
    description    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_rg.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
