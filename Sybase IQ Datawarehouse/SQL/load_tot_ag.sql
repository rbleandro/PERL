LOAD into table tot_ag
(   account_group '|:|',
    description   '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ag.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
