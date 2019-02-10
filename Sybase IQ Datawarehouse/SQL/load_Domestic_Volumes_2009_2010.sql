truncate table Dom_Vol_09_10;
LOAD into table Dom_Vol_09_10
(
        Group_Customer ,
        FILLER('|'),
        Customer ,
        FILLER('|'),
        Customer_Province ,
        FILLER('|'),
        Customer_City ,
        FILLER('|'),
        Product_Code ,
        FILLER('|'),
        PU_Year_Month ,
        FILLER('|'),
        Origin_Post_Code ,
        FILLER('|'),
        Origin_IATA ,
        FILLER('|'),
        Dest_Post_Code ,
        FILLER('|'),
        Dest_IATA ,
        FILLER('|'),
        Basic_Charges ,
        FILLER('|'),
        Freight_Charges ,
        FILLER('|'),
        Surcharges ,
        FILLER('|'),
        Liability_Charges ,
        FILLER('|'),
        Additional_Charges ,
        FILLER('|'),
        Fuel_Charges ,
        FILLER('|'),
        Total_Revenue ,
        FILLER('|'),
        Total_Shipments ,
        FILLER('|'),
        Total_Weight ,
        FILLER('|'),
        Total_Pieces ,
        FILLER('|'),
        Group_Cust_Intl_Spend

)
from '/opt/sybase/tmp/Domestic_Volumes_2009_2010.txt'
QUOTES OFF
ESCAPES OFF
FORMAT ascii
SKIP 1
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
ROW DELIMITED BY '\n'
PREVIEW ON

