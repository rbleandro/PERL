truncate table tttl_ac_address_correction;
LOAD into table tttl_ac_address_correction 
(
    reference_num          '|:|',
    service_type           '|:|',
    shipper_num            '|:|',
    conv_time_date         '|:|',
    employee_num           '|:|',
    adcor_barcode          '|:|',
    pickup_shipper_num     '|:|',
    del_conv_time_date     '|:|',
    del_employee_num       '|:|',
    billed_date            '|:|',
    inserted_on_cons       '|:|',
    updated_on_cons        '|:|',
    new_address1           '|:|',
    new_address2           '|:|',
    new_postal_code        '|:|',
    changed                '|:|',
    redirected_by_shipper  '|:|',
    redirected_by_consignee'|:|',
    redirected_by_name     '|:|',
    process_status         '|:|',
    terminal_num           '|:|',
    new_address3           '\n' 

)
from '/opt/sybase/bcp_data/cpscan/tttl_ac_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
