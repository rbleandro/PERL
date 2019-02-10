LOAD into table invoice_summary
(
FILLER(1),
Client_Number '","',
Invoice_Date '","', 
Billing_Name '","',
EdLine '","',
Purchase_order '","',
Invoice_number '","',
MonthlyServicePlans '","',
AdditionalLocalAirtime '","',  
LongDistanceCharges '","',
RoamingCharges '","',
DoMoreDataServices '","',
DoMoreVoiceServices '","',
PagerServices '","',
ValueAddedServices '","',
OtherChargesCredits '","',
NetworkLicCharges '","',
HST  '","',
PST_BC '","',
PST_AB '","',
PST_SK '","', 
PST_MB '","',
PST_ON '","',
PST_PE '","',
QST1002928058 '","',
GSTR866201197 '","',
InternationalRoamingTaxes '","',
TotalTaxes '","',
TotalCurrentCharges '","',
AmountofLastBill '","',
Payments '","',
PaymentReversals '","',
Adjustments '","',
AdjustedHST '","',
AdjustedPSTQST '","',
AdjustedGST '","',
TotalAdjustments '","',
TotalPreChgBroughtForward '","',
TotalAmountDue '\n'
)
from '/opt/sybase/tmp/invoice_summary.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
