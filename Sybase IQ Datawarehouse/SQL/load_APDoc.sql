truncate table APDoc;
LOAD into table APDoc
(
    Acct           '|:|',
    AddlCost       '|:|',
    ApplyAmt       '|:|',
    ApplyDate      '|:|',
    ApplyRefNbr    '|:|',
    BatNbr         '|:|',
    BatSeq         '|:|',
    CashAcct       '|:|',
    CashSub        '|:|',
    ClearAmt       '|:|',
    ClearDate      '|:|',
    CpnyID         '|:|',
    Crtd_DateTime  '|:|',
    Crtd_Prog      '|:|',
    Crtd_User      '|:|',
    CurrentNbr     '|:|',
    CuryDiscBal    '|:|',
    CuryDiscTkn    '|:|',
    CuryDocBal     '|:|',
    CuryEffDate    '|:|',
    CuryId         '|:|',
    CuryMultDiv    '|:|',
    CuryOrigDocAmt '|:|',
    CuryPmtAmt     '|:|',
    CuryRate       '|:|',
    CuryRateType   '|:|',
    CuryTaxTot00   '|:|',
    CuryTaxTot01   '|:|',
    CuryTaxTot02   '|:|',
    CuryTaxTot03   '|:|',
    CuryTxblTot00  '|:|',
    CuryTxblTot01  '|:|',
    CuryTxblTot02  '|:|',
    CuryTxblTot03  '|:|',
    Cycle          '|:|',
    DfltDetail     '|:|',
    DirectDeposit  '|:|',
    DiscBal        '|:|',
    DiscDate       '|:|',
    DiscTkn        '|:|',
    Doc1099        '|:|',
    DocBal         '|:|',
    DocClass       '|:|',
    DocDate        '|:|',
    DocDesc        '|:|',
    DocType        '|:|',
    DueDate        '|:|',
    Econfirm       '|:|',
    Estatus        '|:|',
    InstallNbr     '|:|',
    InvcDate       '|:|',
    InvcNbr        '|:|',
    LCCode         '|:|',
    LineCntr       '|:|',
    LUpd_DateTime  '|:|',
    LUpd_Prog      '|:|',
    LUpd_User      '|:|',
    MasterDocNbr   '|:|',
    NbrCycle       '|:|',
    NoteID         '|:|',
    OpenDoc        '|:|',
    OrigDocAmt     '|:|',
    PayDate        '|:|',
    PayHoldDesc    '|:|',
    PC_Status      '|:|',
    PerClosed      '|:|',
    PerEnt         '|:|',
    PerPost        '|:|',
    PmtAmt         '|:|',
    PmtID          '|:|',
    PmtMethod      '|:|',
    PONbr          '|:|',
    PrePay_RefNbr  '|:|',
    ProjectID      '|:|',
    RecordID       '|:|',
    RefNbr         '|:|',
    Retention      '|:|',
    RGOLAmt        '|:|',
    Rlsed          '|:|',
    S4Future01     '|:|',
    S4Future02     '|:|',
    S4Future03     '|:|',
    S4Future04     '|:|',
    S4Future05     '|:|',
    S4Future06     '|:|',
    S4Future07     '|:|',
    S4Future08     '|:|',
    S4Future09     '|:|',
    S4Future10     '|:|',
    S4Future11     '|:|',
    S4Future12     '|:|',
    Selected       '|:|',
    Status         '|:|',
    Sub            '|:|',
    TaxCntr00      '|:|',
    TaxCntr01      '|:|',
    TaxCntr02      '|:|',
    TaxCntr03      '|:|',
    TaxId00        '|:|',
    TaxId01        '|:|',
    TaxId02        '|:|',
    TaxId03        '|:|',
    TaxTot00       '|:|',
    TaxTot01       '|:|',
    TaxTot02       '|:|',
    TaxTot03       '|:|',
    Terms          '|:|',
    TxblTot00      '|:|',
    TxblTot01      '|:|',
    TxblTot02      '|:|',
    TxblTot03      '|:|',
    User1          '|:|',
    User2          '|:|',
    User3          '|:|',
    User4          '|:|',
    User5          '|:|',
    User6          '|:|',
    User7          '|:|',
    User8          '|:|',
    VendId         '\n'
)

from '/opt/sybase/bcp_data/cmf_data/APDoc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

