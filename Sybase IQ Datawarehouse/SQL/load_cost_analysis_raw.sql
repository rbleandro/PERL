truncate table cost_analysis_raw;
LOAD into table cost_analysis_raw 
(
    customer     '|:|',
    ointerline   '|:|',
    dinterline   '|:|',
    ofsa         '|:|',
    dfsa         '|:|',
    oregion      '|:|',
    dregion      '|:|',
    tariff       '|:|',
    salesrep     '|:|',
    purnum       '|:|',
    pudate       '|:|',
    putype       '|:|',
    deltype      '|:|',
    originterm   '|:|',
    desterm      '|:|',
    tterm1       '|:|',
    tterm2       '|:|',
    tterm3       '|:|',
    tterm4       '|:|',
    tterm5       '|:|',
    type         '|:|',
    frt          '|:|',
    ins          '|:|',
    cod          '|:|',
    put          '|:|',
    extra        '|:|',
    misc         '|:|',
    totalrev     '|:|',
    claimrate    '|:|',
    claimcost    '|:|',
    discount     '|:|',
    weight       '|:|',
    ship_pieces  '|:|',
    pickup_pcs   '|:|',
    del_pcs      '|:|',
    del_flag     '|:|',
    ratecode     '|:|',
    servicetype  '|:|',
    zone         '|:|',
    billto       '|:|',
    discflag     '|:|',
    assoc        '|:|',
    discpct      '|:|',
    fixdiscpct   '|:|',
    entrydate    '|:|',
    sample	 '|:|',
    record_id	 '|:|\n'
)

from '/opt/sybase/bcp_data/cmf_data/cost_analysis_raw.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;
