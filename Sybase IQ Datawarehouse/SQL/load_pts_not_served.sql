LOAD into TABLE pts_not_served 
(
    city '|:|',
    fsa  '\n'
)

from '/opt/sybase/bcp_data/cmf_data/pts_not_served_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
