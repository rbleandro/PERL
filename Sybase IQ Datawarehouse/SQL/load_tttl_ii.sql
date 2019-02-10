truncate table tttl_ii_interline_inbound;
LOAD into table tttl_ii_interline_inbound 
(
    conv_time_date       '|:|',
    employee_num         '|:|',
    interline_num        '|:|',
    unit_num             '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    terminal_num         '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ii_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
