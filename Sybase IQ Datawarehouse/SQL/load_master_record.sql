truncate table master_record;
LOAD into table master_record
(
	shipper_num                     '|:|',
	reference_num                   '|:|',
	service_type                    '|:|',
	inserted_on                     '|:|',
	linkage                         '|:|',
	shipment_id                     '|:|',
	origin_pc                       '|:|',
	origin_terminal                 '|:|',
	origin_interline                '|:|',
	destin_terminal                 '|:|',
	destin_interline                '|:|',
	destin_pc                       '|:|',
	scan_date                       '|:|',
	scan_terminal                   '|:|',
	scan_status                     '|:|',
	pickup_date                     '|:|',
	ground_base                     '|:|',
	ground_net                      '|:|',
	select_base                     '|:|',
	select_net                      '|:|',
	us_base                         '|:|',
	us_net                          '|:|',
	weight                          '|:|',
	dim_weight                      '|:|',
	rate_code                       '|:|',
	rate_zone                       '|:|',
	bill_to                         '|:|',
	account_group                   '|:|',
	data_entry_date                 '|:|',
	actual_pd_cost                  '|:|',
	implied_pd_cost                 '|:|',
	actual_hub_cost                 '|:|',
	implied_hub_cost                '|:|',
	actual_linehaul_cost            '|:|',
	implied_linehaul_cost           '|:|',
	actual_interline_cost           '|:|',
	implied_interline_cost          '|:|',
	actual_preload_cost             '|:|',
	implied_preload_cost            '|:|',
	record_complete                 '||\n'

)
from '/opt/sybase/bcp_data/mpr_data/master_record_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
