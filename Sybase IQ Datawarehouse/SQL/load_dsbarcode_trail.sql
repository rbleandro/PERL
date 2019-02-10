truncate table  dsbarcode_trail;
LOAD into table dsbarcode_trail
(
    acting_user  '|:|' ,
    action_date  '|:|' ,
    action       '|:|' ,
    ins_documentID   '|:|' ,
    ins_service_type '|:|'  ,
    ins_reference_num '|:|' ,
    ins_shipper_num  '|:|'  ,
    ins_billable_weight  '|:|' ,
    ins_weight_type  '|:|' ,
    del_documentID   '|:|' ,
    del_service_type '|:|'  ,
    del_reference_num '|:|' ,
    del_shipper_num  '|:|'  ,
    del_billable_weight  '|:|' ,
    del_weight_type '\n'
)
from '/opt/sybase/bcp_data/rev_hist/dsbarcode_trail_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

