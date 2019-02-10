LOAD into table tot_at
(   account_type     '|:|',
    description      '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_at.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
