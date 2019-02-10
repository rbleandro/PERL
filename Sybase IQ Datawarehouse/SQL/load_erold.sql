LOAD into table er 
(
er_id  ',',
bill_l_id ',',
group_id ',',
ebod_version_number ',',
billing_system_id ',',
pilot_customer_account_number ',',
billing_date  ',',
billing_cs_account_number ',',
record_type_code ',',
pilot ',',
pilot_psc ',',
organization ',',
organization_psc ',',
billing_number ',',
billing_number_psc ',',
circuit_number ',',
circuit_point ',',
effective_date  ',',
quantity ',',
description ',',
pre_tax_amount ',',
gst ',',
hst ',',
taxing_province ',',
pst ',',
toll_plan_description ',',
service_address ',',
circuit_address ',',
tariff_code ',',
toll_plan_id ',',
bill_section ',',
supporting_report_name ',',
order_number ',',
unit_cost ',',
nbp_id '\n'
)
from '/opt/sybase/tmp/er.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
