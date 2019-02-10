LOAD into table tot_co
(   range_from   '|:|',
    range_to     '|:|',
    collector_id '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_co.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
