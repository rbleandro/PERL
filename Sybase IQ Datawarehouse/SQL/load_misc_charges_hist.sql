truncate table misc_charges_hist;
LOAD into table misc_charges_hist
(
customer_num    '|:|',
referenceA      '|:|',
referenceA_date '|:|',
referenceB      '|:|',
charge_code     '|:|',
unique_ref      '|:|',
store_number    '|:|',
amount          '|:|',
ship_type       '|:|',
rate_code       '|:|',
charge_type     '|:|',
entry_date      '|:|',
billed_date     '|:|',
invoice_date    '|:|',
infoA1          '|:|',
infoA2          '|:|',
infoA3          '|:|',
infoA4          '|:|',
infoB1          '|:|',
infoB2          '|:|',
infoB3          '|:|',
infoB4          '|:|',
fsa             '|:|',
barcode         '|:|',
Q               '\n'
)

from '/opt/sybase/bcp_data/cmf_data/misc_charges_hist.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
