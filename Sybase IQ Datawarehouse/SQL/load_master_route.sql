truncate table master_route;
LOAD into table master_route
(
	shipper_num                     '|:|',
	reference_num                   '|:|',
	service_type                    '|:|',
	inserted_on                     '|:|',
	hop_number                      '|:|',
	hop_type                        '|:|',
	hop_terminal                    '|:|',
	hop_linehaul                    '|:|',
	hop_date_time                   '|:|',
	hop_expected_date               '|:|',
	hop_actual_cost                 '|:|',
	hop_inferred_cost               '|:|',
	hop_scan                        '|:|',
	miss_sort                       '|:|',
	is_interline                    '||\n'
)
from '/opt/sybase/bcp_data/mpr_data/master_route_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
