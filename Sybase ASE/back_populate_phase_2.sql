use cpscan
go
set nocount on
declare @cur_id numeric(10), @nxt_id numeric(10), @pctd  datetime, @pen char(6)
        ,@cnt int,@prv_cnt int, @rowsfound int, @shipper_num char(8), @pa_ship_num char(8),
        @pa_ref_num char(13), @pa_serv_type char(1)

select @cur_id = 1

select @cnt=0, @prv_cnt = 1000000
while (@cur_id <> @nxt_id)
BEGIN
    select  @pctd = pt.pickup_conv_time_date, 
            @pen = pt.pickup_employee_num, 
            @pa_ref_num = pt.reference_num,
            @pa_serv_type = pt.service_type,
            @pa_ship_num = pt.shipper_num
    from pa_temp pt
    where pt.id_col = @cur_id

    select @rowsfound = count(*) from tttl_ps_pickup_shipper ps
    where ps.conv_time_date = @pctd and
          ps.employee_num = @pen
    if (@rowsfound > 1)
    BEGIN
    select "More than one row found for employee_num: "+ @pen + " and conv_time_date: "+ convert(varchar,@pctd,109)
    goto NEXT_REC
    END

    if (@cnt = @prv_cnt)
        BEGIN
            dump tran cpscan with truncate_only
            select @prv_cnt = @prv_cnt + 1000000
            if (@cnt = 30000000)
            BEGIN
               BREAK
            END
        END
        
        select @shipper_num = shipper_num from tttl_ps_pickup_shipper ps
        where   ps.conv_time_date = @pctd and
                ps.employee_num = @pen
        

        update tttl_pa_parcel
        set pickup_shipper_num = @shipper_num
        where reference_num = @pa_ref_num and
              service_type = @pa_serv_type and
              shipper_num = @pa_ship_num

        if @@rowcount = 1
        BEGIN
        select "Working On: "+@pa_ref_num+","+@pa_serv_type+","+@pa_ship_num+","+convert(varchar,@cnt)
        select @cnt = @cnt + 1
        END

    NEXT_REC:
    select @nxt_id = @cur_id
    set rowcount 1
    select @cur_id = id_col
    from pa_temp
    where   id_col > @nxt_id
    set rowcount 0

END
go
