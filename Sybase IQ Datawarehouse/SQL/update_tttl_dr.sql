select * into #tttl_dr_upd from tttl_dr_delivery_record where 1=2;

LOAD into table #tttl_dr_upd
(   conv_time_date 		'|:|',
    employee_num 		'|:|',
    delivery_rec_num 		'|:|',
    multiple_del_rec_flag 	'|:|',
    manual_entry_flag 		'|:|',
    consignee_name 		'|:|',
    consignee_num 		'|:|',
    consignee_unit_number_name 	'|:|',
    consignee_street_number 	'|:|',
    consignee_street_name 	'|:|',
    consignee_more_address 	'|:|',
    consignee_city 		'|:|',
    consignee_postal_code 	'|:|',
    residential_flag 		'|:|',
    inserted_on_cons 		'|:|',
    updated_on_cons 		'\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_dr_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_dr_delivery_record
set     	   
    t.multiple_del_rec_flag 	 = upd.multiple_del_rec_flag,
    t.manual_entry_flag 	 = upd.manual_entry_flag,
    t.consignee_name 		 = upd.consignee_name,
    t.consignee_num 		 = upd.consignee_num,
    t.consignee_unit_number_name = upd.consignee_unit_number_name,
    t.consignee_street_number 	 = upd.consignee_street_number,
    t.consignee_street_name 	 = upd.consignee_street_name,
    t.consignee_more_address 	 = upd.consignee_more_address,
    t.consignee_city 		 = upd.consignee_city,
    t.consignee_postal_code 	 = upd.consignee_postal_code,
    t.residential_flag 		 = upd.residential_flag,
    t.updated_on_cons 		 = upd.updated_on_cons

from tttl_dr_delivery_record t, #tttl_dr_upd upd
where   t.conv_time_date 	 = upd.conv_time_date and
    	t.employee_num 		 = upd.employee_num and
    	t.delivery_rec_num 	 = upd.delivery_rec_num;
