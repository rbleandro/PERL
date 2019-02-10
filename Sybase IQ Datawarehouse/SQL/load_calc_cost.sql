truncate table calc_cost;
LOAD into table calc_cost 
(

	"record_id" '|:|',
	"opickup" '|:|',
	"osort" '|:|',
	"ofixedoh" '|:|',
	"ovaroh" '|:|',
	"dsort" '|:|',
	"dfixoh" '|:|',
	"dvaroh" '|:|',
	"dlinehaul" '|:|',
	"t1sort" '|:|',
	"t1fixoh" '|:|',
	"t1varoh" '|:|',
	"t1linehaul" '|:|',
	"m2sort" '|:|',
	"m2fixoh" '|:|',
	"m2varoh" '|:|',
	"m2linehaul" '|:|',
	"m3sort" '|:|',
	"m3fixoh" '|:|',
	"m3varoh" '|:|',
	"m3linehaul" '|:|',
	"m4sort" '|:|',
	"m4fixedoh" '|:|',
	"m4varoh" '|:|',
	"m4linehaul" '|:|',
	"m5sort" '|:|',
	"m5fixedoh" '|:|',
	"m5varoh" '|:|',
	"m5linehaul" '|:|',
	"ddelivery" '|:|',
	"pickupvmaint" '|:|',
	"delvmaint" '|:|',
	"errorflag" '|:|',
	"sample" '|:|\n'
)

from '/opt/sybase/bcp_data/cmf_data/calc_cost_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
