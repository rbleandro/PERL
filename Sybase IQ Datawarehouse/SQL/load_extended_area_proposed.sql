truncate table extended_area_proposed;
LOAD into table extended_area_proposed 
(
    postal_code		   '|:|',
    city                   '|:|',
    province               '\n'
)
from '/opt/sybase/bcp_data/cpscan/extended_area_proposed.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
