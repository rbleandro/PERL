LOAD into table tot_ba
(   billing_audit    '|:|',
    description      '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ba.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
