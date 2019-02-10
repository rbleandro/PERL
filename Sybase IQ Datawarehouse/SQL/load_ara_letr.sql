truncate table ara_letr;
LOAD into table ara_letr
(
description '|:|',
language    '|:|',
letter_file '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_letr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

