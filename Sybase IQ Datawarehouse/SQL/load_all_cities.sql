truncate table all_cities;
LOAD into table all_cities
(   postal_code		'|:|',
    city  	        '|:|',
    province_code	'\n'
)
from '/opt/sybase/bcp_data/cpscan/all_cities.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
