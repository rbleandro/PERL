LOAD into table corporate_test(
Client_Number ',',
card_no ',',
unit_no ',', 
purchase_date ',',
Supplier_Name ',',
city ',',
prov ',',
invoive_no ',',
supplier_pst ',',
total_amount ',',
gas_qty ',',
gross_amt_gas ',',
price_per_litre ',',
gas_type ',',
gas_tps_amount ',',
gas_gst_amount ',',
discount ',',
Gas_Discount_Amount ',',
Gas_Amount_Net ',',
Gas_Amount_Due ',',
Gross_Amount_Oil ',',
Oil_TPS_Amount ',',
Oil_GST_Amount ',',
Oil_Discount ',',
Oil_Discount_Amount ',',
Oil_Amount_Net ',',
Oil_Amount_Due ',',
Gross_Amount_Other ',',
Other_TPS_Amount ',',
Other_GST_Amount ',',
Other_Discount ',',
Other_Discount_Amount ',',
Other_Net_Amount ',',
Other_Due_Amount ',',
Odometre ',',
Maintenance_Gross_Amount ',',
Maintenance_TPS_Amount ',',
Maintenance_GST_Amount ',',
Maintenace_Discount ',',
Maintenance_Discount_Amount ',',
Maintenance_Net_Amount ',',
Maintenance_Due_Amount ',',
Number_of_Days ',',
Rental_Gross_Amount ',',
Rental_TPS_Amount ',',
Rental_GST_Amount ',',
Discount_Percentage ',',
Rental_Discount_Amount ',',
Rental_Net_Amount ',', 
Rental_Due_Amount ',',
Total_Amount_Due ',',
Invoice_Date '\n'
)
from '/opt/sybase/tmp/corporate.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
