truncate table cmf_baudit_hdr;
LOAD into table cmf_baudit_hdr 
(
customer	'|:|',
cycle           '|:|',
last_audit      '|:|',
notes		'||\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmf_baudit_hdr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

