truncate table rc_extarea;
LOAD into table rc_extarea 
(
    to_fsa          '|:|',
    zone	    '\n'
)
from '/opt/sybase/bcp_data/cmf_data/rc_extarea_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
