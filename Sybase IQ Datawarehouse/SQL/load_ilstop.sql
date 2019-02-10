truncate table ilstop;
LOAD into table ilstop        
(
ilinkage            '|:|',
stop_number         '|:|',
stop_type           '|:|',
stop_data           '|:|',
employee_num        '|:|',
conv_time_date      '|:|',
postal_code         '|:|',
consignee           '|:|',
pieces              '|:|',
put_pieces          '|:|',
area                '|:|',
stop_cost           '|:|',
fuel_surcharge_cost '|:|',
cartage_flag	    '\n'  
)
from '/opt/sybase/bcp_data/cmf_data/ilstop_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
