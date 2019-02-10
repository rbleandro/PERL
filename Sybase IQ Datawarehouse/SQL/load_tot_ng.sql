LOAD into table tot_ng
(   cmf_code    '|:|',
    description '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ng.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
