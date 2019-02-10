truncate table disp_user_regn;
LOAD into table disp_user_regn
(
    userid '|:|',
    region '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_user_regn_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

