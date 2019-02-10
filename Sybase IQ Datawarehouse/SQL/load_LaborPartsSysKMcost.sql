truncate table LaborPartsSysKMcost;
LOAD into table LaborPartsSysKMcost
(
        MeterType 	'|:|',
	Fleet 		'|:|',
	Unit 		'|:|',
	Sys 		'|:|',
	CumUsage 	'|:|',
	Travelled 	'|:|',
	LaborCost 	'|:|',
	PartsCost 	'|:|',
	ReadingDate 	'|:|',
	RO_No 		'|:|',
	Lines 		'|:|',
	EqYear 		'|:|',
	EqMod 		'|:|',
	EqMake		'|:|',
	POClosedDate 	'|:|',
	PO_No 		'|:|',
	P_Group 	'|:|',
	EqType 		'|:|',
	ReasonofRepair 	'|:|',
	EqGroup 	'|:|',
	RegHours 	'|:|',
	OTHours		'\n' 
)

from '/opt/sybase/bcp_data/cmf_data/LaborPartsSysKMcost_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

