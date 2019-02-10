LOAD into table nameaddr 
(
nameadd_id ',',
bill_l_id ',',
group_id ',',
ebod_version_number ',',
billing_system_id ',',
pilot_customer_account_number ',',
billing_date ',',
billing_cs_account_number ',',
record_type_code ',',
number ',',
number_psc ',',
circuit_number ',',
billing_name ',',
billing_address ',',
service_address  '\n'
)
from '/opt/sybase/tmp/nameaddr.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
