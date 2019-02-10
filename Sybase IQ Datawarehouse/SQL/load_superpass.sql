LOAD into table superpass
(
number	',',
card_number ',',
sales_date ',',
sales_time ',',
city	',',
province ',',
product_code ',',
product	',',
volume	',',
net_unit_price ',',
fet	',',
province_tax ',',
gst	',',
pst	',',
amount	',',
odometer ',',
sales_type ',',
doc_id	',',
outlet	',',
misc	',',
oroigin_city ',',
origin_prov ',',
origin_area ',',
origin_num ',',
dest_city ',',
dest_prov ',',
dest_area ',',
dest_num ',',
driver_name ',',
account_num '\n'
)
from '/opt/sybase/tmp/superpass.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
