Truncate table tttl_se_search;
LOAD into table tttl_se_search 
(
    reference_num      '|:|',
    service_type       '|:|',
    shipper_num        '|:|',
    trace_num          '|:|',
    trace_agent        '|:|',
    con_trace_agent    '|:|',
    postal_code        '|:|',
    start_search_date  '|:|',
    end_search_date    '|:|',
    found_date         '|:|',
    found_flag         '|:|',
    print_location     '|:|',
    con_print_location '|:|',
    inserted_on_cons   '|:|',
    updated_on_cons    '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_se_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
