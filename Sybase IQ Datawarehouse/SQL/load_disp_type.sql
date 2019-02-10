truncate table disp_type;
LOAD into table disp_type
(
    code      '|:|',
    type      '|:|',
    type_desc '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_type_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

