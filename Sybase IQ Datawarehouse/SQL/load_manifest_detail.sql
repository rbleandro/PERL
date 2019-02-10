truncate table manifest_detail;
LOAD into table manifest_detail
(
shipper_num       '|:|',
manifest          '|:|',
receive_date_time '|:|',
pickup_date_time  '|:|',
pieces            '|:|',
manifest_2D_flag  '\n'
)

from '/opt/sybase/bcp_data/cpscan/manifest_detail_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

