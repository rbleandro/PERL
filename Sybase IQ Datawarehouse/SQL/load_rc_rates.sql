LOAD into table rc_rates 
(
    rate_name '|:|',
    KorL      '|:|',
    version   '|:|',
    weight    '|:|',
    sm_flag   '|:|',
    zone      '|:|',
    rate      '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rc_rates_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
