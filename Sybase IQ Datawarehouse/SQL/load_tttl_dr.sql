set option LOAD_MEMORY_MB = 500;
truncate table tttl_dr_delivery_record;
LOAD into table tttl_dr_delivery_record
(   conv_time_date '|:|',
    employee_num '|:|',
    delivery_rec_num '|:|',
    multiple_del_rec_flag '|:|',
    manual_entry_flag '|:|',
    consignee_name '|:|',
    consignee_num '|:|',
    consignee_unit_number_name '|:|',
    consignee_street_number '|:|',
    consignee_street_name '|:|',
    consignee_more_address '|:|',
    consignee_city '|:|',
    consignee_postal_code '|:|',
    residential_flag '|:|',
    inserted_on_cons '|:|',
    updated_on_cons '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_dr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
