LOAD into table cmffield 
(
    file_id      '|:|',
    field_id     '|:|',
    description  '|:|',
    field_length '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmffield_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
