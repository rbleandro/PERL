LOAD into table tot_ar
(   adjust_code       '|:|',
    short_description '|:|',
    long_description  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_ar.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
