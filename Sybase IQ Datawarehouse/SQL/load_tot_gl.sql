LOAD into table tot_gl
(   expense_code '|:|',
    description  '|:|',
    amount       '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_gl.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
