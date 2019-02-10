truncate table tttl_lo_linehaul_outbound;
LOAD into table tttl_lo_linehaul_outbound 
(
    conv_time_date       '|:|',
    employee_num         '|:|',
    trailer_num          '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    terminal_num         '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_lo_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
