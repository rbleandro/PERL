LOAD into table occ
(
occ_id ',',
bill_l_id ',',
group_id ',',
ebod_version_number ',',
billing_system_id ',',
pilot_customer_account_number ',',
billing_date ',',
billing_cs_account_number ',',
record_type_code ',',
pilot ',',
pilot_psc ',',
organization ',',
organization_psc ',',
billing_number ',',
billing_number_psc ',',
circuit_number ',',
effective_date ',',
to_date ',',
quantity ',',
description ',',
order_number ',',
pre_tax_amount ',',
gst ',',
hst ',',
taxing_province ',',
pst ',',
toll_plan_description ',',
phrase_code ',',
tariff_code ',',
toll_plan_id ',',
bill_section ',',
supporting_report_name ',',
filler1 ',',
filler2 ',',
unit_cost ',',
nbp_id  '\n'
)
from '/opt/sybase/tmp/occ.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
