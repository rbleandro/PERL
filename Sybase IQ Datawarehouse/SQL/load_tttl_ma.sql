truncate table tttl_ma_manifest;
LOAD into table tttl_ma_manifest 
(
    service_type         '|:|',
    reference_num        '|:|',
    shipper_num          '|:|',
    conv_time_date       '|:|',
    pickup_date          '|:|',
    manifest_num         '|:|',
    consignee_account    '|:|',
    consignee_name       '|:|',
    consignee_address1   '|:|',
    consignee_address2   '|:|',
    consignee_address3   '|:|',
    consignee_city       '|:|',
    consignee_province   '|:|',
    consignee_postalcode '|:|',
    package_weight       '|:|',
    customer_reference   '|:|',
    customer_costcentre  '|:|',
    customer_order_num   '|:|',
    estimated_del_date   '|:|',
    inserted_on_cons     '|:|',
    updated_on_cons      '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;
