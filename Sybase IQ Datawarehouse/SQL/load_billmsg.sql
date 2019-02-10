LOAD into table billmsg 
(
billmsg_id ',',
bill_l_id ',',
group_id ',',
ebod_version_number ',',
billing_system_id ',',
pilot_customer_account_number ',',
billing_date ',',
billing_cs_account_number ',',
record_type_code ',',
billing_number ',',
billing_number_psc ',',
heading ',',
message1 ',',
message2 ',',
message3 ',',
message4 ',',
message5 ',',
message_type ',',
bill_section ',',
message_type_code ',',
message_id ',',
message_priority ',',
indentation ',',
font '\n'
)
from '/opt/sybase/tmp/billmsg.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
