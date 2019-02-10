LOAD into table rc_zwdisc 
(
    rate_name '|:|',
    version   '|:|',
    weight    '|:|',
    sm_flag   '|:|',
    zone      '|:|',
    rate      '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rc_zwdisc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
