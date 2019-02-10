truncate table all_major_cities;
LOAD into table all_major_cities
(   postal_code		'|:|',
    province_code	'|:|',
    major_city		'\n'
)
from '/opt/sybase/bcp_data/canada_post/all_major_cities.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
