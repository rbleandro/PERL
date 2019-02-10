LOAD into table tot_sp
(   province          '|:|',
    short_description '|:|',
    long_description  '|:|',
    country           '|:|',
    postal_from       '|:|',
    postal_to         '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_sp.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
