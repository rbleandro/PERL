select * into #tttl_ma_upd from tttl_ma_manifest where 1=2;

LOAD into table #tttl_ma_upd
(   service_type         '|:|',
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
from '/opt/sybase/bcp_data/cpscan/tttl_ma_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ma_manifest
set     
    t.conv_time_date       = upd.conv_time_date,
    t.pickup_date          = upd.pickup_date,
    t.manifest_num         = upd.manifest_num,
    t.consignee_account    = upd.consignee_account,
    t.consignee_name       = upd.consignee_name,
    t.consignee_address1   = upd.consignee_address1,
    t.consignee_address2   = upd.consignee_address2,
    t.consignee_address3   = upd.consignee_address3,
    t.consignee_city       = upd.consignee_city,
    t.consignee_province   = upd.consignee_province,
    t.consignee_postalcode = upd.consignee_postalcode,
    t.package_weight       = upd.package_weight,
    t.customer_reference   = upd.customer_reference,
    t.customer_costcentre  = upd.customer_costcentre,
    t.customer_order_num   = upd.customer_order_num,
    t.estimated_del_date   = upd.estimated_del_date,
    t.updated_on_cons      = upd.updated_on_cons
    
from tttl_ma_manifest t, #tttl_ma_upd upd
where   t.service_type         = upd.service_type and
    	t.reference_num        = upd.reference_num and
    	t.shipper_num          = upd.shipper_num;
