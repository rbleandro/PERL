LOAD into table rc_zones 
(
    zone_name    '|:|',
    zone_version '|:|',
    from_fsa_1   '|:|',
    from_fsa_2   '|:|',
    to_fsa_1     '|:|',
    to_fsa_2     '|:|',
    rate_zone    '|:|',
    origin	 '|:|',
    originsub	 '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rc_zones_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
