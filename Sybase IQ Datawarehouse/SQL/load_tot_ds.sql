LOAD into table tot_ds
(   delivery_status   '|:|',
    description       '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ds.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
