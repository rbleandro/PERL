LOAD into table group_summary
(
Client_Number ',',
Invoice_Date ',',
Billing_Name ',',
EdLine ',',
Purchase_order ',',
Invoice_number ',',
ProductType ',',
User_ ',',
SubLevelA ',',
SubLevelB ',',
UserName ',',
AdditionalUsername',',
reference1 ',', 
reference2 ',',
Adjustments ',',
AdjustmentsHST ',',
AdjustmentsPST ',',
AdjustmentsGST ',',
ServicePlanName ',',
ServicePlanPrice ',',
AdditionalLocalAirtime ',',
Over_Under ',',
ContributiontoPool ',',
PhoneLongDistanceCharges ',',
PrivateGroupLongDist ',',
RoamingCharges ',',
DoMoreDataServices ',',
DoMoreVoiceServices ',',
PagerServices ',',
ValueAddedServices ',',
OtherCharges ',',
NetworkCharges ',',
HST ',',
PST_BC ',',
PST_AB ',',
PST_SK ',',
PST_MB ',',
PST_ON ',',
PST_PE ',',
QST ',',
SubtotalbeforeGST ',',
GST ',',
TotalCurrentCharges ',',
TotalChargesAdj '\n'
)
from '/opt/sybase/tmp/group_summary.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
