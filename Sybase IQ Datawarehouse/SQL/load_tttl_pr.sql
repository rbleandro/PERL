--truncate table tttl_pr_pickup_record;
LOAD into table tttl_pr_pickup_record 
(
    pickup_rec_num           '|:|',
    conv_time_date           '|:|',
    employee_num             '|:|',
    num_pickup_packages      '|:|',
    num_pickup_cod           '|:|',
    num_pickup_select        '|:|',
    multiple_pickup_rec_flag '|:|',
    manifest_flag            '|:|',
    not_scanned_flag         '|:|',
    manual_entry_flag        '|:|',
    inserted_on_cons         '|:|',
    updated_on_cons          '|:|',
    modified_pickup_record   '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
