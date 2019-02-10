truncate table ilexception;
LOAD into table ilexception        
(
ilinkage            '|:|',
stop_number      '|:|',
service_type     '|:|',
reference_num    '|:|',
shipper_num      '|:|',
pickup_shipper   '|:|',
freight_cost     '|:|',
ancillary_charge '|:|',
fuel_surcharge   '|:|',
exception_code   '|:|',
exception_note   '|:|',
review_date      '|:|',
review_status    '|:|',
review_user      '|:|',
po_number    '\n'  
)
from '/opt/sybase/bcp_data/cmf_data/ilexception_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
