truncate table tttl_hc_hub_cod;
LOAD into table tttl_hc_hub_cod 
(
    reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    scan_time_date   '|:|',
    employee_num     '|:|',
    interline_id     '|:|',
    status           '|:|',
    city             '|:|',
    postal_code      '|:|',
    cod_label_amount '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_hc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
