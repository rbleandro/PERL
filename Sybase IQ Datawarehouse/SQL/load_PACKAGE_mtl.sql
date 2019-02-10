truncate table PACKAGE_mtl;
LOAD into table PACKAGE_mtl
(
	Package_ID '|:|',
	Customer_ID '|:|',
	Service_Type_Alpha '|:|', 
	Postal_Code '|:|',
	Service_Type '|:|',
	Weight '|:|',
	Weight_UOM '|:|',
	Download_Time  '|:|',
	Upload_Time  '|:|',
	Arrive_Time  '|:|',
	Depart_Time  '|:|',
	Inbound_Trailer_ID '|:|',
	Outbound_Trailer_ID '|:|',
	Induct_ID  '|:|',
	No_Read_Flag '|:|',
	Keying_Station_ID '|:|',
	Recirc_Count  '|:|',
	Destination_Chute  '|:|',
	Destination_Description '|:|',
	Tracking_ID2 '|:|',
	Tracking_ID3 '|:|',
	Tote_ID '|:|',
	No_Read_Count  '|:|',
	Number_Of_Packages_Scanned  '|:|',
	Number_Of_Packages_Keyed  '|:|',
	Inbound_Trailer_Pk '|:|',
	Outbound_Trailer_Pk '|:|',
	Create_Time   '|:|',
	Length  '|:|',
	Width  '|:|',
	Height  '|:|',
	Volume  '|:|',
	CargoScan_Status '|:|',
	repl_id '\n'
)

from '/opt/sybase/bcp_data/mtldb/PACKAGE_MTL.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

