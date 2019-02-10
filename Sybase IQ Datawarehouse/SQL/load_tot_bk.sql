LOAD into table tot_bk
(   bank_number     '|:|',
    bank_name      '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_bk.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
