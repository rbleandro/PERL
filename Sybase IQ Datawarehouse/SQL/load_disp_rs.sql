truncate table disp_rs;
LOAD into table disp_rs
(
    in_use      '|:|',
    eng_message '|:|',
    fre_message '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_rs_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

