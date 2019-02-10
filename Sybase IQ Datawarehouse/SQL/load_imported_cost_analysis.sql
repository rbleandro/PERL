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
    sample       '|:|',
    EA_charges   '|:|',
    fuel_charge  '|:|',
    fuel_rate    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/filename.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

declare @maxId numeric(30), @lastId numeric(30), @sample integer
  select @maxId = isnull(max(record_id),0) from cost_analysis_raw
  update cost_analysis_raw set
    record_id = @maxId+NUMBER(*) where
    record_id is null

select @sample = sample from cost_analysis_raw where record_id = (@maxId+1)
exec run_recalc @sample,param0,param1,param2,param3

