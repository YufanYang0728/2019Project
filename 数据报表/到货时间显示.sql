alter proc CGRKQK



as
begin

--select * from ICTransType
--select * from t_TableDescription where FDescription like '%销售订单%'
--select * from t_FieldDescription where  FTableID=230004 and FDescription like '%制单%'
select a.FInterID,b.FItemID orderwl,c.FName GYS,a.FBillNo orderbillno,convert(varchar(10),a.FDate ,120) DDRQ
,d.FNumber,d.FName WL,d.FModel,cast(isnull(b.FQty,'') as varchar(100)) orderqty,convert(varchar(10),b.FDate ,120) JHRQ,
cast(case when b.FQty-b.FStockQty>=0 then b.FQty-b.FStockQty else 0 end  as varchar(100))Funstockqty
,b.FEntryID orderFEntryID
into #order                                                       
from POOrder a
inner join POOrderEntry b on a.FInterID=b.FInterID
left join  t_Supplier c on a.FSupplyID=c.FItemID
left join t_ICItem d on b.FItemID=d.FItemID

select isnull(a.FBillNo,'') stockbillno,isnull(b.FSourceInterId,'')FSourceInterId,isnull(b.FSourceBillNo,'')FSourceBillNo,
convert(varchar(10),a.FDate ,120) stockdate,isnull(b.FItemID,'') stockwl,cast(isnull(b.FQty,'') as varchar(100)) stockqty,
isnull(b.FEntrySelfA0170,'') note1,isnull(b.FNote,'') note,b.FSourceTranType,b.FSourceEntryID,
a.FInterID stockfid,b.FEntryID stockentid
into #stock
from ICStockBill a 
inner join ICStockBillEntry b on a.FInterID=b.FInterID
where a.FTranType=1 


select b.*,a.FBillNo
into #pobill
from POInstock a 
inner join POInStockEntry b on a.FInterID=b.FInterID
where FSourceTranType=71


--select FInterID,orderFEntryID from #order where orderbillno='CGDD20181101'
--select FSourceInterId,FSourceEntryID from #pobill where FBillNo='DD000006'
--select FInterID,FEntryID from #pobill where FBillNo='DD000006'


--select FItemID from #pobill where FBillNo='DD000006'
select
--a.orderbillno,b.stockbillno,c.FBillNo,d.stockbillno postockbillno
 a.orderFEntryID c,c.FSourceEntryID d,c.FEntryID e,
d.stockwl postockwl,a.*,b.*
,d.stockbillno postockbillno,d.FSourceBillNo poFSourceBillNo,
d.stockdate postockdate,d.stockqty postockqty,
d.note1 ponote1,d.note poFNote
into #sub
from 
#order a 
left join #stock b on a.FInterID=b.FSourceInterId and a.orderFEntryID=b.FSourceEntryID and b.FSourceTranType=71
left join #pobill c on a.FInterID=c.FSourceInterId and a.orderFEntryID=c.FSourceEntryID
left join #stock d on c.FInterID=d.FSourceInterId and d.FSourceEntryID=c.FEntryID and d.FSourceTranType=72

--select * from #sub  where orderbillno='CGDD20181101'
  
---- select * from t_TableDescription where FDescription like '%领料%'

------  CGRKQK

select 
IDENTITY(int,1,1) findex,
ROW_NUMBER() OVER(PARTITION BY FInterID,orderFEntryID ORDER BY FInterID,orderFEntryID,stockentid) fwlno,
ROW_NUMBER() OVER(PARTITION BY orderbillno ORDER BY FInterID,orderFEntryID,stockentid) fbnno,
* 
into #summary
from #sub 

update a set GYS='',orderbillno='',DDRQ='' from  #summary a where fbnno<>1
update  a set WL='',FModel='',FNumber='',orderqty='',Funstockqty='',JHRQ='' from  #summary a where fwlno<>1
----  CGRKQK

select orderbillno 采购单号,GYS 供应商,DDRQ 订单日期,FNumber 物料编号,WL 物料名称,FModel 规格型号
,orderqty 订货数量,JHRQ 交货日期,Funstockqty 未入库数量
,case when stockfid is null then isnull(postockdate,'') else isnull(stockdate,'') end 入库日期,
case when stockfid is null then isnull(postockqty,'') else  isnull(stockqty,'') end 入库数量,
case when stockfid is null then isnull(postockbillno,'') else  isnull(stockbillno,'') end 入库单号,
case when stockfid is null then  isnull(poFSourceBillNo,'') else isnull(FSourceBillNo,'') end 源单编号,
case when stockfid is null then isnull(poFNote,'') else isnull(note,'') end 备注,
case when stockfid is null then isnull(ponote1,'') else isnull(note1,'') end  备注1
--into #result
from #summary  order by findex

drop table #stock
drop table #order
drop table #summary
drop table #pobill
drop table #sub

end 