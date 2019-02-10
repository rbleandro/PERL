truncate table TimeFragment_mtl;
LOAD into table TimeFragment_mtl
(
	TimeFragmentID '|:|',
	TimeID         '\n'
)

from '/opt/sybase/bcp_data/mtldb/TimeFragment.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

