LOAD into table tot_cn
(   company_name   '|:|',
    description    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_cn.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
