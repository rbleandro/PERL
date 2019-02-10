LOAD into table tot_ch
(   charge_code     '|:|',
    description     '|:|',
    amount          '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ch.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
