LOAD into table equipment_rec_charges_NSB 
( 
FILLER(1),
BilledTelcoNumber '","',
BillingNumber '","',
NumberBilled '","',
BilledDate '","',
AccountNumber '","',
CustomerReferenceNumber '","',
BilledTypeNumber '","',
Circuit '","',
ServiceorEquipment '","',
USOCShortDescription '","',
ProductCode '","',
ProductCodeDescription '","',
SubProductCode '","',
SubProductCodeDesc '","',
Reference_ '","',
Quantity  '","',
UnitCost  '","',
MonthlyRate '","',
ConsoSubAccount '","',
Division '","',
ManualRateIndicator '","',
ServiceDescription1 '","',
ServiceNumber '","',
USOC  '","',
USOCLongDescription '","',
ProviderID  '\n' 
)
from '/opt/sybase/tmp/equip_rec.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
