-- ASE DDL Generator Utility/16.0/EBF 28334/S/1.6.0/ase160sp03pl06x/Tue Dec 25 23:13:07 PST 2018 ASE DDL Generator Utility/SP03/EBF 28334/S/1.6.0/ase160sp03pl06x/Tue Dec 25 23:13:07 PST 2018 ASE DDL Generator Utility/PL06/EBF 28334/S/1.6.0/ase160sp03pl06x/Tue Dec 25 23:13:07 PST 2018


-- Confidential property SAP AG or an SAP affiliate company. 
-- Copyright 2001, 2014 
-- SAP AG or an SAP affiliate company.  All rights reserved. 
-- Unpublished rights reserved under U.S. copyright laws. 
-- This software contains confidential and trade secret information of SAP AG or 
-- an SAP affiliate company.  Use, duplication or disclosure of the software and 
-- documentation by the U.S. Government is subject to restrictions set forth in 
-- a license agreement between the Government and SAP AG or an SAP affiliate 
-- company, or other written agreement specifying the Government's rights to use 
-- the software and any applicable FAR provisions, for example, FAR 52.227-19.


-- DDLGen started with the following arguments
-- -Usa -P*** -TU -Ntttl_ma_shipment -Dcpscan -SCPDB1 -O/opt/sap/cron_scripts/tttl_ma_shipment.sql 
-- at 09/02/20 21:33:10 EDT



-----------------------------------------------------------------------------
-- DDL for Table 'cpscan.dbo.tttl_ma_shipment'
-----------------------------------------------------------------------------
print '<<<<< CREATING Table - "cpscan.dbo.tttl_ma_shipment" >>>>>'
go

use cpscan
go 

setuser 'dbo'
go 

IF EXISTS (SELECT 1 FROM sysobjects o, sysusers u WHERE o.uid=u.uid AND o.name = 'tttl_ma_shipment' AND u.name = 'dbo' AND o.type = 'U')
	drop table tttl_ma_shipment

IF (@@error != 0)
BEGIN
	PRINT 'Error CREATING table "cpscan.dbo.tttl_ma_shipment"'
	SELECT syb_quit()
END
go

create table tttl_ma_shipment (
	manlink                         int                              not null,
	shipment_id                     int                              not null,
	pieces                          tinyint                          not null,
	weight                          decimal(5,1)                     not null,
	spec_inst                       char(40)                         not null,
	cust_reference                  varchar(40)                      not null,
	cost_centre                     varchar(40)                      not null,
	order_number                    varchar(40)                      not null,
	service_code                    tinyint                          not null,
	total_charges                   smallmoney                       not null,
	DV_charges                      smallmoney                       not null,
	DV_amount                       smallmoney                       not null,
	PUT_charges                     smallmoney                       not null,
	XC_charges                      smallmoney                       not null,
	HST                             smallmoney                       not null,
	GST                             smallmoney                       not null,
	QST                             smallmoney                       not null,
	zone                            tinyint                          not null,
	cons_account                    varchar(15)                      not null,
	cons_name                       varchar(40)                      not null,
	cons_address1                   varchar(40)                      not null,
	cons_address2                   varchar(40)                      not null,
	cons_address3                   varchar(40)                      not null,
	cons_city                       varchar(30)                      not null,
	cons_prov                       char(2)                          not null,
	cons_postal                     varchar(10)                      not null,
	cons_attention                  varchar(30)                      not null,
	xc_pieces                       tinyint                          not null,
	min_weight_flag                 bit                              not null,
	NSR_flag                        bit                              not null,
	estimated_del_date              smalldatetime                        null,
	EA_charges                      smallmoney                      DEFAULT  0

  not null,
	consignee_email                 varchar(50)                     DEFAULT  ' '
  not null,
	sa_resi_flag                    char(1)                         DEFAULT  ' '
  not null,
	sa_resi_charge                  smallmoney                      DEFAULT  0
  not null,
	enh_service                     char(1)                         DEFAULT  ' '

  not null,
	pd_flag                         char(1)                         DEFAULT  " "
  not null,
	pd_charge                       smallmoney                      DEFAULT  0
  not null,
	cos_flag                        char(1)                         DEFAULT  " "
  not null,
	cos_charge                      smallmoney                      DEFAULT  0
  not null,
	dg_flag                         char(1)                         DEFAULT  " "
  not null,
	dg_charge                       smallmoney                      DEFAULT  0
  not null,
	rural_charge                    smallmoney                      DEFAULT  0
  not null,
	country                         char(2)                         DEFAULT  " "

  not null,
	dhl_extract                     char(1)                         DEFAULT  ' ' 
  not null,
	inserted_on_cons                datetime                        DEFAULT  'Jan 01 1900' 
  not null,
	updated_on_cons                 datetime                        DEFAULT  'Jan 01 1900' 
  not null,
		CONSTRAINT tttl_ma_sidx UNIQUE NONCLUSTERED ( manlink, shipment_id )  on 'default' 
)
lock datapages
with dml_logging = full
 on 'default'
go 

Grant Select on dbo.tttl_ma_shipment to public Granted by dbo
go
Grant Delete Statistics on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Truncate Table on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Update Statistics on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Transfer Table on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Insert on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Delete on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant References on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Select on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Update on dbo.tttl_ma_shipment to cust_serv Granted by dbo
go
Grant Insert on dbo.tttl_ma_shipment to developers Granted by dbo
go
Grant Delete on dbo.tttl_ma_shipment to developers Granted by dbo
go
Grant References on dbo.tttl_ma_shipment to developers Granted by dbo
go
Grant Select on dbo.tttl_ma_shipment to developers Granted by dbo
go
Grant Update on dbo.tttl_ma_shipment to developers Granted by dbo
go
Grant References on dbo.tttl_ma_shipment to developer_read Granted by dbo
go
Grant Select on dbo.tttl_ma_shipment to developer_read Granted by dbo
go

setuser
go 

-----------------------------------------------------------------------------
-- DDL for Index 'shp_order'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "shp_order" >>>>>'
go 

create nonclustered index shp_order 
on cpscan.dbo.tttl_ma_shipment(order_number, cons_postal)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'cons_postal_idx'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "cons_postal_idx" >>>>>'
go 

create nonclustered index cons_postal_idx 
on cpscan.dbo.tttl_ma_shipment(cons_postal, manlink, shipment_id)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'shp_ref'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "shp_ref" >>>>>'
go 

create nonclustered index shp_ref 
on cpscan.dbo.tttl_ma_shipment(cust_reference, cons_postal)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'dhl_extract_ndx'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "dhl_extract_ndx" >>>>>'
go 

create nonclustered index dhl_extract_ndx 
on cpscan.dbo.tttl_ma_shipment(dhl_extract)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'inserted_on_con_ndx'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "inserted_on_con_ndx" >>>>>'
go 

create nonclustered index inserted_on_con_ndx 
on cpscan.dbo.tttl_ma_shipment(inserted_on_cons)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'idx1'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "idx1" >>>>>'
go 

create nonclustered index idx1 
on cpscan.dbo.tttl_ma_shipment(cons_address1, cons_address2, cons_address3, cons_city, cons_prov, cons_postal, pieces)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'idx2'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "idx2" >>>>>'
go 

create nonclustered index idx2 
on cpscan.dbo.tttl_ma_shipment(estimated_del_date, cos_flag)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'shp_costc'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "shp_costc" >>>>>'
go 

create nonclustered index shp_costc 
on cpscan.dbo.tttl_ma_shipment(cost_centre, cons_postal)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Index 'idx3'
-----------------------------------------------------------------------------

print '<<<<< CREATING Index - "idx3" >>>>>'
go 

create nonclustered index idx3 
on cpscan.dbo.tttl_ma_shipment(inserted_on_cons, dhl_extract, cons_postal)
with index_compression = none , index_hash_caching = default 
go 


-----------------------------------------------------------------------------
-- DDL for Trigger 'cpscan.dbo.tttl_ma_shipment_deletes_trg'
-----------------------------------------------------------------------------

print '<<<<< CREATING Trigger - "cpscan.dbo.tttl_ma_shipment_deletes_trg" >>>>>'
go 

setuser 'dbo'
go 

CREATE TRIGGER dbo.tttl_ma_shipment_deletes_trg
ON dbo.tttl_ma_shipment
FOR DELETE AS

insert tttl_ma_shipment_deletes
select manlink, shipment_id from deleted

delete tttl_ma_shipment_inserts
from tttl_ma_shipment_inserts ri, deleted rd
where   ri.shipment_id  = rd.shipment_id
and     ri.manlink      = rd.manlink
go 



alter table dbo.tttl_ma_shipment disable trigger dbo.tttl_ma_shipment_deletes_trg
go 

setuser
go 

-----------------------------------------------------------------------------
-- DDL for Trigger 'cpscan.dbo.tttl_ma_shipment_inserts_trg'
-----------------------------------------------------------------------------

print '<<<<< CREATING Trigger - "cpscan.dbo.tttl_ma_shipment_inserts_trg" >>>>>'
go 

setuser 'dbo'
go 

CREATE TRIGGER dbo.tttl_ma_shipment_inserts_trg
ON dbo.tttl_ma_shipment
FOR INSERT AS
BEGIN

 declare @cos_flag char(1)
 select @cos_flag = cos_flag from inserted

 if (@cos_flag = 'Y')
 begin
  insert COSInventory
  select service_type, reference_num, shipper_num, getdate()
  from tttl_ma_barcode b, inserted i
  where b.manlink = i.manlink and
          b.shipment_id = i.shipment_id 
  insert lmscan..COSInventory
  select service_type, reference_num, shipper_num, getdate()
  from tttl_ma_barcode b, inserted i
  where b.manlink = i.manlink and
          b.shipment_id = i.shipment_id 

 end
END
go 

setuser
go 

-----------------------------------------------------------------------------
-- DDL for Trigger 'cpscan.dbo.tttl_ma_shipment_updates_trg'
-----------------------------------------------------------------------------

print '<<<<< CREATING Trigger - "cpscan.dbo.tttl_ma_shipment_updates_trg" >>>>>'
go 

setuser 'dbo'
go 

CREATE TRIGGER dbo.tttl_ma_shipment_updates_trg
ON dbo.tttl_ma_shipment
FOR UPDATE AS

insert tttl_ma_shipment_deletes
select manlink, shipment_id from deleted

insert tttl_ma_shipment_inserts
select manlink, shipment_id from inserted
go 



alter table dbo.tttl_ma_shipment disable trigger dbo.tttl_ma_shipment_updates_trg
go 

setuser
go 


-- DDLGen Completed
-- at 09/02/20 21:33:11 EDT