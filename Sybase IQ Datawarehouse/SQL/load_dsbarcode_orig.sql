truncate table  dsbarcode_orig;
LOAD into table dsbarcode_orig
(
    documentID   '|:|' ,
    service_type '|:|'  ,
    reference_num '|:|' ,
    shipper_num  '|:|'  ,
    billable_weight  '|:|' ,
    weight_type    '\n'
)
from '/opt/sybase/bcp_data/rev_hist/dsbarcode_orig_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

