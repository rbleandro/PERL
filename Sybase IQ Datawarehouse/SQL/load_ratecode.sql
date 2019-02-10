LOAD into table ratecode 
(
    rate_code            '|:|',
    service_type         '|:|',
    short_description    '|:|',
    KorL                 '|:|',
    status               '|:|',
    rate_name            '|:|',
    rate_KorL            '|:|',
    rate_version         '|:|',
    zone_name            '|:|',
    zone_version         '|:|',
    effective_date       '|:|',
    previous_rate_code   '|:|',
    ins_mode             '|:|',
    insurance_limit      '|:|',
    insurance_rate       '|:|',
    cod_mode             '|:|',
    single_cod_fee       '|:|',
    multi_cod_fee        '|:|',
    cod_pc_value_limit   '|:|',
    cod_sh_value_limit   '|:|',
    hvr_rate             '|:|',
    hvr_mode             '|:|',
    max_weight_per_piece '|:|',
    weight_limit         '|:|',
    pieces_limit         '|:|',
    dec_val_piece_limit  '|:|',
    dec_val_sh_limit     '|:|',
    put_charge           '|:|',
    extra_charge         '|:|',
    full_description     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ratecode_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
