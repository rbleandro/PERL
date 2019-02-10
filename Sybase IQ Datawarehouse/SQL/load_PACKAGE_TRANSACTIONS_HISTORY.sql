--truncate table PACKAGE_TRANSACTIONS_HISTORY;
LOAD into table PACKAGE_TRANSACTIONS_HISTORY
(
	GUID '|:|',
	Transaction_Time  '|:|',
	"Type"  '|:|',
	Package_ID '|:|',
	Customer_ID '|:|',
	Shipment_ID '|:|',
	Service_Type '|:|',
	Postal_Code '|:|',
	Tunnel_ID  '|:|',
	Door_ID  '|:|',
	Virtual_Scanner_ID  '|:|',
	Key_Station_ID  '|:|',
	Virtual_Chute_ID  '|:|',
	Physical_Chute_ID  '|:|',
	Destination_ID  '|:|',
	Inbound_Trailer_ID  '|:|',
	Outbound_Trailer_ID  '|:|',
	Smart_Barcode '|:|',
	Barcode_2 '|:|',
	Barcode_3 '|:|',
	Barcode_4 '|:|',
	Tote_ID '|:|',
	Pallet_ID  '|:|',
	Container_ID  '|:|',
	Cart_ID '|:|',
	Reject_Reason  '|:|',
	Sort_Method  '|:|',
	Actual_Length  '|:|',
	Actual_Width  '|:|',
	Actual_Height  '|:|',
	Actual_Volume  '|:|',
	Is_XC  '|:|',
	XC_Reason_ID '|:|',
	Dimensioner_Status_Code '|:|', 
	Actual_Weight  '|:|',
	Actual_Weight_Status_Code '|:|',
	Sorter_Cell_ID  '|:|',
	Object_ID  '|:|',
	"Comment" '\n'
)

from '/opt/sybase/bcp_data/ssdb/PTH.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

