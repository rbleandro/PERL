truncate table Attributes_mtl;
LOAD into table Attributes_mtl
(
	AttributeID '|:|',
	StatClassID '|:|',
	Parm_ID1 '|:|',
	Parm_ID2 '|:|',
	Description '|:|',
	HasExpectedValue '|:|',
	Width '|:|',
	Expression '|:|',
	Position '\n'
)

from '/opt/sybase/bcp_data/mtldb/Attributes_MTL.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

