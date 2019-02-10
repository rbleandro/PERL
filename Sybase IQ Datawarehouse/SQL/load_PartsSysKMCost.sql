truncate table PartsSysKMCost;
LOAD into table PartsSysKMCost
(
	MeterType '|:|',
	Fleet '|:|',
	Unit '|:|',
	Sys '|:|',
        CumUsage '|:|',
	Travelled '|:|',
	PartsCost '|:|',
	ROdate '|:|',
	RO_No '|:|',
	Lines '|:|',
	EqYear '|:|',
	EqMod '|:|',
	EqMake '|:|',
	POCloseDate '|:|',
	PO_No '|:|',
	P_Group '|:|',
	EqType '|:|',
	Reason_of_Repair '|:|',
	EqGroup '\n' 
)

from '/opt/sybase/bcp_data/cmf_data/PartsSysKMCost_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

