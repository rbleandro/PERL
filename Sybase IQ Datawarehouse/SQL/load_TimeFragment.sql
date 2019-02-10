truncate table TimeFragment;
LOAD into table TimeFragment
(
	TimeFragmentID '|:|',
	TimeID         '\n'
)

from '/opt/sybase/bcp_data/ssdb/TimeFragment.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

