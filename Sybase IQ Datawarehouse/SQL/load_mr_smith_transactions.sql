LOAD into table mr_smith_transactions
(
card_number '\x09',
trans_date '\x09',
trans_time '\x09',
site_name '\x09',
product '\x09',
quantity '\x09',
price_per_litre '\x09',
fuel_tax_per_litre '\x09',
unit_price_excl_gst '\x09',
trans_price_excl_gst '\x09',
trans_gst '\x09',
trans_price_incl_gst '\x09',
card_driver '\x09',
card_unit '\x09',
trans_driver '\x09',
trans_unit '\x09',
last_odometer '\x09',
this_odometer '\x09',
invoice_date '\n'
)

from '/opt/sybase/tmp/mr_smith_transactions.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
