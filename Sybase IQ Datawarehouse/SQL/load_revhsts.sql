truncate table revhsts;
LOAD into table revhsts
(   
shipper_num     '|:|',
pickup_rec_num  '|:|',
pickup_rec_date '|:|',
data_entry_date '|:|',
service         '|:|',
rate_code       '|:|',
shipments       '|:|',
pieces          '|:|',
weight          '|:|',
base            '|:|',
discount        '|:|',
freight         '|:|',
f16912          '|:|',
COD_charges     '|:|',
DV_charges      '|:|',
PUT_charges     '|:|',
XC_charges      '|:|',
MISC_charges    '|:|',
total           '\n'

)
from '/opt/sybase/bcp_data/rev_hist/revhsts_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
