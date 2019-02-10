LOAD into table tot_ac
(   area_code      '|:|',
    province_state '|:|',
    description    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ac.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
