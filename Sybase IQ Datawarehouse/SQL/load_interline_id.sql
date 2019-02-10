truncate table il_interline_id;
LOAD into table il_interline_id 
(
    interline_id       '|:|',
    interline_name     '|:|',
    inserted_on_cons   '|:|',
    updated_on_cons    '\n'
)
from '/opt/sybase/bcp_data/cpscan/il_interline_id_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
