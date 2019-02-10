truncate table tttl_pt_pickup_totals;
LOAD into table tttl_pt_pickup_totals 
(
    conv_time_date       '|:|',
    employee_num         '|:|',
    num_packages_scanned '|:|',
    num_cod_scanned      '|:|',
    num_select_scanned   '|:|',
    num_hvr_scanned      '|:|',
    totals_no_match_flag '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pt_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
