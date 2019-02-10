LOAD into table tot_wt
(   weight_code '|:|',
    description '|:|',
    unit        '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_wt.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
