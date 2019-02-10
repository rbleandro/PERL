truncate table tppack;
LOAD into table tppack 
(
    tpnumb    '|:|',
    tpshipper '|:|',
    tppknumb  '|:|',
    tpline    '|:|',
    tpspkgid  '|:|',
    tpsertyp  '|:|',
    tprefnum  '|:|',
    tpwght    '|:|',
    tpwghtid  '|:|',
    tpcomod   '|:|',
    tpcodesc  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tppack_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
