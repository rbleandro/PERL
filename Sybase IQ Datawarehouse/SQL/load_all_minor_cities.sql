truncate table all_minor_cities;
LOAD into table all_minor_cities
(   postal_code		'|:|',
    province_code	'|:|',
    minor_city		'\n'
)
from '/opt/sybase/bcp_data/canada_post/all_minor_cities.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
