truncate table ba_barcode_audit;
LOAD into table ba_barcode_audit
(
conv_time_date   '|:|',
employee_num     '|:|',
service_type     '|:|',
reference_num    '|:|',
shipper_num      '|:|',
inserted_on_cons '|:|',
updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/ba_barcode_audit_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
