truncate table missed_pu_rpt;
LOAD into table missed_pu_rpt
(
report_date          '|:|',
customer             '|:|',
picked_up_flag       '|:|',
actual_pu_time       '|:|',
pu_rec_num           '|:|',
num_pickup_packages  '|:|',
num_scanned_packages '\n'
)
from '/opt/sybase/bcp_data/cmf_data/missed_pu_rpt_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
