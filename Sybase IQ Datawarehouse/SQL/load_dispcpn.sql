truncate table dispcpn;
LOAD into table dispcpn
(
    cust   '|:|',
    rteno  '|:|',
    putime '|:|',
    cltime '|:|',
    puloc  '|:|',
    pupkg  '\n'
)

from '/opt/sybase/bcp_data/cmf_data/dispcpn_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

