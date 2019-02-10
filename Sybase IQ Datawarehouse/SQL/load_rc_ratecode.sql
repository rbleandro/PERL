truncate table rc_ratecode;
LOAD into table rc_ratecode 
(
	rate_code                       '|:|',
	service_type                    '|:|',
	short_description               '|:|',
	KorL                            '|:|',
	rate_code_alpha                 '|:|',
	rate_name                       '|:|',
	rate_KorL                       '|:|',
	rate_suffix                     '|:|',
	zone_name                       '|:|',
	zone_version                    '|:|',
	ins_mode                        '|:|',
	insurance_limit                 '|:|',
	insurance_rate                  '|:|',
	cod_mode                        '|:|',
	single_cod_fee                  '|:|',
	multi_cod_fee                   '|:|',
	cod_pc_value_limit              '|:|',
	cod_sh_value_limit              '|:|',
	hvr_rate                        '|:|',
	hvr_mode                        '|:|',
	max_weight_per_piece            '|:|',
	weight_limit                    '|:|',
	pieces_limit                    '|:|',
	dec_val_piece_limit             '|:|',
	dec_val_sh_limit                '|:|',
	put_charge                      '|:|',
	extra_charge                    '|:|',
	full_description                '|:|',
	min_weight                      '|:|',
	applies_to_pieces               '|:|',
	inserted_on_cons                '|:|',
	updated_on_cons                 '|:|',
	ea_charge1                      '|:|',
	ea_charge2                      '|:|',
	ea_charge3                      '|:|',
	resi_charge                     '|:|',
	ea_zone_name                    '|:|',
	ea_zone_version                 '|:|',
	ea_charge4 			'|:|',
	ea_charge5 			'|:|',
	ea_charge6 			'|:|',
	ea_charge7 			'|:|',
	ea_charge8 			'|:|',
	ea_charge9 			'|:|',
	ea_charge10 			'|:|',
	ea_charge11			'|:|',
	ea_charge12 			'|:|',
	ea_charge13			'|:|',
	ea_charge14 			'|:|',
	ea_charge15 			'|:|',
	ea_charge16 			'|:|',
	ea_charge17 			'|:|',
	ea_charge18 			'|:|',
	ea_charge19 			'|:|',
	ea_charge20 			'\n'
)

from '/opt/sybase/bcp_data/cmf_data/rc_ratecode_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
