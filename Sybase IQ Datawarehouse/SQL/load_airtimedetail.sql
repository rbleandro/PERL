LOAD into table airtime_detail
(
Client_Number ',',
Invoice_Date ',',
Billing_Name ',',
EdLine ',',
Purchase_order ',',
Invoice_number ',',
SubLevelA ',',
SubLevelB ',',
UnitNumber ',',
UserName ',',
AdditionalUsername ',',
reference1 ',',
reference2 ',',
UsageType ',',
AirTimecall ',',
AirTimeDate ',',
AirtimeTime ',',
callPeriod ',',
From_ ',',
NumberCalled ',',
To_ ',',
CallType ',',
calllength ',',
LocalAirTimeRate ',',
LocalAirtimeCharges ',',
LDCharges ',',
AdditionalCallCharges ',', 
total '\n'
)
from '/opt/sybase/tmp/airtime_detail.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
