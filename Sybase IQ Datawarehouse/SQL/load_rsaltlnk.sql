LOAD into table rsaltlnk 
(
    ground_rate_code   '|:|',
    ground_rate_suffix '|:|',
    alt_rate_code      '|:|',
    alt_rate_suffix    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rsaltlnk_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
