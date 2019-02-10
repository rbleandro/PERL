truncate table tttl_cp_cod_package;
LOAD into table tttl_cp_cod_package 
(
    reference_num             '|:|',
    service_type              '|:|',
    shipper_num               '|:|',
    scan_time_date            '|:|',
    employee_num              '|:|',
    cod_label_amount          '|:|',
    status                    '|:|',
    cod_audit_label_chng_flag '|:|',
    cod_comments              '|:|',
    inserted_on_cons          '|:|',
    updated_on_cons           '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_cp_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
