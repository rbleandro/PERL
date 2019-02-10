truncate table Attributes;
LOAD into table Attributes
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

from '/opt/sybase/bcp_data/ssdb/Attributes.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

