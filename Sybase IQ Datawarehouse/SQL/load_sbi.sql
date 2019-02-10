LOAD into table sbi
(
sbi_id ',',
bill_l_id ',',
group_id ',',
ebod_version_number ',',
billing_system_id ',',
pilot_customer_account_number ',',
billing_date ',',
billing_customer_account_number ',',
record_type_code ',',
number_customer_account_number ',',
number ',',
number_psc ',',
number_sbi ',',
level_indentation ',',
pilot_indicator ',',
bill_payer ',',
billing_name ',',
number_of_nodes_per_bill ',',
taxing_province ',',
customer_account_number_check_digit ',',
pilot_customer_account_number_1 ',',
pilot ',',
pilot_psc ',',
pilot_sbi ',',
organization_cs_account_number ',',
organization ',',
organization_psc ',',
organization_sbi ',',
billing_number_cs_account_number ',',
billing_number ',',
billing_number_psc ',',
billing_number_sbi ',',
reference_number_cs_account_number ',',
reference_number ',',
reference_number_psc ',',
reference_number_sbi  '\n'
)
from '/opt/sybase/tmp/sbi.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
