LOAD into table tot_bc
(   bill_to_code '|:|',
    description  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_bc.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
