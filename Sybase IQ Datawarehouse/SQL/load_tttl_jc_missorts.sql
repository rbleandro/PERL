truncate table tttl_jc_missorts;
LOAD into table tttl_jc_missorts
(	service_type      '|:|',
	reference_num     '|:|',
	shipper_num       '|:|',
	scan_time_date    '|:|',
	employee_num      '|:|',
	city              '|:|',
	FSA               '|:|',
	prov              '|:|',
	origin_trm        '|:|',
	trailer_num       '|:|',
	small_sort        '|:|',
	double_label      '|:|',
	bad_code          '|:|',
	inserted_on_cons  '|:|',
	updated_on_cons   '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_jc_missorts_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
