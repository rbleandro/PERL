LOAD into table tot_pe
(   year       '|:|',
    period     '|:|',
    start_date '|:|',
    end_date   '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_pe.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
