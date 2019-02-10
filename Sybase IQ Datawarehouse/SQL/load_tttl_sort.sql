--truncate table tttl_sortation;
LOAD into table tttl_sortation
(
service_type       '|:|',
reference_num      '|:|',
shipper_num        '|:|',
in_trailer         '|:|',
in_chute           '|:|',
in_timedate        '|:|',
barcode1           '|:|',
barcode2           '|:|',
barcode3           '|:|',
postal_code        '|:|',
service_code       '|:|',
weight             '|:|',
weight_unit        '|:|',
no_read            '|:|',
station_id         '|:|',
recirculation      '|:|',
dest_chute         '|:|',
dest_trailer       '|:|',
dest_timedate      '|:|',
sort_descr         '|:|',
sort_terminal      '|:|',
inserted_on_cons   '|:|',
record_id          '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_sortation_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
