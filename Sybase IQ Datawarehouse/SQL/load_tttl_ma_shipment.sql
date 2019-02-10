--truncate table tttl_ma_shipment;
load into table tttl_ma_shipment
(
manlink		'|:|',  
shipment_id     '|:|',
pieces          '|:|',
weight          '|:|',
spec_inst       '|:|',
cust_reference  '|:|',
cost_centre     '|:|',
order_number    '|:|',
service_code    '|:|',
total_charges   '|:|',
DV_charges      '|:|',
DV_amount       '|:|',
PUT_charges     '|:|',
XC_charges      '|:|',
HST             '|:|',
GST             '|:|',
QST             '|:|',
zone            '|:|',
cons_account    '|:|',
cons_name       '|:|',
cons_address1   '|:|',
cons_address2   '|:|',
cons_address3   '|:|',
cons_city       '|:|',
cons_prov       '|:|',
cons_postal     '|:|',
cons_attention  '|:|',
xc_pieces       '|:|',
min_weight_flag '|:|',
NSR_flag        '|:|',
estimated_del_date'|:|',
EA_charges '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_shipment_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
