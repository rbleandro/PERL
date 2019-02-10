LOAD into table equipment_Rec_Charge 
( 
AccountNumber ',',
BilledDate ',',
NumberBilled ',',
ConsoSubAccount ',',
Circuit ',',
Division ',',
ServiceEquipment ',',
USOC ',',
USOCShortDesc ',',
Reference_ ',',
ManualRateIndicator ',',
Quantity ',',
UnitCost ',',
MonthlyRate ',',
DiscountGroup ',',
CustomerRefNumber '\n' 
)
from '/opt/sybase/tmp/equip_rec.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
