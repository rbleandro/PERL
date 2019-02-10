LOAD into table tot_oc
(   carrier_code '|:|',
    carrier_name '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_oc.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
