truncate table tttl_ma_document;
load into table tttl_ma_document
(
shipper_num	'|:|',   
manifest_num	'|:|',  
manifest_date	'|:|', 
filedatetime	'|:|',  
manlink		'|:|',       
weight_unit	'|:|',   
EDMP_flag	'|:|',
filenum   	'|:|',
filename	'\n'	
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_document_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
