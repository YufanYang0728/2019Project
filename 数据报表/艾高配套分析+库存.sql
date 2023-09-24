USE [AIS20181030152008]
GO
/****** Object:  StoredProcedure [dbo].[KCFX]    Script Date: 2019-07-20 17:40:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[KCFX]
 


 @itemno varchar(200),
 @pts0 int,
 @itemno1 varchar(200),
  @ptsl int,
 @itemno2 varchar(200),
   @pts2 int,
 @itemno3 varchar(200),
    @pts3 int ,
	 @itemno4 varchar(200),
 @pts4 int,
 @itemno5 varchar(200),
  @pts5 int,
 @itemno6 varchar(200),
   @pts6 int,
 @itemno7 varchar(200),
    @pts7 int ,
 @enddate varchar(200)




as begin 

--***********************************************************************************************************
  CREATE TABLE #StockList(FStockID INT) 
 INSERT INTO #StockList(FStockID) VALUES(279)
 INSERT INTO #StockList(FStockID) VALUES(281)
 INSERT INTO #StockList(FStockID) VALUES(282)
 INSERT INTO #StockList(FStockID) VALUES(283)
 INSERT INTO #StockList(FStockID) VALUES(284)
 INSERT INTO #StockList(FStockID) VALUES(4233)
 INSERT INTO #StockList(FStockID) VALUES(4452)



  create table #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (    FID  INT identity(1,1) ,
    FItemID int  NOT NULL,
    FCustBomInterID int DEFAULT(0),
    FOrderBomInterID int default(0),  --订单BOM
    FMTONo NVARCHAR(50) default(''),
    FSecInv decimal(28,10) default(0),
    FQtyInv decimal(28,10) default(0),
    FHighLimit  decimal(28,10) default(0),
    FErpClsId int ,
    FAuxPropID int default(0) ,
    FAuxInMrpCal int default(0) null,
    F01  int default(0),
    F02  int default(0),
    F03  int default(0),
    F04  int default(0),
    F05  int default(0))
 
Insert Into #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMTONo,FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
select T1.FItemID, 0 as FCustBomInterID,IsNull(t8.FMtoNo,'') as FMtoNo,IsNull(t1.FSecInv,0) as FSecInv,Isnull(t8.FQtyInv,0) ,t1.FHighLimit,t1.FErpClsId
,Case when t2.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,t2.FAuxInMrpCal
from t_ICItem T1
Inner join t_IcItemPlan t2 on t1.FItemID=t2.FItemID 
left join (
     Select v8.FItemID as FItemID, v8.FMtoNo, sum(v8.FQty) as FQtyInv,v8.FAuxPropID
         From (SELECT t1.FItemID,t1.FMtoNo,t1.FQty,t1.FStockID,case when t2.FAuxInMrpCal=1 then t1.FAuxPropID else 0 end as FAuxPropID  from ICInventory t1 inner join t_IcItemPlan t2 on t1.FItemID=t2.FItemID 
                 union all SELECT t1.FItemID,t1.FMtoNo,t1.FQty,t1.FStockID,case when t2.FAuxInMrpCal=1 then t1.FAuxPropID else 0 end as FAuxPropID  from POInventory  t1 inner join t_IcItemPlan t2 on t1.FItemID=t2.FItemID ) v8 
         inner join t_Stock v9 on v8.FStockID=v9.FItemID and v9.FTypeID<>501 --考虑赠品仓,代管仓,不考虑501待检仓 
         inner join #StockList v10 on v8.FStockID=v10.FStockID
         Where 1 = 1
         Group by v8.FItemID,v8.FAuxPropID,v8.FMtoNo,v8.FAuxPropID 
) t8 on t1.FItemID=t8.FItemID
where 1=1  AND (( t2.FAuxInMrpCal=1 AND ISNULL(t8.FAuxPropID,0) <>0 ) OR  t2.FAuxInMrpCal=0) and (t1.FNumber like '%%')
and t1.ferpclsid<>7


Union
select T1.FItemID,t8.FCustBomInterID as FCustBomInterID,Isnull(t8.FMtoNo,'') as FMtoNo , Isnull(t1.FSecInv,0) as FSecInv ,Isnull(t8.FQtyInv,0),t1.FHighLimit,t1.FErpClsId
,Case when t3.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,t3.FAuxInMrpCal
from t_ICItem T1
inner join icbom t2 on t1.FItemID=t2.FItemID and t2.FBomType=3 and FStatus=1
Inner join t_IcItemPlan t3 on t1.FItemID=t3.FItemID 
inner join (
     Select v8.FItemID as FItemID, IsNull(B.FCustBomID,0) as FCustBomInterID,v8.FMtoNo, sum(v8.FQty) as FQtyInv,v8.FAuxPropID
         From ICInventory v8 inner
         join t_Stock v9 on v8.FStockID=v9.FItemID
         inner JOIN (SELECT DISTINCT FItemID,FCustBOMID,FBatchNo FROM ICOrderBatchTrace WHERE FForbid=0) B ON V8.FBatchNo=B.FBatchNo and V8.FItemID=B.FItemID 
         inner join #StockList v10 on v8.FStockID=v10.FStockID
         Where 1 = 1
         Group by v8.FItemID, IsNull(B.FCustBomID,0), v8.FMtoNo,v8.FAuxPropID  
) t8 on t1.FItemID=t8.FItemID and t2.FInterID=t8.FCustBomInterID and t2.FAuxPropID=t8.FAuxPropID
Where 1=1  and (t1.FNumber like '%%')
and t1.ferpclsid=7



Insert Into #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMTONo, FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
select T1.FItemID, t8.FInterID as FCustBomInterID,'' as FMTONo, IsNull(t1.FSecInv,0) as FSecInv,0 as FQtyInv,t1.FHighLimit,t1.FErpClsId
,Case when t3.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,t3.FAuxInMrpCal
from t_ICItem T1
Inner join t_IcItemPlan t3 on t1.FItemID=t3.FItemID 
INNER JOIN ICBOM T8 ON t1.FItemID=t8.FItemID and t8.FBomType=3 and FStatus=1 
WHERE NOT EXISTS (SELECT 1 FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 WHERE T1.FItemID=V88.FItemID AND t8.FInterID=v88.FCustBomInterID AND V88.FMtoNo =''  and t8.FAuxPropID=CASE WHEN v88.FAuxInMrpCal=1 THEN v88.FAuxPropID ELSE t8.FAuxPropID END ) 
 and (t1.FNumber like '%%')
and t1.ferpclsid=7



Insert Into #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMtoNo,FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
select Distinct T1.FItemID, t8.FBomInterID as FCustBomInterID,Isnull(t8.FMtoNo,'') , IsNull(t1.FSecInv,0) as FSecInv,0 as FQtyInv,t1.FHighLimit,t1.FErpClsId
,Case when T1.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,T1.FAuxInMrpCal
from t_icitem T1
Inner Join (
Select Distinct U.FItemID,IsNull(V.FInterID,0) as FBomInterID,U.FMtoNo,U.FAuxPropID
From
(
    --销售订单
    SELECT Distinct v2.FItemID,v2.FBomInterID,v2.FMtoNo,v2.FAuxPropID as FAuxPropID FROM SeOrder v1
        Inner JOin SeOrderEntry v2 on v1.FInterID=v2.FInterID
        Where v2.FMtoNo <> ''
        and V1.FSaleStyle NOT IN (20296,20297) AND V1.FAreaPS<>20303
        And v2.FMrpclosed = 0
        --bCsdPlanSale 根据参数是否勾选“考虑未审核的销售订单”） --参考GetSaleWillOutSql函数
    --产品预测单
    --Union
    --计划订单
    Union
    SELECT Distinct v2.FItemID,case when v2.FBomCategory=36821 then ISNULL(v2.FBOM,0) else 0 end AS FBOM,v2.FMtoNo,ISNULL(v2.FAuxPropID,0) FROM ICMrpResult v2
        Where v2.FMtoNo <> '' And v2.FMrpclosed = 0AND FStatus = 1
    --采购订单
    Union
    SELECT Distinct v2.FItemID,0,v2.FMtoNo,v2.FAuxPropID as FAuxPropID From PoOrder v1
        Inner Join PoOrderEntry v2 On v1.FInterID=v2.FInterID
        Where v2.FMtoNo <> ''  And v2.FMrpclosed = 0
    --采购申请单
    Union
    SELECT Distinct v2.FItemID,case when v2.FBomCategory=36821 then ISNULL(v2.FBOMInterID,0) else 0 end AS FBOM,v2.FMtoNo,v2.FAuxPropID From PORequest v1
        Inner Join PORequestEntry v2 On v1.FInterID=v2.FInterID
        Where v2.FMtoNo <> ''  And v2.FMrpclosed = 0
        and (v1.FStatus > 0 OR (v1.FStatus = 0 AND V1.FPlanConfirmed=1))
        and v1.FCancellation = 0
    --生产任务单/委外加工任务单  确认、下达 考虑计划确认
    Union
    SELECT Distinct v2.FItemID,case when v2.FBomCategory=36821 then ISNULL(v2.FBOMInterID,0) else 0 end AS FBOM,v2.FMtoNo,ISNULL(v2.FAuxPropID,0) From ICMo V2
        Where v2.FMtoNo <> '' and v2.FMrpclosed = 0 and ( (v2.FStatus = 0 and v2.FPlanConfirmed=1) or v2.FStatus > 0) 
    --委外订单
    Union
    SELECT Distinct v2.FItemID,case when v2.FBomCategory=36821 then ISNULL(v2.FBOMInterID,0) else 0 end AS FBOM,v2.FMtoNo,ISNULL(v2.FAuxPropID,0) as FAuxPropID From ICSubContract v1
        Inner Join ICSubContractEntry v2 On v1.FInterID=v2.FInterID
        Where v2.FMtoNo <> ''  And v2.FMrpclosed = 0
        and v1.FStatus > 0
        and v1.FCancellation = 0
    --投料单
    Union
    SELECT Distinct v2.FItemID,v2.FBomInterID,v2.FMtoNo,ISNULL(v2.FAuxPropID,0) From PPBOM v1
        Inner Join PPBOMEntry v2 On V1.FInterID=v2.FInterID
        Where v2.FMtoNo <> '' --and  v1.FStatus > 0
) U
Left Join ICBom V On /*U.FItemID=V.FItemID and*/ U.FBomInterID=V.FInterID and v.FStatus>0 and  v.FBOMType=3
Where 1=1
) t8 On t1.FItemID=t8.FItemID 
WHERE NOT EXISTS (SELECT 1 FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 WHERE t8.FItemID=V88.FItemID AND t8.FBomInterID=v88.FCustBomInterID And t8.FMtoNo=v88.FMtoNo ) 
 and (t1.FNumber like '%%')



--考虑MTS物料没有库存，而MTO物料有库存的情况 ZhaiYC
INSERT INTO #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMTONo,FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
SELECT DISTINCT s.FItemID,s.FCustBomInterID,'' AS FMTONo,IsNull(t.FSecInv,0) as FSecInv,0 AS FQtyInv,t.FHighLimit,t.FERPClsID,s.FAuxPropID,s.FAuxInMrpCal
FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 s
INNER JOIN t_ICItemBase t ON t.FItemID=s.FItemID
LEFT JOIN (SELECT DISTINCT FItemID,FCustBOMInterID FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 WHERE FMTONO='') d ON d.FItemID=s.FItemID AND d.FCustBomInterID=s.FCustBomInterID
WHERE s.FMTONO<>'' AND d.FItemID IS NULL
--其他辅助属性--
Insert Into #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMTONo, FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
select T1.FItemID,0 as FCustBomInterID,'' as FMtoNo , Isnull(t1.FSecInv,0) as FSecInv ,0,t1.FHighLimit,t1.FErpClsId 
,Case when t1.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,t1.FAuxInMrpCal
from t_ICItem t1 
inner join ICItemAuxProp t8  on t1.FItemID=t8.FItemID WHERE NOT EXISTS (SELECT 1 FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 WHERE T1.FItemID=V88.FItemID and v88.FAuxPropID=Case when t1.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end and V88.FMTONo='' and V88.FCustBomInterID=0)
 and (t1.FNumber like '%%')
--跳层处理
Create TABLE #BomList (FInterID int )
Create TABLE #BomList2 (FInterID int,FItemID int,FFlag INT,FAuxPropID INT )
Create TABLE #BomSkipTable (FItemID int) --记录原来的物料范围
insert into #BomList(FInterID)
select u2.FInterID
from(
select u1.FInterID from ICBomChild u1 Inner Join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 t1 on u1.FItemID=t1.FItemID and t1.FAuxPropID = u1.FAuxPropID 
Union
select u1.FInterID from ICCustBomChild u1 Inner Join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 t1 on u1.FItemID=t1.FItemID and t1.FAuxPropID = u1.FAuxPropID
) u2 inner join icbom v1 on u2.FInterid=v1.Finterid and v1.FStatus=1
insert into #BomList2(FInterID,FItemID,FFlag,FAuxPropID)
select a.FinterID,b.FItemID,1,b.FAuxPropID from  #BomList a inner join ICBom b on a.finterid=b.FInterID and b.FBomSkip=1058
while exists(select 1 from #BomList2 where FFlag=1)
begin
      insert into #BomList(FinterID)
      select u1.FInterID
      from
      (
      select u1.FInterID from ICBomChild u1 Inner Join #BomList2 t1 on u1.FItemID=t1.FItemID and t1.FAuxPropID = u1.FAuxPropID  and t1.FFlag=1
        Union
      select u1.FInterID from ICCustBomChild u1 Inner Join #BomList2 t1 on u1.FItemID=t1.FItemID and t1.FAuxPropID = u1.FAuxPropID and t1.FFlag=1
      ) u1 inner join icbom v1 on u1.FInterid=v1.Finterid and v1.FStatus=1 
      where not exists(select 1 from #BomList c where c.FInterID=u1.FInterID)
      update  #BomList2 set FFlag=0
      insert into #BomList2(FInterID,FItemID,FFlag)
      select a.FinterID,b.FItemID,1 from  #BomList a inner join ICBom b on a.finterid=b.FInterID and b.FBomSkip=1058
      where not exists (select 1 from #BomList2 c where c.FInterID=a.FInterID)
end
Insert Into #BomSkipTable(FItemID)
select Distinct FItemID FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60
CREATE INDEX IX_BomSkipTable_FItem01 ON #BomSkipTable(FItemID)
Insert Into #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 (FItemID,FCustBomInterID,FMTONo, FSecInv,FQtyInv,FHighLimit,FErpClsId,FAuxPropID,FAuxInMrpCal)
select  Distinct T1.FItemID, 0 as FCustBomInterID,'' as FMTONo, IsNull(t1.FSecInv,0) as FSecInv,0 as FQtyInv,t1.FHighLimit,t1.FErpClsId
,Case when T1.FAuxInMrpCal=1 then ISNULL(t8.FAuxPropID,0) else 0 end as FAuxPropID,T1.FAuxInMrpCal
from t_ICItem T1
INNER JOIN ICBOM t8 ON t1.FItemID=t8.FItemID  and FStatus=1 
INNER JOIN #BomList T3 ON   t8.FInterID=t3.FInterID
WHERE NOT EXISTS (SELECT 1 FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 WHERE T1.FItemID=V88.FItemID and v88.FAuxPropID=t8.FAuxPropID )

   Create Table #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(
     FID  INT identity(1,1) PRIMARY KEY,
     FEntryID INT,
     FDataType int default(10) not null,    --数据类型：锁库量(1),预计量(10)，排序使用 
     FItemID int default(0)  not null,       --物料内码 
     FUnitID INT NULL,       --常用单位 
     FBeginDate datetime null, --需求开始日期
     FNeedDate datetime null, --需求日期
     FRelationTranType int default(0) not null,--相关单据类型 
     FRelationInterID int default(0) not  null, --相关单据内码 
     FRelationEntryID int default(0) not  null, --相关单据分录号 
     FBeginStockQty decimal(28,10) default(0) not null, --期初库存 
     FWillOutQty decimal(28,10) default(0) not  null, --已分配量 
     FWillInQty decimal(28,10) default(0) not  null, --预计入库 
     FTempQty decimal(28,10) default(0), --为方便计算例外信息代码  
     foldqty decimal(28,10) default(0), --为方便计算例外信息代码  
     FBillNo varchar(80) default('')  not null , --相关单据编号 
     FStatusName varchar(80) default('')  not null , --相关单据状态 
     FLockQty decimal(28,10) default(0) not null, --锁库量 
     FWillStockQty decimal(28,10) default(0) not null, --预计库存 
     FForSafeStock int default(0) not null, --为补充安全库存的计划订单即ICMRPResult.FMrpLockFlag=32则为－1，默认为0
     FBillType int default(0) not  null,
     fnote varchar(250) default(''), --单据排序类型 
     FAuxPropID int default(0),  --辅助属性 
     FCustBomInterID int default(0),   --客户BOM,通过ICOrderBatchTrace关联批号
     FOrderBomInterID int default(0),  --订单BOM
     FMTONo NVARCHAR(50) default('')   --MTO跟踪号
    ,FExceptionCode INT                   --单据例外信息代码（关联辅助资料t_SubMessage） 
    ,FExpNote NVARCHAR(1000) default('')  --例外信息详细描述
    ,FAdjustDays int   NULL  --业务提前或者延后的天数 
    ,FWillAdjQty decimal(23,10) NULL  --建议调整数量
    ,FAdjustBeginDate  DATETIME NULL  --建议采购/开工日期
    ,FAdjustEndDate    DATETIME NULL  --建议到货/完工日期
    ,FAdjustPrevCount INT  NULL default(0) --10，11，15，20 预计量单据被调整的次数 
 )
-----插入销售订单  
  insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,FForSafeStock
        ,FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
  select 1,t1.FItemID,u1.FUnitID,u1.FAdviceConsignDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end, u1.FEntryID,-2 AS FForSafeStock
        ,0,0,0,t1.FQty,0,-8 as FBillType,u1.FAuxPropID,case when ISNULL(tb.FTranType,0)<>51 then Isnull(u1.FBomInterID,0) else 0 end,u1.FMTONo 
   from t_LockStock t1 WITH(NoLock) inner join SEOrder v1 WITH(NoLock) on t1.FInterID=v1.FInterID and t1.FTranType=81 
   inner join SEOrderEntry u1 WITH(NoLock) on t1.FEntryID=u1.FEntryID and t1.FInterID=u1. FInterID left join vw_BomList tb on tb.FInterID = u1.FBomInterID 
   inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  u1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end and (u1.FBomInterID=v88.FCustBomInterID or (u1.FBomInterID>0 and ISNULL(tb.FTranType,0)=51))  and u1.FMTONo=v88.FMTONo 
   --Left Join ICBom u2 on u1.FBomInterID=u2.FInterID and u2.FBomtype=3 
   inner join t_Stock t2 WITH(NoLock) on t1.FStockID=t2.FItemID
         and t2.FMRPAvail=1 and t1.FQty>0
-----插入生产投料单(锁单)  
  insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,FForSafeStock
      ,FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
      select 1,t1.FItemID,u1.FUnitID,u1.FSendItemDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,u1.FEntryID,-2 AS FForSafeStock
      ,0,0,0,t1.FQty,0,case when v1.FOrderEntryID>0  then -6 else -5 end  as FBillType,ISNULL(u1.FAuxPropID,0) as FAuxPropID , Isnull(u1.FBomInterID,0) as FCustBomInterID,u1.FMTONo 
  from t_LockStock t1 WITH(NoLock) inner join PPBOM v1 WITH(NoLock) on t1.FInterID=v1.FInterID and t1.FTranType=88 
  inner join PPBOMEntry u1 WITH(NoLock) on t1.FInterID=u1.FInterID and t1.FEntryID=u1.FEntryID
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  u1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end  AND U1.FBomInterID=v88.FCustBomInterID  and u1.FMTONo=v88.FMTONo 
  --Left Join ICBom u2 on u1.FBomInterID=u2.FInterID and u2.FBomtype=3 
  inner join t_Stock t2 WITH(NoLock) on t1.FStockID=t2.FItemID
       and t2.FMRPAvail=1 and t1.FQty>0
-----第三步:插入预计入库单据  
-----插入生产任务单  
  Insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
     FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo )
  select 10,v1.FItemID,v1.FUnitID,t1.FBeginDate,t1.FNeedDate,case when v1.FTranType = 85 AND V1.FType=1067 then 85 when v1.FTranType = 85 AND V1.FType=11060 then 85 else v1.FTranType end,
    v1.FInterID,v1.FBillNo,Case v1.FStatus when 0 then '计划' when 3 then '结案' when 5 then '确认' Else '下达' end,0,
    0,t1.FWillQty,0,0,0,case when v1.FTranType = 85 AND V1.FType=1067 then 2 when v1.FTranType = 85 AND V1.FType=11060 then 9 else 1 end as FBillType
, v1.FAuxPropID, v88.FCustBomInterID,v88.FMTONo 
  from (select v1.FTranType ,v1.FInterID FInterID,v1.FBillNo,v1.FStatus,1 as FEntryID ,v1.FItemID as FItemID,v1.FAuxPropID, V1.FPlanCommitDate FBeginDate,v1.FPlanFinishDate FNeedDate,v1.FQty, v1.FStockqty, (case when v1.FQty > v1.FStockQty + isnull(v1.FReleasedQty,0) then (v1.FQty - v1.FStockQty -  isnull(v1.FReleasedQty,0) ) else 0 end ) FWillQty 
,v1.FMTONo,v1.FPlanCategory 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0 THEN 36820 ELSE v1.FBomCategory END) AS FBomCategory 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN ISNULL(T2.FInterID,0)  ELSE 0 END) AS FOrderBOMInterID 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN v1.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0  THEN ISNULL(t3.FInterID,0)  ELSE (CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0)> 0  THEN 0 ELSE  v1.FBOMInterID END ) END) AS FBOMInterID
 From ICMO v1 with (nolock) 
 LEFT JOIN ICOrderBOM T2 ON v1.FBOMInterID=T2.FInterID AND v1.FBomCategory = 36822  AND T2.FOrderBOMStatus = 36832 
 LEFT JOIN ICBOM t3 ON v1.FItemID=t3.FItemID AND v1.FAuxPropID=t3.FAuxPropID AND t3.FBOMType<>3 AND t3.FUseStatus=1072 
 Where v1.FCancellation = 0 and v1.FMrpClosed = 0  and v1.FQty > v1.FStockQty + isnull(v1.FReleasedQty,0) 
 and (  v1.FPlanFinishDate >= '2019-06-12' ) and v1.FMrpclosed = 0 and ((v1.FStatus = 0 and v1.FPlanConfirmed=1 ) or v1.FStatus >0) ) t1 inner join ICMO v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  Left join icbom T2 WITH(NoLock) ON  V1.FBOMINTERID=T2.FINTERID AND T2.FBOMTYPE=3 
  Inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  v1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end  and  Isnull(T2.Finterid,0)= v88.FCustBomInterID  and v1.FMTONo=v88.FMTONo   --考虑客户BOM 
  where 1=1 and v1.FTranType <> 54 
-----重复生产计划单  
 insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
    FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo )
 select 10,v1.FItemID,v1.FUnitID,t1.FBeginDate,t1.FNeedDate, v1.FTranType ,
   v1.FInterID,v1.FBillNo,Case v1.FStatus when 0 then '计划' when 1 then '审核' Else '关闭' end,0,
   0,t1.FWillQty,0,0,0,10 as FBillType
, v1.FAuxPropID, IsNull(v88.FCustBomInterID,0),v88.FMTONo 
 from (select v1.FTranType ,v1.FInterID FInterID,v1.FBillNo,v1.FStatus,1 as FEntryID ,v1.FItemID as FItemID,v1.FAuxPropID, V1.FPlanCommitDate FBeginDate,v1.FPlanFinishDate FNeedDate,v1.FQty, v1.FStockqty, (case when v1.FQty > v1.FStockQty + isnull(v1.FReleasedQty,0) then (v1.FQty - v1.FStockQty -  isnull(v1.FReleasedQty,0) ) else 0 end ) FWillQty 
,v1.FMTONo,v1.FPlanCategory 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0 THEN 36820 ELSE v1.FBomCategory END) AS FBomCategory 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN ISNULL(T2.FInterID,0)  ELSE 0 END) AS FOrderBOMInterID 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN v1.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID 
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0  THEN ISNULL(t3.FInterID,0)  ELSE (CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0)> 0  THEN 0 ELSE  v1.FBOMInterID END ) END) AS FBOMInterID
 From ICMO v1 with (nolock) 
 LEFT JOIN ICOrderBOM T2 ON v1.FBOMInterID=T2.FInterID AND v1.FBomCategory = 36822  AND T2.FOrderBOMStatus = 36832 
 LEFT JOIN ICBOM t3 ON v1.FItemID=t3.FItemID AND v1.FAuxPropID=t3.FAuxPropID AND t3.FBOMType<>3 AND t3.FUseStatus=1072 
 Where v1.FCancellation = 0 and v1.FMrpClosed = 0  and v1.FQty > v1.FStockQty + isnull(v1.FReleasedQty,0) 
 and (  v1.FPlanFinishDate >= '2019-06-12' ) and v1.FMrpclosed = 0 and ((v1.FStatus = 0 and v1.FPlanConfirmed=1 ) or v1.FStatus >0) ) t1 inner join ICMO v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  Left join icbom T2 WITH(NoLock) ON  V1.FBomInterID=T2.FInterID AND T2.FBomtype=3 
 inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  v1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and v1.FMTONo=v88.FMTONo 
 where 1=1 and v1.FTranType = 54 
-----插入委外加工生产任务单  
  Insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
     FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo )
  select DISTINCT 10,u1.FItemID,u1.FUnitID,t1.FBeginDate,t1.FNeedDate,t1.FTranType ,
    v1.FInterID,v1.FBillNo,Case when v1.FStatus=0 then '计划' WHEN u1.FMRPClosed=1 THEN '行业务关闭' WHEN v1.FClosed=1 THEN '关闭' ELSE '审核' end,u1.FEntryID,
    0,t1.FWillQty,0,0,0,2 as FBillType
, u1.FAuxPropID, v88.FCustBomInterID,v88.FMTONo 
  from (select v1.FClassTypeID as FTranType ,v1.FInterID FInterID,v1.FBillNo,v1.FStatus,u1.FEntryID as FEntryID ,u1.FItemID as FItemID,(tip.FAuxInMrpCal*u1.FAuxPropID)  AS FAuxPropID, u1.FPayShipDate as FBeginDate,u1.FFetchDate FNeedDate,u1.FQty, u1.FStockqty, (case when u1.FQty > u1.FStockQty  then (u1.FQty - u1.FStockQty ) else 0 end ) FWillQty 
,u1.FMTONo,v1.FPlanCategory 
,(CASE WHEN u1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0 THEN 36820 ELSE u1.FBomCategory END) AS FBomCategory
,(CASE WHEN u1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN ISNULL(T2.FInterID,0)  ELSE 0 END) AS FOrderBOMInterID 
,(CASE WHEN u1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN u1.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID 
,(CASE WHEN u1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) = 0 THEN ISNULL(t3.FInterID,0) ELSE (CASE WHEN u1.FBomCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN 0 ELSE u1.FBOMInterID END) END) AS FBOMInterID
 From ICSubContract v1 with (nolock) 
 inner join ICSubContractEntry u1 with (nolock) on v1.FInterID=u1.FInterID And v1.FInterID > 0 
 LEFT JOIN ICOrderBOM T2 ON u1.FBOMInterID=T2.FInterID AND u1.FBomCategory = 36822  AND T2.FOrderBOMStatus = 36832 
 LEFT JOIN ICBOM t3 ON u1.FItemID=t3.FItemID AND u1.FAuxPropID=t3.FAuxPropID AND t3.FBOMType<>3 AND t3.FUseStatus=1072 
 INNER JOIN  t_ICItemPlan tip ON u1.FItemID=tip.FItemID
 Where v1.FCancellation = 0 and u1.FMrpClosed = 0  and u1.FQty > u1.FStockQty 
 and (  u1.FFetchDate >= '2019-06-12' ) and u1.FMrpclosed = 0 and v1.FStatus > 0) t1 
  inner join ICSubContract v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  inner join ICSubContractEntry u1 WITH(NoLock) on t1.FInterID=u1.FInterID and t1.FEntryID=u1.FEntryID 
  Left join icbom T2 WITH(NoLock) ON  u1.FBOMINTERID=T2.FINTERID AND T2.FBOMTYPE=3 
  Inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  u1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end  and  Isnull(T2.Finterid,0)= v88.FCustBomInterID  and u1.FMTONo=v88.FMTONo    --考虑客户BOM 
  where 1=1 
-----插入投料单预计入库(联副产品，等级品)  
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
    FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,v2.FUnitID,t1.FBeginDate,t1.FNeedDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,t1.FEntryID,
    0,t1.FWillQty,0,0,0,3 as FBillType, v2.FAuxPropID as FAuxPropID, Isnull(t2.FInterID,0) as FCustBomInterID,v88.FMTONo 
 from (select u1.FTranType ,u1.FInterID as FInterID,u1.FBillNo FBillNo,u1.FStatus, u2.FEntryID as FEntryID,u2.FItemID as FItemID,u2.FAuxPropID      ,u2.FSendItemDate FBeginDate,u2.FSendItemDate FNeedDate,u2.FQtyMust FQty,u2.FStockQty FStockQty,(case when u2.FQtyMust > u2.FStockqty then u2.FQtyMust - u2.FStockQty else 0 end ) FWillQty 
     ,u2.FMTONo,v1.FPlanCategory 
     ,CASE WHEN u2.FOrderBOMInterID>0 THEN 36822 ELSE 0 END AS FBomCategory
     ,u2.FOrderBOMInterID,u2.FOrderBOMEntryID
     ,(CASE WHEN u2.FBOMInterID > 0 THEN u2.FBOMInterID ELSE 0 END) AS FBOMInterID
 From ICMO v1 with (nolock)
     Inner Join PPBOM u1 with (nolock) on u1.FICMOInterID = v1.FInterID 
     Inner join PPBOMEntry u2 with (nolock) on u1.fInterId = u2.FInterID and u2.FMTONo=v1.FMTONo 
      LEFT JOIN ICOrderBOMChild S1 with (nolock) ON S1.FInterID = u2.FOrderBOMInterID AND S1.FEntryID = u2.FOrderBOMEntryID 
 Where v1.FCancellation = 0 
 and v1.FMrpClosed = 0 
     
 and u2.FQtyMust > u2.FStockQty and (u2.FMaterielType=372 or u2.FMaterielType=373) 
 and (  u2.FSendItemDate >= '2019-06-12' ) and v1.FMrpclosed = 0  and ((v1.FStatus = 0 and (v1.FMrp=1052 or v1.FMrp=1053 or v1.FMrp=11078 or v1.FMrp=11084)) 
 or (v1.FStatus >0  ))) t1 
    inner join PPBOM v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
    inner join PPBOMEntry v2 WITH(NoLock) on t1.FInterID = v2.FInterID AND t1.FEntryID=v2.FEntryID 
    Left Join ICBom t2 WITH(NoLock) on v2.FBomInterID=t2.FInterID and t2.FBomtype=3 
    inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  v2.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v2.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and v2.FMTONo=v88.FMTONo 
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,FUnitID,
    FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo )
 select 10,v1.FItemID,t1.FBeginDate,t1.FNeedDate,v1.FTranType,
    v1.FInterID,v1.FBillNo,case v1.FStatus when 0 then '计划' when 3 then '关闭' else '审核' end ,0,v1.FUseUnitID,
    0,t1.FWillQty,0,0,0,15 as FBillType
, v1.FAuxPropID, IsNull(t2.FInterID,0),v88.FMTONo 
 from (SELECT v1.FTranType ,v1.FPlanOrderInterID FInterID,v1.FPlanOrderNo FBillNo,v1.FStatus,1 as FEntryID ,v1.FItemID as FItemID,v1.FAuxPropID, V1.FPlanBeginDate FBeginDate,v1.FPlanEndDate FNeedDate,v1.FPlanQty FQty, v1.FReleasedQty FStockqty, (case when v1.FPlanQty > v1.FHaveOrderQty then (v1.FPlanQty - v1.FHaveOrderQty) else 0 end ) FWillQty 
,v1.FMTONo,v1.FPlanCategory 
,(CASE WHEN V1.FBOMCategory = 36822 AND ISNULL(T2.FInterID,0) = 0  THEN 36820 ELSE V1.FBOMCategory END) AS FBOMCategory
,(CASE WHEN V1.FBOMCategory = 36822 AND ISNULL(T2.FInterID,0) >0   THEN  V1.FBOM ELSE 0 END) AS  FOrderBOMInterID
,(CASE WHEN V1.FBOMCategory = 36822 AND ISNULL(T2.FInterID,0) >0   THEN  V1.FOrderBOMEntryID ELSE 0 END) AS  FOrderBOMEntryID
,(CASE WHEN V1.FBOMCategory = 36822 AND ISNULL(T2.FInterID,0) = 0  THEN ISNULL(t3.FInterID,0)  ELSE (CASE WHEN V1.FBOMCategory = 36822 AND ISNULL(T2.FInterID,0) > 0 THEN 0 ELSE   v1.FBOM END)  END) AS FBOMInterID
 From ICMrpResult v1 with (nolock) left join ICMrpInfo v2 with (nolock) on v1.FRunID = v2.FInterID and (v2.FType = 0 or v2.FType = 1 or v2.FType = 4) 
 LEFT JOIN ICOrderBOM T2 ON  V1.FBOM=T2.FInterID AND V1.FBOMCategory = 36822 AND T2.FOrderBOMStatus = 36832 
 LEFT JOIN ICBOM t3 ON v1.FItemID=t3.FItemID AND v1.FAuxPropID=t3.FAuxPropID AND t3.FBOMType<>3 AND t3.FUseStatus=1072 
 Where 1=1 and ((v1.FIsAPS=1 AND v1.FType=4 AND v1.FRunID=0) OR v1.FIsAPS=0 )  and v1.FPlanQty > v1.FHaveOrderQty 
 AND v1.FStatus = 1  and (  v1.FPlanEndDate >= '2019-06-12' )) t1 inner join ICMrpResult v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  Left Join ICBom t2 WITH(NoLock) on v1.FBOM=t2.FInterID and t2.FBomtype=3 
 inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  v1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and v1.FMTONo=v88.FMTONo 
 where 1=1
-----物料替代清单预计入库  V12龙工专项 Add By lihaisheng 
INSERT INTO #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
   FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo )
SELECT 10,V1.FItemID,U1.FNeedDate,U1.FClassTypeID,U1.FID,U1.FBillNo
    ,Case U1.FStatus WHEN 0 THEN '计划' WHEN 1 THEN '审核' WHEN 3 THEN '手工关闭' ELSE '业务关闭' END
    ,V1.FIndex,0
    ,ISNULL((V1.FRelNeedQty - V1.FPPBOMSelQty),0)
 ,0,0,0,16 as FBillType,v1.FAuxPropID,0 as FCustBomInterID,v88.FMTONo 
  FROM ICSubsItemBill U1 WITH(NoLock) INNER JOIN ICSubsItemBillEntry V1 WITH(NoLock) ON U1.FID = V1.FID
        INNER JOIN #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 ON V1.FItemID = V88.FItemID and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end AND V88.FCustBomInterID = 0 AND U1.FMTONo = V88.FMTONo 
 WHERE V1.FDataType = 1058 AND U1.FStatus = 1 AND NOT EXISTS(SELECT 1 FROM ICSubsItemBillEntry T1 WHERE T1.FID = V1.FID AND T1.FDataType = 1059 AND T1.FIsKeyItem = 1058 AND T1.FPPBOMSelQty > 0)
AND CONVERT(VARCHAR(10),U1.FNeedDate,121) >= '2019-06-12' 
-----插入采购订单入库 
-----采购订单，是否未审核要参与查询，根据CsdPlanPurchase参数由GetPurchaseWillInSql决定 
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,u1.FUnitID,t1.FBeginDate,t1.FNeedDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,t1.FEntryID,
 0,t1.FWillQty,0,0,0,5 as FBillType
,v88.FAuxPropID, 0 ,v88.FMTONo 
 from (select v1.FTranType ,v1.FInterId as FInterID,v1.FBillNo,v1.FStatus,v2.FEntryID as FEntryID,v2.FItemID as FItemID,(tip.FAuxInMrpCal*v2.FAuxPropID) AS FAuxPropID, v2.FDate FBeginDate,v2.FDate FNeedDate,v2.FQty FQty, v2.FStockQty FStockQty
,(CASE WHEN v2.FCommitQty > v2.FQty THEN (CASE WHEN v2.FCommitQty > v2.FStockQty then v2.FCommitQty - v2.FStockQty else 0 END) ELSE (CASE WHEN v2.FQty > v2.FStockQty THEN v2.FQty - v2.FStockQty ELSE 0 END) END) FWillQty 
,v2.FMTONo,v1.FPlanCategory
,0 AS FBomCategory,0 AS FOrderBOMInterID ,0 AS FOrderBOMEntryID 
,0 AS FBOMInterID
 From POOrder v1 with (nolock) inner join POOrderEntry v2 with (nolock) on v1.FInterID = v2.FInterID 
 INNER JOIN  t_ICItemPlan tip ON v2.FItemID=tip.FItemID 
 Where v1.FCancellation = 0 
 AND ((v2.FCommitQty >= v2.FQty AND v2.FCommitQty > v2.FStockQty) OR (v2.FQty >= v2.FCommitQty AND v2.FQty > v2.FStockQty)) 
 and (  v2.FDate >= '2019-06-12' ) and v2.FMrpclosed = 0 and v1.FStatus > 0 AND V1.FPOStyle NOT IN (20300,20301) AND V1.FAreaPS<>20303 ) t1 inner join POOrder v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  t1.FItemID=v88.FItemid  and 0=v88.FCustBomInterID  and t1.FMTONo=v88.FMTONo 
 inner join POOrderEntry u1 WITH(NoLock) on (t1.FInterID=u1.FInterID and t1.FEntryID=u1.FEntryID and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end) 
 inner join t_IcItem v2 WITH(NoLock) on t1.FItemID=v2.FItemID --where v2.FErpClsID<>7 
-----考虑已审核的采购申请单 
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FBeginDate,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,u1.FUnitID,u1.FAPurchTime As FBeginDate,t1.FNeedDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,t1.FEntryID,
 0,t1.FWillQty,0,0,0,13 as FBillType
,u1.FAuxPropID,case when u1.FBOMCategory=36821 then u1.FBomInterid else 0 end, v88.FMTONo 
 from (select v1.FTranType ,v1.FInterId as FInterID,v1.FBillNo,v1.FStatus,v2.FEntryID as FEntryID,v2.FItemID as FItemID,(tip.FAuxInMrpCal*v2.FAuxPropID)  AS FAuxPropID,
 v2.FAPurchTime FBeginDate,v2.FFetchTime FNeedDate,v2.FQty FQty, 0 FStockQty
 ,case v1.FBizType when 12510 then (case when v2.FQty > IsNull(v3.FCommitQty_New,0) then v2.FQty - IsNull(v3.FCommitQty_New,0) else 0 end) 
  else (case when v2.FQty > IsNull(v2.FOrderQty,0) then v2.FQty - IsNull(v2.FOrderQty,0) else 0 end) end AS FWillQty
,v2.FMTONo,v1.FPlanCategory 
,(CASE WHEN v2.FBOMCategory = 36822 AND ISNULL(T4.FInterID ,0) = 0 THEN 36820 ELSE v2.FBOMCategory END) AS FBOMCategory
,(CASE WHEN v2.FBOMCategory = 36822 AND ISNULL(T4.FInterID ,0) > 0 THEN T4.FInterID ELSE 0 END) AS FOrderBOMInterID
,(CASE WHEN v2.FBOMCategory = 36822 AND ISNULL(T4.FInterID ,0) > 0 THEN v2.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID
,(CASE WHEN v2.FBOMCategory = 36822 THEN 0  ELSE (CASE WHEN v2.FBOMInterID > 0 THEN v2.FBOMInterID
       WHEN ISNULL(T3.FBOM,0) > 0 THEN ISNULL(T3.FBOM,0)
       ELSE 0
   END )  END) AS FBOMInterID
 From PORequest v1 with (nolock) 
     inner join PORequestEntry v2 with (nolock) on v1.FInterID = v2.FInterID 
     INNER JOIN  t_ICItemPlan tip ON v2.FItemID=tip.FItemID 
 left join ( 
     select v1.FInterID,v1.FEntryID,isnull(Sum(isnull(v1.FOrderQty,0)),0) as FCommitQty_New 
     from PORequest u1 with (nolock) 
     inner join PORequestEntry v1 with (nolock) on u1.FInterID = v1.FInterID
     where u1.FStatus in (1,2,3) and u1.FCancellation = 0 and v1.FMrpClosed = 0
     group by v1.FInterID,v1.FEntryID,v1.FMTONo ) v3 on v2.FInterID = v3.FInterID and v2.FEntryID = v3.FEntryID 
     LEFT JOIN ICMrpResult T3 with (nolock) ON v2.FPlanOrderInterID = T3.FInterID
     LEFT JOIN ICOrderBOM T4 ON v2.FBOMCategory = 36822  AND v2.FBOMInterID = T4.FInterID AND T4.FOrderBOMStatus=36832 
 Where v1.FCancellation = 0 
 AND ((v1.FBizType = 12510 AND v2.FQty > IsNull(v3.FCommitQty_New,0)) OR (v1.FBizType <> 12510 AND v2.FQty > IsNull(v2.FOrderQty,0)))  
 and (  v2.FFetchTime >= '2019-06-12' ) and v2.FMrpclosed = 0 and v1.FPlanConfirmed=1 and v1.FCancellation=0 ) t1 inner join PORequest v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
 inner join PORequestEntry u1 WITH(NoLock) on (t1.FInterID=u1.FInterID and t1.FEntryID=u1.FEntryID) 
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  t1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end and (u1.FBomInterid=v88.FCustBomInterID or u1.FBOMCategory<>36821)  and t1.FMTONo=v88.FMTONo 
 inner join t_IcItem v2 WITH(NoLock) on t1.FItemID=v2.FItemID --where v2.FErpClsID<>7 
-----第四步:插入已分配量单据) 
-----投料单预计出库
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,v2.FUnitID,t1.FNeedDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,t1.FEntryID,
 0,0,t1.FWillQty,0,0,case when v1.FOrderEntryID>0  then 21 else 20 end as FBillType, v2.FAuxPropID as FAuxPropID, Isnull(t2.FInterID,0) as FCustBomInterID,v88.FMTONo 
 from (SELECT u1.FTranType ,u1.FInterID as FInterID,u1.FBillNo,u1.FStatus, u2.FEntryID as FEntryID,u2.FItemID as FItemID,u2.FAuxPropID, u2.FSendItemDate FNeedDate,u2.FQtyMust FQty,u2.FStockQty FStockQty, (case when u2.FQtyMust + u2.FQtySupply> u2.FStockQty + isnull(u3.FLockQty,0) then u2.FQtyMust + u2.FQtySupply - u2.FStockQty - isnull(u3.FLockQty,0) else 0 end ) FWillQty 
     , isnull(u3.FLockQty,0) FLockQty 
     ,u2.FMTONo 
     ,(CASE WHEN S0.FInterID IS NULL THEN 0 ELSE 36822 END) AS FBomCategory
     ,ISNULL(T0.FOrderBOMInterID,0) AS FOrderBOMInterID,CASE WHEN ISNULL(T0.FOrderBOMInterID,0) >0 THEN  ISNULL(u2.FOrderBOMEntryID,0) ELSE 0 END AS FOrderBOMEntryID
     ,0 AS FSupplyID,1058 AS FSubstitute
     ,(CASE WHEN u2.FBOMInterID > 0 THEN u2.FBOMInterID ELSE 0 END) AS FBOMInterID
 From (SELECT FInterID,0 as FEntryID,FMTONo,v1.FTranType,v1.FPlanCategory,v1.FBomInterID,v1.FBomCategory,v1.FOrderInterID AS FInterIDOrder_SRC,v1.FSourceEntryID AS FEntryIDOrder_SRC FROM ICMO v1 WHERE  v1.FCancellation = 0 and v1.FMrpClosed = 0   and v1.FMrpclosed = 0 and ((v1.FStatus = 0 and ((v1.FMrp=1052 or v1.FMrp=1053 or v1.FMrp=11084))) 
 or (v1.FStatus >0  ))
         union all 
       select t2.FInterID,t2.FEntryID,t2.FMTONo,t1.FClassTypeID AS FTranType,t1.FPlanCategory,T2.FBomInterID,T2.FBomCategory,T2.FInterIDOrder_SRC,T2.FEntryIDOrder_SRC from ICSubContract t1 inner join ICSubContractEntry t2 on t1.Finterid=t2.Finterid where t1.FCancellation = 0 and t1.FStatus > 0  and t2.FMrpClosed = 0 
      )v1 inner join  PPBOM u1 with (nolock) on u1.FICMOInterID = v1.FInterID AND v1.FEntryID=u1.FOrderEntryID
      inner join PPBOMEntry u2 with (nolock) on  u1.fInterId = u2.FInterID  
     LEFT JOIN SEOrderEntry T0 with (nolock) ON v1.FBomCategory = 36822 AND T0.FInterID = v1.FInterIDOrder_SRC AND T0.FEntryID = v1.FEntryIDOrder_SRC AND T0.FOrderBOMStatus = 36832
     LEFT JOIN ICOrderBOMChild S0 with (nolock) ON S0.FInterID = T0.FOrderBOMInterID AND S0.FItemID = u2.FItemID  AND S0.FEntryID = u2.FOrderBOMEntryID  
      left join (select s1.FTranType,s1.Finterid,s1.FEntryID,s1.FItemID,sum(isnull(case when isnull(s1.FQty,0) <=0 then 0 else s1.FQty end,0)) FLockQty 
                 From t_LockStock s1 with (nolock) inner join t_Stock s3 with (nolock) 
                  on ( s1.FStockID = s3.FItemID )
                 Where s1.FTranType = 88 

                 group by FTranType,FinterID,s1.FEntryID,s1.FItemID ) u3 
      On (u2.FLockFlag > 0 and u2.FInterID = u3.FInterID and u2.FEntryID = u3.FEntryID and u2.FItemID = u3.FItemID) 
 Where  1 = 1 
 and ( u2.FQtyMust + u2.FQtySupply> u2.FStockQty + isnull(u3.FLockQty,0) or isnull(u3.FLockQty,0) > 0) and (u2.FMaterielType=371) 
 and (  u2.FSendItemDate >= '2019-06-12' )) t1 
  inner join PPBOM v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  inner join PPBOMEntry v2 WITH(NoLock) on t1.FInterID = v2.FInterID AND t1.FEntryID=v2.FEntryID 
  Left Join ICBom t2 WITH(NoLock) on v2.FBomInterID=t2.FInterID and t2.FBomtype=3 
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  v2.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v2.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and v2.FMTONo=v88.FMTONo 
  where t1.FWillQty > 0 
-----物料替代清单:已分配  V12龙工专项 Add By lihaisheng
INSERT INTO #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
SELECT  10,V1.FSubsItemID,U1.FNeedDate,U1.FClassTypeID,U1.FID,U1.FBillNo
    ,Case U1.FStatus WHEN 0 THEN '计划' WHEN 1 THEN '审核' WHEN 3 THEN '手工关闭' ELSE '业务关闭' END
    ,V1.FIndex,0,0
    ,ISNULL((V1.FRelSubsQty - V1.FPPBOMSelQty),0) AS FWillOutQty
    ,0,0,70 as FBillType,V1.FAuxPropID,0 as FCustBomInterID,V88.FMTONo
  FROM ICSubsItemBill U1 WITH(NoLock) INNER JOIN ICSubsItemBillEntry V1 WITH(NoLock) ON U1.FID = V1.FID
        INNER JOIN #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 V88 ON V1.FSubsItemID = V88.FItemID and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end AND V88.FCustBomInterID = 0 AND U1.FMTONo = V88.FMTONo 
 WHERE V1.FDataType = 1059 AND V1.FPPBOMSelQty <= 0 AND U1.FStatus = 1 
AND CONVERT(VARCHAR(10),U1.FNeedDate,121) >= '2019-06-12' 
-----销售订单预计出库
insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,u1.FUnitID,t1.FNeedDate,v1.FTranType,v1.FInterID,v1.FBillNo,case  when v1.FCheckerID>0 then '审核' when v1.FCheckerID<0 then '审核' else '计划' end ,t1.FEntryID,
 0,0,t1.FWillQty,0,0,25 as FBillType, u1.FAuxPropID,case when u1.FBOMCategory=36821  then Isnull(u1.FBomInterID,0) else 0 end,v88.FMTONo  
 from (select v1.FTranType ,v1.FInterId as FInterID,v1.FBillNo,v1.FStatus,v2.FEntryID as FEntryID,v2.FItemID as FItemID,(tip.FAuxInMrpCal*v2.FAuxPropID) AS FAuxPropID,(SELECT TOP 1 FPreDay FROM T_MutiWorkCal WHERE FCalID = 999 AND FDay =v2.FAdviceConsignDate) AS FNeedDate, v2.FQty FQTy,v2.FStockQty FStockQty, ( CASE WHEN v2.FQty > isnull(v2.FStockQty,0) + isnull(u3.FLockQty,0) then (v2.FQty - v2.FStockQty - isnull(u3.FLockQty,0)) else 0 END ) FWillQty ,  isnull(u1.FLockQty,0) FLockQty
,v2.FMTONo
,(CASE WHEN v2.FBomCategory =36822 AND v2.FOrderBOMStatus = 36832 THEN  36822 ELSE v2.FBomCategory END) AS FBomCategory
,(CASE WHEN v2.FBomCategory = 36822 AND v2.FOrderBOMStatus = 36832 THEN v2.FOrderBOMInterID ELSE 0 END) AS FOrderBOMInterID
,CASE WHEN v2.FBomCategory = 36822 AND v2.FOrderBOMStatus = 36832  THEN ISNULL(v2_1.FEntryID,0) ELSE 0 END AS FOrderBOMEntryID
,0 AS FSupplyID,1058 AS FSubstitute,(CASE WHEN v2.FBOMCategory = 36822 THEN 0  ELSE v2.FBOMInterID END) AS FBOMInterID
 From SEOrder v1 with (nolock) 
 inner join SEOrderEntry v2 with (nolock) on (v1.FInterID = v2.FInterID and v1.FCancellation = 0) 
 LEFT join ICOrderBOMChild v2_1 with (nolock) on v2.FOrderBOMInterID=v2_1.FInterID AND v2_1.FParentID=0

 left join (select s1.FTranType,s1.Finterid,s1.FEntryID,s1.FItemID,sum(isnull(case when isnull(s1.FQty,0) <=0 then 0 else s1.FQty end,0)) FLockQty 
              From t_LockStock s1 with (nolock) inner join t_Stock s3 with (nolock) on ( s1.FStockID = s3.FItemID )
              Where s1.FTranType = 81 
              group by FTranType,FinterID,s1.FEntryID,s1.FItemID 
 ) u1  On (v2.FLockFlag > 0 and v2.FInterID = u1.FInterID and v2.FEntryID = u1.FEntryID and v2.FItemID = u1.FItemID) 
 left join (select FTranType, FInterid, FEntryID, FItemID,sum(isnull(FQty,0)) FLockQty 
             From t_LockStock with (nolock)  Where FTranType = 81 And FQty > 0
             group by FTranType, FInterID, FEntryID, FItemID
 ) u3 On (v2.FLockFlag > 0 and v2.FInterID = u3.FInterID and v2.FEntryID = u3.FEntryID and v2.FItemID = u3.FItemID)
 INNER JOIN  t_ICItemPlan tip ON v2.FItemID=tip.FItemID 
 Where  v2.FItemID > 0  and (v2.FQty > isnull(v2.FStockQty,0) + isnull(u1.FLockQty,0) or isnull(u1.FLockQty,0) > 0) 
 and (  v2.FAdviceConsignDate >= '2019-06-12' ) and IsNull(v2.FMrpclosed,0) = 0 and v1.FStatus > 0 AND V1.FSaleStyle NOT IN (20296,20297) AND V1.FAreaPS<>20303 ) t1 inner join SEOrder v1 WITH(NoLock) on t1.FInterID=v1.FInterID inner join SEOrderEntry u1 WITH(NoLock) on t1.FInterID=u1.FInterID and t1.FEntryID=u1.FEntryID  
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  u1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(u1.FAuxPropID,0) else v88.FAuxPropID end and (u1.FBomInterID=v88.FCustBomInterID or  u1.FBOMCategory<>36821 )  and u1.FMTONo=v88.FMTONo 
 where t1.FWillQty>0
-----其他已分配量/预计入
 insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,v1.FUnitID,t1.FDate,case when v1.FTranType = 85 AND V1.FType=1067 then 85 when v1.FTranType = 85 AND V1.FType=11060 then 85 else v1.FTranType end,
 v1.FInterID,v1.FBillNo,Case v1.FStatus when 0 then '计划' when 3 then '结案' when 5 then '确认' Else '下达' end,0,
 0,0,t1.FWillQty,0,0,case when v1.FTranType = 85 AND V1.FType=1067 then 41 when v1.FTranType = 85 AND V1.FType=11060 then 44 else 40 end
 ,v1.FAuxPropID ,Isnull(t2.FInterID,0) as FCustBomInterID,v88.FMTONo 
 from (select v1.FTranType,v1.FInterID,0 as FEntryID, v1.FPlanCommitDate FDate,v1.FItemID, v1.FAuxPropID,
 (case when v1.FQty >  isnull(v1.FReleasedQty,0) then (v1.FQty -  isnull(v1.FReleasedQty,0)) else 0 end ) FWillQty 
,v1.FMTONo
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) = 0 THEN 36820 ELSE v1.FBomCategory END) AS FBomCategory
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) >0 THEN T1.FInterID ELSE 0 END) AS FOrderBOMInterID
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) >0 THEN v1.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID
 From ICMO v1 with (nolock) 
   LEFT JOIN ICOrderBOM T1 ON v1.FBOMInterID=T1.FInterID AND v1.FBomCategory = 36822  AND T1.FOrderBOMStatus = 36832 
 Where  v1.FCancellation = 0 and  v1.FType = 1055
 and not exists (select top 1 u1.FICMOInterID from PPBOM u1 with (nolock) Where u1.FICMOInterID = v1.FInterID) and (  v1.FPlanCommitDate >= '2019-06-12' ) and v1.FMrpclosed = 0 and ((v1.FStatus = 0 and v1.FPlanConfirmed=1) 
 or (v1.FStatus >0  ))) t1 inner join ICMO v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  Left Join ICBom t2 WITH(NoLock) on v1.FBomInterID=t2.FInterID and t2.FBomtype=3 
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  t1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and t1.FMTONo=v88.FMTONo 
  where v1.FInterID=t1.FInterID and v1.FTranType=t1.FTranType and t1.FWillQty>0 and v1.FTranType <> 54 
 insert into #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60(FDataType,FItemID,FUnitID,FNeedDate,FRelationTranType,FRelationInterID,FBillNo,FStatusName,FRelationEntryID,
 FBeginStockQty,FWillInQty,FWillOutQty,FLockQty,FWillStockQty,FBillType,FAuxPropID,FCustBomInterID,FMTONo)
 select 10,t1.FItemID,v1.FUnitID,t1.FDate,v1.FTranType ,
 v1.FInterID,v1.FBillNo,Case v1.FStatus when 0 then '计划' when 1 then '审核' Else '关闭' end,0,
 0,0,t1.FWillQty,0,0,45
 ,v1.FAuxPropID ,Isnull(t2.FInterID,0) as FCustBomInterID,v88.FMTONo 
 from (select v1.FTranType,v1.FInterID,0 as FEntryID, v1.FPlanCommitDate FDate,v1.FItemID, v1.FAuxPropID,
 (case when v1.FQty >  isnull(v1.FReleasedQty,0) then (v1.FQty -  isnull(v1.FReleasedQty,0)) else 0 end ) FWillQty 
,v1.FMTONo
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) = 0 THEN 36820 ELSE v1.FBomCategory END) AS FBomCategory
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) >0 THEN T1.FInterID ELSE 0 END) AS FOrderBOMInterID
,(CASE WHEN v1.FBomCategory = 36822 AND ISNULL(T1.FInterID,0) >0 THEN v1.FOrderBOMEntryID ELSE 0 END) AS FOrderBOMEntryID
 From ICMO v1 with (nolock) 
   LEFT JOIN ICOrderBOM T1 ON v1.FBOMInterID=T1.FInterID AND v1.FBomCategory = 36822  AND T1.FOrderBOMStatus = 36832 
 Where  v1.FCancellation = 0 and  v1.FType = 1055
 and not exists (select top 1 u1.FICMOInterID from PPBOM u1 with (nolock) Where u1.FICMOInterID = v1.FInterID) and (  v1.FPlanCommitDate >= '2019-06-12' ) and v1.FMrpclosed = 0 and ((v1.FStatus = 0 and v1.FPlanConfirmed=1) 
 or (v1.FStatus >0  ))) t1 inner join ICMO v1 WITH(NoLock) on t1.FInterID=v1.FInterID 
  Left Join ICBom t2 WITH(NoLock) on v1.FBomInterID=t2.FInterID and t2.FBomtype=3 
  inner join #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 v88 on  t1.FItemID=v88.FItemid and v88.FAuxPropID=Case when v88.FAuxInMrpCal=1 then ISNULL(v1.FAuxPropID,0) else v88.FAuxPropID end and Isnull(T2.Finterid,0)= v88.FCustBomInterID  and t1.FMTONo=v88.FMTONo 
 where v1.FInterID=t1.FInterID and v1.FTranType=t1.FTranType and t1.FWillQty>0 and v1.FTranType = 54
 --日期排法参数的逻辑处理 add by linus wang at 2010-08-09 
 --更新需求类单据的需求日期（按工厂日历） 
 UPDATE tp SET FNeedDate=ISNULL(t2.FPreDay,tp.FNeedDate) 
 FROM #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 tp 
 INNER JOIN t_ICItem item ON item.FItemID=tp.FItemID 
 LEFT JOIN t_Department dept ON dept.FItemID=ISNULL(item.FSource,0) 
 LEFT JOIN t_MutiWorkCal t1 ON DATEDIFF(d,t1.FDay,tp.FNeedDate)=0 AND t1.FCalID=ISNULL(dept.FCalID,999) 
 LEFT JOIN t_MutiWorkCal t2 ON t2.FInterID=t1.FInterID- 0 AND t2.FCalID=t1.FCalID 
 WHERE tp.FBillType>=20 AND tp.FBillType<>70 

 
--开始显示汇总信息
select  IDENTITY(int,1,1) as Fid,t88.f01,t88.f02,t88.f03,t88.f04,t88.f05,IsNull(t86.FName,'') FPlanner,
 Isnull(t87.FName,'') + '/' + Isnull(t90.FName,'') as FProductPrincipal, 
t1.FItemID,t89.fname FUseState,t1.FQtyDecimal, t1.FAuxClassID,t1.FPlanPoint,t1.FRequirePoint,t1.FNumber as FNumber,t1.FShortNumber,t1.FName,t1.FModel,t1.FHelpCode,t2.Fname FUnitID,t1.FSecInv,/*isnull(t3.FQty,0) FQty,*/
   t1.FLeadTime,t1.FFixLeadTime,t1.FBatChangeEconomy,t1.FQtyMin,t6.FName as FOrderTrategy,
   t1.FQtyMax FMaxQty, t1.FBatFixEconomy, t1.FBatchAppendQty,
  t4.FName as FCUUnitID, Round(t1.FSecInv/t4.FCoefficient,t1.FQtyDecimal) as FCUSecInv, /*Round(isnull(t3.FQty,0)/t4.FCoefficient,t1.FQtyDecimal) as FCUQty,*/ 
  Round(t1.FQtyMin/t4.FCoefficient,t1.FQtyDecimal) as FCUQtyMin,
  Round(t1.FQtyMax/t4.FCoefficient,t1.FQtyDecimal) FCUMaxQty, Round(t1.FBatFixEconomy/t4.FCoefficient,t1.FQtyDecimal) as FCUBatFixEconomy, Round(t1.FBatchAppendQty/t4.FCoefficient,t1.FQtyDecimal) as FCUBatchAppendQty
   ,t7.FName as FErpClsID, t1.FErpClsId as FErpCls,isnull(t8.FQtyInv,0) as FStockQty,Round(isnull(t8.FQtyInv,0)/t4.FCoefficient,t1.FQtyDecimal) as FCUStockQty 
   ,ISNULL(V.FWillInQty,0) AS FWillInQty,
   Round(ISNULL(V.FWillInQty,0)/t4.FCoefficient,t1.FQtyDecimal) as FCUWillInQty,
   ISNULL(V.FWillOutQty,0) AS FWillOutQty
   ,Round(ISNULL(V.FWillOutQty,0)/t4.FCoefficient,t1.FQtyDecimal) as FCUWillOutQty,
    ISNULL(V.FLockQty,0) AS FLockQty,
   Round(ISNULL(V.FLockQty,0)/t4.FCoefficient,t1.FQtyDecimal) as FCULockQty
   ,ISNULL(t8.FQtyInv,0)+ISNULL(V.FWillInQty,0)-ISNULL(V.FWillOutQty,0)-ISNULL(V.FLockQty,0) - ISNULL(V.FSecInv,0) AS FUsableStockQty
   ,Round((ISNULL(t8.FQtyInv,0)+ISNULL(V.FWillInQty,0)-ISNULL(V.FWillOutQty,0)- ISNULL(V.FSecInv,0)-ISNULL(V.FLockQty,0))/t4.FCoefficient,t1.FQtyDecimal) AS FCUUsableStockQty,t99.FName as FAuxPropIDName,
   t88.FAuxPropID
 INTO #Result 
   from t_icitem t1 inner join  
   (SELECT FItemID,FAuxPropID,Sum(F01) as F01,Sum(F02) as F02,Sum(F03) as F03,Sum(F04) as F04,Sum(F05) as F05 
   FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 
   GROUP BY FItemID,FAuxPropID) t88 on t1.fitemid=t88.fitemid 
  inner join #BomSkipTable BomSkipTable on BomSkipTable.FItemID=t1.FItemID
   left join t_MeasureUnit t2 on t1.FUnitID=t2.FItemID 
   left join t_Item t86 on t1.FPlanner=t86.fitemid  and t86.fitemid>0
  left join t_Item t87 on t1.FProductPrincipal=t87.fitemid  and t87.fitemid>0
  left join t_Item t90 on t1.FOrderRector=t90.fitemid  and t90.fitemid>0  left join t_submessage t89 on t1.FUseState=t89.finterid and t89.finterid>0
   left join t_MeasureUnit t4  on t1.FStoreUnitID = t4.FItemID   
   left join t_Submessage t6  on t6.finterid=t1.FOrderTrategy  
   left join t_SubMessage t7 on t1.FErpClsId=t7.FInterID 
   left join (Select sum(v8.FQty) as FQtyInv,v8.FItemID as FItemID,v8.FAuxPropID  From (SELECT v1.FItemID,FMtoNo,FQty,FStockID,(case when v1.FAuxInMrpCal=1 then ICInv.FAuxPropID else 0 end) as FAuxPropID  from ICInventory as ICInv 
             inner join t_ICItemPlan v1 on ICInv.FItemID=v1.FItemID  WHERE 1=1   


                  union all SELECT v1.FItemID,FMtoNo,FQty,FStockID,(case when v1.FAuxInMrpCal=1 then POInv.FAuxPropID else 0 end) as FAuxPropID from POInventory as POInv               inner join t_ICItemPlan v1 on POInv.FItemID=v1.FItemID  WHERE 1=1   


) v8 
             inner join t_Stock v9 on v8.FStockID=v9.FItemID  and v9.FTypeID<>501  
             inner join #StockList v10 on v8.FStockID=v10.FStockID 
             Where 1 = 1 Group by v8.FItemID,v8.FAuxPropID) t8 on t1.FItemID=t8.FItemID and t88.FAuxPropID=t8.FAuxPropID  
    Left Join (
           SELECT t100.FItemID ,Case when t2.FAuxInMrpCal =1 then t1.FAuxPropID else 0 end as FAuxPropID,ISNULL(SUM(t1.FWillInQty),0) AS FWillInQty,ISNULL(SUM(t1.FWillOutQty),0) AS FWillOutQty,ISNULL(SUM(t1.FLockQty),0) as FLockQty,ISNULL(t100.FSecInv,0) AS FSecInv  FROM #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 t100 left join #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60 t1 on t100.FItemID=t1.FItemID  And t100.FAuxPropID = t1.FAuxPropID And t100.FMTONo = t1.FMTONo inner join t_ICItemPlan t2 on t100.FItemID=t2.FitemID GROUP BY t100.FItemID,t100.FSecInv,Case when t2.FAuxInMrpCal =1 then t1.FAuxPropID else 0 end 
    ) AS V ON T88.FItemID=v.FItemID and v.FAuxPropID=t88.FAuxPropID
 left join t_auxItem t99 on t99.FItemID=t88.FAuxPropID WHERE 1=1 
   order by t1.FNumber,t88.FAuxPropID


 --***********************************************************************************************************************
 --***********************************************************************************************************************
 --***********************************************************************************************************************
 


select @ptsl= case when @ptsl is null then 0 else @ptsl end
select @enddate =case when @enddate is null then '2099-01-01'else @enddate end
select @itemno=case when @itemno =''  then '' else @itemno end
select @itemno1=case when @itemno1 =''  then '' else @itemno1 end
select @itemno2=case when @itemno2 =''  then '' else @itemno2 end
select @itemno3=case when @itemno3 =''  then '' else @itemno3 end

 --    KCFX '''01.020103708','01.020102206','01.020103706','','',100

select
 0 fno,
'成品编号：'+c.FNumber as FNumber,'BOM单号：'+a.FBOMNumber wl,
'' wlsx ,'成品名称：'+c.FName wlmodel,'规格：'+c.FModel unit ,a.FBOMNumber bomnum,null dwrl,null jskcsl 
,c.FNumber stock,null qlsl,null fitemid,null wlxqsl,null mqlsl,null blpsl,null yfpl
into #sub
from ICBOM a 
left join ICBOMCHILD b on a.FInterID=b.FInterID
left join t_ICItem c on a.FItemID=c.FItemID 
where c.FNumber like @itemno or c.FNumber like @itemno1 or c.FNumber like @itemno2 or c.FNumber like @itemno3
or c.FNumber like @itemno4 or c.FNumber like @itemno5 or c.FNumber like @itemno6 or c.FNumber like @itemno7
group by c.FNumber ,a.FBOMNumber ,c.FName ,c.FModel

 select bomnum,case when stock=@itemno then @pts0
when stock=@itemno1 then @ptsl
when stock=@itemno2 then @pts2
when stock=@itemno3 then @pts3 
when stock=@itemno4 then @pts4
when stock=@itemno5 then @pts5
when stock=@itemno6 then @pts6
when stock=@itemno7 then @pts7 else 0 end ptsl
into #pt
from #sub order by BOMNum,fno

update a set a.qlsl=b.ptsl
from #sub a
inner join #pt b on a.bomnum=b.bomnum

select c.FName,b.FItemID,sum(FAuxQtyPick) yfsl,sum(FAuxStockQty) ylsl,sum(FAuxQtyPick)-sum(FAuxStockQty)yfpl 
into #yfpl1
from PPBOM a
inner join PPBOMEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID
group by b.FItemID,c.FName




select b.FItemID,b.FAuxQty-b.FStockQty wcksl
into #yfpl2
from SEOrder a
inner join SEOrderEntry b on a.FInterID=b.FInterID
where b.FDate<GETDATE() and b.FMrpClosed<>1





select *
into #sub1
from #sub
union all
select
1 fno,
d.FNumber,d.FName wl,e.FName wlsx,d.FModel wlmodel
,f.FName unit,a.FBOMNumber bomnum,isnull(b.FAuxQty,0) dwrl ,isnull(j.FQty,0) jskcsl ,isnull('','') stock,
case when p.ptsl=0 then 0 else case when isnull(isnull(b.FAuxQty,0)*isnull(p.ptsl,0)-isnull(j.FQty,0),0)<0 then 0 else isnull(isnull(b.FAuxQty,0)*p.ptsl-isnull(j.FQty,0),0) end end qlsl,
d.FItemID,isnull(isnull(b.FAuxQty,0)*p.ptsl,0) wlxqsl
,


case when p.ptsl=0 then 0 else case when isnull(b.FAuxQty,0)*isnull(p.ptsl,0)-(isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))<0 then 0 
when (isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))<0 then 
case when isnull(isnull(b.FAuxQty,0)*isnull(p.ptsl,0)-isnull(j.FQty,0),0)<0 then 0 else isnull(isnull(b.FAuxQty,0)*p.ptsl-isnull(j.FQty,0),0) end
 else isnull(b.FAuxQty,0)*p.ptsl-(isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0))) end end  mqlsl
--case when (isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))>0 then isnull(b.FAuxQty,0)*p.ptsl-(isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))
--else isnull(isnull(b.FAuxQty,0)*p.ptsl-isnull(j.FQty,0),0) end mqlsl

 --(isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))
 --isnull(b.FAuxQty,0)*p.ptsl-(isnull(j.FQty,0)-(isnull(h.yfpl,0)+isnull(i.wcksl,0)))
 --isnull(isnull(b.FAuxQty,0)*p.ptsl-isnull(j.FQty,0),0)
,isnull(k.FBLQty,0) blpsl,isnull(h.yfpl,0)+isnull(i.wcksl,0) yfpl
from ICBOM a 
left join ICBOMCHILD b on a.FInterID=b.FInterID
left join t_ICItem c on a.FItemID=c.FItemID 
left join t_ICItem d on  b.FItemID=d.FItemID
left join t_Submessage e on d.FErpClsID=e.FInterID
left join t_MeasureUnit f on d.FUnitID=f.FItemID    
left join (select FItemID,sum(FQty)FQty from ICInventory where FStockID in(279,280,281,284,285,286,4452)  group by FItemID) j on d.FItemID=j.FItemID  
left join (select FItemID,sum(FQty)FBLQty from ICInventory where FStockID in(282)  group by FItemID) k on d.FItemID=k.FItemID  
left join #Result g on b.FItemID=g.FItemID
left join #pt p on p.bomnum=a.FBOMNumber
left join #yfpl1 h on b.FItemID=h.FItemID
left join #yfpl2 i on b.FInterID=i.FItemID
where c.FNumber like @itemno or c.FNumber like @itemno1 or c.FNumber like @itemno2 or c.FNumber like @itemno3
or c.FNumber like @itemno4 or c.FNumber like @itemno5 or c.FNumber like @itemno6 or c.FNumber like @itemno7

----   KCFX '01.010201802',50,'01.010100801',30,'01.020102206',80,'01.010201102','20','01.020100704',100,'01.020100706',30,'01.020101502',60,'01.020102201',100,''
--**********************************************************


--select * from #pt 
--select * from #sub1 order by bomnum,fno
 --    KCFX '01.020409004','','','',20,100,50,30,''
 --    KCFX '01.020107501','01.010201802','01.010100801','01.020102206','20',100,50,30,''
--select * from #sub1 order by fno
--select * from t_TableDescription where FDescription like '%采购%'
--select * from t_FieldDescription where FTableID=200005 and FDescription like '%业务%'
--select * from POOrder a inner join POOrderEntry b on a.FInterID=b.FInterID where FBillNo=''


select 
ROW_NUMBER()over(partition by c.FItemID order by a.FDate ) frow,--最早采购订单日期
c.FItemID wlid,a.FDate ddrq
into #datedd
from POOrder a 
inner join POOrderEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID 
where   isnull(a.FStatus,0)<>0 
and b.FQty-b.FStockQty<>0 and b.FMrpClosed<>1
and a.FInterID not in (select FInterID from POOrder where( FBillNo='CGDD20181105' and  FInterID<>1178) or ( FBillNo='CGDD20190102' and  FInterID<>1175))
--and convert(varchar(7),a.FDate,120)='2019-05'--CONVERT(varchar(7),GETDATE(),120) --and a.FBillNo='CGDD20190361'
--group by c.FItemID ,a.FDate 


select 
ROW_NUMBER()over(partition by c.FItemID order by b.FEntrySelfP0273 ) frow,--最早延长到货日期
c.FItemID wlid,b.FEntrySelfP0273 ycdhrq
into #dateycdh
from POOrder a 
inner join POOrderEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID 
where   isnull(a.FStatus,0)<>0 
and b.FQty-b.FStockQty<>0 and b.FMrpClosed<>1
and a.FInterID not in (select FInterID from POOrder where( FBillNo='CGDD20181105' and  FInterID<>1178) or ( FBillNo='CGDD20190102' and  FInterID<>1175))


select 
ROW_NUMBER()over(partition by c.FItemID order by b.FDate ) frow,--最早交货日期
c.FItemID wlid,b.FDate jhrq
into #datejh
from POOrder a 
inner join POOrderEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID 
where   isnull(a.FStatus,0)<>0 
and b.FQty-b.FStockQty<>0 and b.FMrpClosed<>1
and a.FInterID not in (select FInterID from POOrder where( FBillNo='CGDD20181105' and  FInterID<>1178) or ( FBillNo='CGDD20190102' and  FInterID<>1175))
--and convert(varchar(7),a.FDate,120)='2019-05'--CONVERT(varchar(7),GETDATE(),120) --and a.FBillNo='CGDD20190361'
--group by c.FItemID ,b.FDate 



select 
ROW_NUMBER()over(partition by c.FItemID order by a.FDate desc) frow,--最晚入库日期
c.FItemID wlid,a.FDate rkrq
into #daterk
from ICStockBill a 
inner join ICStockBillEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID 
where   isnull(a.FStatus,0)<>0 
and FTranType=1 



select 
c.FItemID wlid,c.FName wl,sum(isnull(b.FQty,0)) dhsl,sum(isnull(b.FStockQty,0)) rksl
into #3
from POOrder a 
inner join POOrderEntry b on a.FInterID=b.FInterID
left join t_ICItem c on b.FItemID=c.FItemID 
where   isnull(a.FStatus,0)<>0 
and b.FQty-b.FStockQty<>0 and b.FMrpClosed<>1 and
 a.FInterID not in (select FInterID from POOrder where( FBillNo='CGDD20181105' and  FInterID<>1178) or ( FBillNo='CGDD20190102' and  FInterID<>1175))
--and convert(varchar(7),a.FDate,120)='2019-05'--CONVERT(varchar(7),GETDATE(),120) --and a.FBillNo='CGDD20190361'
group by c.FItemID ,c.FName




select 
a.wlid,a.dhsl,a.rksl,b.ddrq,c.jhrq,d.rkrq,e.ycdhrq
into #sub2
from #3 a left join #datedd b on a.wlid=b.wlid
left join #datejh c on a.wlid=c.wlid and b.frow=c.frow
left join #daterk d on a.wlid=d.wlid and b.frow=d.frow and a.rksl<>0
left join #dateycdh e on a.wlid=e.wlid and b.frow=e.frow
where b.frow=1



----   KCFX '01.010201802',50,'01.010100801',30,'01.020102206',80,'01.010201102','20','01.020100704',100,'01.020100706',30,'01.020101502',60,'01.020102201',100,''




 select 
 a.fno,a.FNumber 物料长代码,a.wl 物料,a.wlsx 物料属性,a.wlmodel 规格型号,a.unit 计量单位,
 sum(isnull(a.dwrl,0)) 单位用量, isnull(a.jskcsl,0) 即时库存数量,isnull(a.yfpl,0) 已分配量,--isnull(c.FWillOutQty,0)
 sum( isnull(a.wlxqsl,0)) 物料需求数量, sum(isnull(a.qlsl,0)) 缺料数量,sum(isnull(mqlsl,0))[缺料数量(毛需求)], 
 isnull(b.dhsl,0)-isnull(b.rksl,0) 未到物料数量,
 isnull(b.dhsl,0) 订货数量, isnull(convert(varchar(10),b.ddrq ,120),'') 订单日期
 ,isnull(convert(varchar(10),b.jhrq ,120),'') 交货日期, isnull(b.rksl,0) 入库数量,
 isnull(convert(varchar(10),b.rkrq ,120),'')入库日期, isnull(convert(varchar(10),b.ycdhrq ,120),'') 延长到货日期
 , isnull(a.jskcsl,0)-isnull(a.yfpl,0) 分配后的库存量,isnull(blpsl,0) 不良品数量
 into #lresult
 from #sub1 a
 left join #sub2 b on a.fitemid=b.wlid 
 left join #Result c on a.fitemid=c.fitemid  
 group by a.FNumber ,a.wl ,a.wlsx ,a.wlmodel ,a.unit ,
 isnull(a.jskcsl,0) ,a.yfpl,
 isnull(b.dhsl,0)-isnull(b.rksl,0) ,
 isnull(b.dhsl,0) , isnull(convert(varchar(10),b.ddrq ,120),'') 
 ,isnull(convert(varchar(10),b.jhrq ,120),'') , isnull(b.rksl,0) ,
 isnull(convert(varchar(10),b.rkrq ,120),'')
 , isnull(convert(varchar(10),b.ycdhrq ,120),''),
 isnull(blpsl,0) ,a.fno
order by a.fno



select
 物料长代码,物料,规格型号,计量单位,
 单位用量,即时库存数量,物料需求数量,
 case when (物料需求数量-即时库存数量)<0  then 0 else case when fno=1 then 物料需求数量-即时库存数量 else 缺料数量 end end 缺料数量
,未到物料数量,订单日期,订货数量 ,交货日期,延长到货日期,入库数量,入库日期,已分配量 ,不良品数量,分配后的库存量,
case when 分配后的库存量<0 then -分配后的库存量 else 0 end  [缺料数量(毛需求)]
 --case when 已分配量>0 then case when fno=1 then 物料需求数量-分配后的库存量 else 0 end else case when (物料需求数量+已分配量-即时库存数量)<0  then 0 else case when fno=1 then 物料需求数量+已分配量-即时库存数量 else 缺料数量 end end end   [缺料数量(毛需求)]
 from  #lresult a

drop table #yfpl1
drop table #yfpl2
drop table #datedd
drop table #datejh
drop table #daterk
drop table #dateycdh
drop table #3
drop table #sub1
drop table #sub2
drop table #lresult
drop table #pt
drop table #sub



DROP TABLE #Result
drop table #TempSum_#TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60
drop table #StockList
drop table #TempStockStatus201906127B0437509AD0452A9299FD3A3DFAFE60
drop table 	#BomSkipTable
drop table #BomList2
drop table #BomList

end