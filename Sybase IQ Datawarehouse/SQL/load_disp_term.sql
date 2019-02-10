truncate table disp_term;
LOAD into table disp_term
(
    terminal      '|:|',
    fax_ld        '|:|',
    fax_acode     '|:|',
    fax_num       '|:|',
    fax_ext       '|:|',
    notify_by     '|:|',
    region        '|:|',
    email         '|:|',
    route_default '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_term_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

