LOAD into table tot_ad
(   association_code '|:|',
    effective_date   '|:|',
    description      '|:|',
    discount_pc      '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ad.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
