--truncate table PACKAGES;
LOAD into table PACKAGES
(
	GUID  '|:|',
	Package_ID '|:|',
	Customer_ID '|:|',
	Service_Type '|:|',
	Postal_Code '|:|',
	Manifest_Weight  '|:|',
	Manifest_Weight_UOM  '|:|',
	Actual_Weight  '|:|',
	Actual_Weight_Status_Code '|:|',
	Manifest_Received_Time  '|:|',
	Upload_Time  '|:|',
	Tunnel_ID  '|:|',
	Scan_Tunnel_Time  '|:|',
	Virtual_Scanner_ID  '|:|',
	Divert_Time  '|:|',
	Door_ID  '|:|',
	Inbound_Trailer_ID  '|:|',
	Outbound_Trailer_ID  '|:|',
	Key_Station_ID  '|:|',
	Key_Station_Time  '|:|',
	Key_Station_Data '|:|',
	Recirc_Count   '|:|',
	Reject_Count  '|:|',
	Virtual_Chute_ID  '|:|',
	Physical_Chute_ID  '|:|',
	Destination_ID  '|:|',
	Smart_Barcode '|:|',
	Barcode_2 '|:|',
	Barcode_3 '|:|',
	Barcode_4 '|:|',
	Tote_ID '|:|',
	Pallet_ID  '|:|',
	Container_ID  '|:|',
	Cart_ID '|:|',
	Logical_Reject_Reason  '|:|',
	Last_Reject_Reason  '|:|',
	Sort_Method  '|:|',
	Actual_Length  '|:|',
	Actual_Width  '|:|',
	Actual_Height  '|:|',
	Actual_Volume  '|:|',
	Dimensioner_Status_Code '|:|',
	Object_ID  '|:|',
	Creation_Type  '|:|',
	Creation_Time '\n'
)

from '/opt/sybase/bcp_data/ssdb/PACKAGES.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

