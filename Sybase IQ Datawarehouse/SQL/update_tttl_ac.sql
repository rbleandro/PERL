select * into #tttl_ac_upd from tttl_ac_address_correction where 1=2;

LOAD into table #tttl_ac_upd
(   reference_num      '|:|',
    service_type       '|:|',
    shipper_num        '|:|',
    conv_time_date     '|:|',
    employee_num       '|:|',
    adcor_barcode      '|:|',
    pickup_shipper_num '|:|',
    del_conv_time_date '|:|',
    del_employee_num   '|:|',
    billed_date        '|:|',
    inserted_on_cons   '|:|',
    updated_on_cons    '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ac_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ac_address_correction
set 
    t.conv_time_date     = upd.conv_time_date,
    t.employee_num       = upd.employee_num,
    t.adcor_barcode      = upd.adcor_barcode,
    t.pickup_shipper_num = upd.pickup_shipper_num,
    t.del_conv_time_date = upd.del_conv_time_date,
    t.del_employee_num   = upd.del_employee_num,
    t.billed_date        = upd.billed_date,
    t.updated_on_cons    = upd.updated_on_cons

from tttl_ac_address_correction t, #tttl_ac_upd upd
where t.reference_num      = upd.reference_num and
      t.service_type       = upd.service_type and
      t.shipper_num        = upd.shipper_num;
