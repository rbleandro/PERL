truncate table disp_regn;
LOAD into table disp_regn
(
    region   	'|:|',
    reg_desc	'\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_regn_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

