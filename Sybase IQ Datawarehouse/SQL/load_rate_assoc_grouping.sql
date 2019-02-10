truncate table rate_assoc_grouping;
LOAD into table rate_assoc_grouping
(
    rate_code   '|:|',
    assoc_code  '|:|',
    description '\n'   
)

from '/opt/sybase/bcp_data/cmf_data/rate_assoc_grouping.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 10000
IGNORE CONSTRAINT UNIQUE 0;
