truncate table LaborSysKMCost;
LOAD into table LaborSysKMCost
(
   	MeterType '|:|',
	Fleet '|:|',
	Unit '|:|',
	Sys '|:|',
        CumUsage '|:|',
	Travelled '|:|',
	LaborCost '|:|',
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

from '/opt/sybase/bcp_data/cmf_data/LaborSysKMCost_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

