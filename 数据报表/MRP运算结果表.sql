

ALTER proc [dbo].[mrpdetail]

@itemstart varchar(200),
@itemend varchar(200),
@startdate datetime ,
@enddate datetime,
@KJQJ int 

as begin 

 select @itemstart=case when @itemstart='' then '000000000000000' else @itemstart end
 select @itemend=case when @itemend='' then 'zzzzzzzzzzzzzzzzz' else @itemend end
 select @startdate= case when @startdate=''then '2000-01-01'else @startdate end
 select @enddate= case when @enddate=''then '2099-01-01'else @enddate end
 select @KJQJ= case when @KJQJ='' or @KJQJ=0 then MONTH(GETDATE()) else @KJQJ end 


  SELECT *  into #head FROM (
  SELECT DISTINCT a.FItemID,a.FQtyDecimal, a.FNumber,a.FName,a.FModel,b.Fname FUnitID,a.FSecInv,isnull(t1.FQty,0) FQty,
              a.FLeadTime,a.FFixLeadTime,a.FBatChangeEconomy,a.FQtyMin,t5.FName as FOrderTrategy,
              a.FQtyMax FMaxQty, a.FBatFixEconomy, a.FBatchAppendQty,
              t51.FName as FCUUnitID, Round(a.FSecInv/t51.FCoefficient,a.FQtyDecimal) as FCUSecInv,Round(isnull(t1.FQty,0)/t51.FCoefficient,a.FQtyDecimal) as FCUQty, 
              Round(a.FQtyMin/t51.FCoefficient,a.FQtyDecimal) as FCUQtyMin,
              Round(a.FQtyMax/t51.FCoefficient,a.FQtyDecimal) FCUMaxQty, Round(a.FBatFixEconomy/t51.FCoefficient,a.FQtyDecimal) as FCUBatFixEconomy, Round(a.FBatchAppendQty/t51.FCoefficient,a.FQtyDecimal) as FCUBatchAppendQty
             ,t60.FBomInterID,t60.FBomNumber  
             ,t1.FMTONo,(CASE ISNULL(t1.FMTONo,'') WHEN '' THEN 'MTS计划模式' ELSE 'MTO计划模式' END) FPlanMode 
             ,taux.FName AS FAuxPropName, t1.FAuxPropID 
  from t_icitem a left join t_MeasureUnit b on a.FUnitID=b.FItemID 
  left join (SELECT DISTINCT t1.FItemID,t1.FAuxPropID,t1.FBomInterID,ISNULl(t3.FNumber,'') AS FBomNumber 
               FROM ( 
                           SELECT DISTINCT t1.FItemID,t1.FAuxPropID,CASE WHEN t2.FErpClsID=7 THEN t1.FBOMInterID ELSE ISNULl(t3.FInterID,0) END AS FBOMInterID 
                           From IC_PLMRPDetail t1  
                           INNER JOIN t_ICItemBase t2 ON t1.FItemID=t2.FItemID 
                           LEFT JOIN ICBOM t3 ON t1.FItemID=t3.FItemID AND t1.FAuxPropID=t3.FAuxPropID AND t3.fUSeStatus=1072
               ) t1 
               LEFT JOIN vw_BOMList t3 ON t1.FBOMInterID=t3.FInterID
   ) t60 on a.FItemID=t60.FItemID  
  left join t_MeasureUnit t51  on a.FProductUnitID = t51.FItemID 
  left join t_Submessage t5  on t5.finterid=a.FOrderTrategy 
  left join (select distinct b.FItemID,b.FAuxPropID,b.FMTONo,a.FQty 
               from  IC_PLMRPDetail b 
               left join ICMrpInfo f on b.FRunID=f.FInterID 
               left join (select a1.FItemID,a1.FAuxPropID,a1.FMTONo,isnull(sum(IsNull(a1.FStockQty,0)),0) FQty
                            From (  Select 2 FStockType,s1.FStockID, s1.FItemID AS FItemID, s1.FAuxPropID AS FAuxPropID,s1.FMTONo,
                                        round((case when s1.FQty <= isnull(s4.FQty,0) then s1.FQty - isnull(s4.FQty,0) else s1.FQty - isnull(s4.FQty,0) end ),s2.FQtyDecimal) FStockQty 
                                        From (select u1.FItemID,u1.FAuxPropID,u1.FMTONo,u1.FStockID,sum(u1.FQty) as FQty 
                                                  From ICInventory u1 
                                                  Group by u1.FStockID,u1.FItemID,u1.FAuxPropID,u1.FMTONo
                                        ) s1 
                                       inner join  t_icitem s2 on s1.FItemID = s2.FItemID
                                       inner join t_Stock s3 on ( s1.FStockID = s3.FItemID  and s3.FMRPAvail = 1 and s3.FItemID in (279,280,281,284,285,4452))
                                       left join ( select u2.FItemID,u2.FAuxPropID,u2.FStockID,sum(case when isnull(u2.FQty,0) <= 0 then 0 else u2.FQty END) FQty 
                                                     From t_lockstock u2 where u2.FStockID in (279,280,281,284,285,4452)
                                                     Group by u2.FStockID,u2.FItemID,u2.FAuxPropID
                                       ) s4 on  s1.FStockId = s4.FStockID and s1.FItemID = s4.FItemID  and s1.FAuxPropID = s4.FAuxPropID 
                            ) a1 
                           GROUP BY a1.FItemID,a1.FAuxPropID,a1.FMTONo
              ) a  on a.FItemID=b.FItemID and  a.FAuxPropID=b.FAuxPropID AND a.FMTONo = b.FMTONo 
          WHERE f.FType=1
         GROUP BY b.FItemID,b.FAuxPropID,b.FMTONo,a.FQty 
    ) t1 on a.fitemid=t1.fitemid  AND t60.FAuxPropID=t1.FAuxPropID  
    LEFT JOIN t_AuxItem taux On t1.FAuxPropID=taux.FItemID
) --WHERE a.FItemID=3520
 tt ORDER BY FNumber,FAuxPropID,FPlanMode


SELECT a.*,b.FQtyDecimal,0 FTotalATPQty,t51.FCoefficient
 ,isnull((case a.FISOldData when 0 then a4.FKillQty else a.FKillQty end),0) FKillQtyPre
 , isnull((case a.FISOldData when 0 then a4.FNeedQty else a.FNeedQty end),0) FNeedQtyPre
 ,isnull((case a.FISOldData when 0 then a4.FWillInQty else a.FWillInQty end),0) FWillInQtyPre
 ,(case a.FISOldData when 0 then isnull(a3.FHaveOrderQty,0) else 0 end) FHaveOrderQty 
  ,0 as FCUTotalATPQty 
 ,isnull((case a.FISOldData when 0 then a4.FKillQty else a.FKillQty end),0)/t51.FCoefficient FCUKillQtyPre
 ,isnull((case a.FISOldData when 0 then a4.FNeedQty else a.FNeedQty end),0)/t51.FCoefficient as  FCUNeedQtyPre
 ,isnull((case a.FISOldData when 0 then a4.FWillInQty else a.FWillInQty end),0)/t51.FCoefficient as FCUWillInQtyPre
 ,(case a.FISOldData when 0 then isnull(a3.FHaveOrderQty,0) else 0 end)/t51.FCoefficient FCUHaveOrderQty
 ,a.FBeginStockQty/t51.FCoefficient as FCUBeginStockQty,a.FNeedQty/t51.FCoefficient as FCUNeedQty
 ,a.FWillOutQty/t51.FCoefficient as FCUWillOutQty,a.FWillInQty/t51.FCoefficient as FCUWillInQty
 ,a.FFactNeedQty/t51.FCoefficient as FCUFactNeedQty,a.FPlanOrderQty/t51.FCoefficient as FCUPlanOrderQty
 ,a.FWillStockQty/t51.FCoefficient as FCUWillStockQty 
 ,IsNull(a4.FAdjusted,0) as FAdjusted 
 ,Convert(varchar(10),a.FNeedDate,121) + (Case When IsNull(a4.FAdjusted,0) = 0 then '' else '(*)' end) as FNeedDateAdj
 into #body
FROM IC_PLMRPDetail a
Inner join t_ICItem b on a.FItemID = b.FItemID 
inner join t_MeasureUnit t51 on b.FProductUnitID=t51.FItemID
left outer join
(  select sum(isnull(a1.FHaveOrderQty,0)) as FHaveOrderQty,a1.fneeddate,a1.FMTONo 
   from icmrpresult a1 
   left join ICMrpInfo f on a1.FRunID=f.FInterID 
   where a1.FType=0 and f.FType=1 and a1.fitemid=3096 and a1.FAuxPropID=0 and a1.FRunID=212
   group by a1.fneeddate,a1.FMTONo) a3 on a.fneeddate=a3.fneeddate and a.FMTONo=a3.FMTONo
left outer join 
 (  select fitemid,FAuxPropID,FNeedDate,sum(FKillQty) FKillQty,sum(FNeedQty) FNeedQty,sum(FWillInQty) FWillInQty
             ,(Case When IsNull(Sum(Case When FBillType >= 1 and FBillType <= 15 and FBillType <> 3 then FAdjustID else 0 end),0) > 0 then 1 else 0 end) as FAdjusted 
    from ic_plmrpdetail where fbilltype<>1000 and FIsOlddata=0 and FAuxPropID=0 and FMTONo='' -- and fitemid=3096
    group by fneeddate,fitemid,FAuxPropID 
  ) a4  on a.fitemid=a4.fitemid and a.FAuxPropID=a4.FAuxPropID and  a.fneeddate=a4.fneeddate and a.FIsOldData = 0
Where a.FAuxPropID=0 and a.FMTONo=''  and a.FBillType=1000 AND a.FBatchSplitOrder = 1059
  and a.FISOldData in (0,2)  and a.FNeedDate between @startdate and @enddate-- a.fitemid=3096 and  
  order by a.FNeedDate,a.FISOldData desc

  --select * from #head where fitemid=3096
  --select * from #body where fitemid=3096

  select row_number() OVER (PARTITION BY a.FItemID ORDER BY FNeedDate) fno,
  row_number() OVER (PARTITION BY a.FItemID ORDER BY FNeedDate desc) fnodesc,
  a.FItemID 物料ID,a.FNumber 物料代码,a.FName 物料名称,a.FModel 规格型号,a.FPlanMode 计划模式,a.FMTONo 计划跟踪号
  ,a.FUnitID 计量单位,a.FSecInv 安全库存,a.FQty 即时库存,a.FOrderTrategy 订货策略,a.FLeadTime 变动提前期,a.FFixLeadTime 固定提前期,
  a.FBatChangeEconomy 变动提前期批量,a.FBatchAppendQty 批量增量,a.FQtyMin 最小订货量 ,a.FMaxQty 最大订货量,a.FBomNumber BOM编号,
  CONVERT(nvarchar(10),b.FNeedDate,102) 日期,b.FBeginStockQty [期初库存-可用库存],FQty_Inv_Lock [期初库存-预留库存],
  FQty_In_Plan [预计入库-计划],FQty_In_OnDo [预计入库-在制],FQty_In_Prep [预计入库-在检],FQty_In_Repl [预计入库-被替代],FStockInQty [预计入库-库存调入],
  FQty_Out_Delay [已分配量-拖期销售],FQty_Out_Plan [已分配量-计划],FQty_Out_Task [已分配量-任务],FQty_Out_Repl [已分配量-替代他料],FQty_Out_Lock [已分配量-锁库],FStockOutQty [已分配量-库存调出],
  FQty_Req_Fore [毛需求-预测],FQty_Req_Sale [毛需求-销售],FQty_Req_Rela [毛需求-相关],
  FMRPLockQty 锁单冲销量,FFactNeedQty 净需求,FPlanOrderQty 计划订单量,FWillStockQty 剩余库存
  ,d.FBLQty 不良品数量,E.FDGQty 代管仓数量
  into #sum 
  from #head a inner join #body b on a.FItemID=b.FItemID 
  left join t_ICItem c on a.FItemID=c.FItemID
  left join (select FItemID,sum(FQty)FBLQty from ICInventory where FStockID in(282)group by FItemID )d on a.FItemID=d.FItemID
  left join (select FItemID,sum(FQty)FDGQty from ICInventory where FStockID in(4233)group by FItemID )e on a.FItemID=e.FItemID
  where c.FNumber between @itemstart and @itemend 

   --select * from t_TableDescription where FDescription like '%单位%'
   --select * from t_FieldDescription where FTableID=17 and FDescription like '%单位%'
   --select b.FName,d.FName,E.FName from t_ICItem a inner join t_MeasureUnit b on a.FProductUnitID=b.FItemID 
   --LEFT join t_MeasureUnit d on a.FUnitID=d.FItemID
   --LEFT join t_MeasureUnit e on a.FCUUnitID=e.FItemID
   --where a.FNumber='04.02060001'
   --FProductUnitID   生产计量单位    
    
--select a.FProcessID,b.FItemID,ic.FName,sum(b.FQtyAct) pdqckc,a.FDate
--into #qcstock
--from icstockcheckprocess a 
--inner join ICInvBackup b on a.FID=b.FInterID
--inner join t_ICItem ic on ic.FItemID=b.FItemID
--where CONVERT(varchar(7),a.FDate,120)=CONVERT(varchar(7), dateadd(mm,-1,GETDATE()),120)
--group by a.FProcessID,b.FItemID,ic.FName,a.FDate
--order by b.FItemID
--盘点实存数量

  Select
[FYear]
      ,[FPeriod]
      ,j.FNumber
	  ,ic.FItemID
      ,sum(isnull([FBegQty],0))FBegQty
      ,sum(isnull([FBegBal],0))FBegBal
	  into #qcstock
 From ICInvBal ic
 Left Join t_Stock t on t.FItemid=ic.FStockID
  inner join t_ICItem j on ic.FItemID=j.FItemID
  where  FYear=YEAR(GETDATE()) and	FPeriod=@KJQJ --当前月份前一期
  and t.FTypeID not in(501,502,503,504) and FStockID not in (4233,282,283)
  group by [FYear]
      ,[FPeriod]
      ,j.FNumber
	  ,ic.FItemID


   select 
   日期 期初日期,物料ID,[期初库存-可用库存],[期初库存-预留库存]
   into #tab1
   from #sum  where fno=1

   
   select 
   日期 剩余库存日期,物料ID,剩余库存
   into #tab2
   from #sum  where fnodesc=1


   select    
   a.物料ID 期初物料ID,[期初库存-可用库存], 剩余库存日期,b.物料ID 剩余库存物料ID,剩余库存,a.[期初库存-预留库存]
   into #stock
   from  #tab1 a inner join #tab2 b on a.物料ID=b.物料ID 
 
 --  mrpdetail '','','','',''

   select 
    物料ID, 物料代码, 物料名称, 规格型号, 计划模式, 计划跟踪号
  , 计量单位, 安全库存, 即时库存, 订货策略, 变动提前期, 固定提前期,
   变动提前期批量, 批量增量, 最小订货量 , 最大订货量, BOM编号,
   sum(isnull([预计入库-计划],0)) [预计入库-计划], sum(isnull([预计入库-在制],0)) [预计入库-在制],
   sum(isnull( [预计入库-在检],0))[预计入库-在检],sum(isnull( [预计入库-被替代],0)) [预计入库-被替代],
   sum(isnull([预计入库-库存调入],0)) [预计入库-库存调入], sum(isnull([已分配量-拖期销售],0)) [已分配量-拖期销售],
   sum(isnull([已分配量-计划],0)) [已分配量-计划], sum(isnull([已分配量-任务],0)) [已分配量-任务],
   sum(isnull([已分配量-替代他料],0)) [已分配量-替代他料], sum(isnull([已分配量-锁库],0)) [已分配量-锁库],
   sum(isnull([已分配量-库存调出],0)) [已分配量-库存调出], sum(isnull([毛需求-预测],0))[毛需求-预测], 
   sum(isnull([毛需求-销售],0))[毛需求-销售], sum(isnull([毛需求-相关],0))[毛需求-相关],
   锁单冲销量
   ,isnull(不良品数量,0) 不良品数量,isnull(代管仓数量,0)代管仓数量
   into #count
   from #sum
   group by 物料ID, 物料代码, 物料名称, 规格型号, 计划模式, 计划跟踪号
  , 计量单位, 安全库存, 即时库存, 订货策略, 变动提前期, 固定提前期,
   变动提前期批量, 批量增量, 最小订货量 , 最大订货量
   , BOM编号,锁单冲销量,不良品数量,代管仓数量
   order by 物料代码

   update a  set
    [毛需求-销售]=0,[预计入库-计划]=0,[预计入库-在制]=0,
	[预计入库-在检]=0,[预计入库-被替代]=0,[预计入库-库存调入]=0
	,[已分配量-拖期销售]=0,[已分配量-计划]=0,[已分配量-任务]=0
	,[已分配量-替代他料]=0,[已分配量-锁库]=0,[已分配量-库存调出]=0
	,[毛需求-预测]=0,[毛需求-相关]=0
	from #count a  where 物料代码 like '01.%'

     select wlID,count(*) bywllcp,SUM(SCSL) BYJHSL
	into #cpql1
	 from 
  (
  select d.FNumber,d.FItemID wlID,d.FName cpwl,
  CONVERT(varchar(7), a.FPlanCommitDate, 120) FPlanCommitDate 
  ,a.FBillNo RWNO,b.FBillNo TLNO,a.FAuxQty SCSL
  from ICMO a inner join PPBOM b on a.FInterID=b.FICMOInterID 
  left join PPBOMEntry  c on b.FInterID=c.FInterID 
  left join t_ICItem d on a.FItemID=d.FItemID
  where c.FAuxQtyPick-c.FAuxStockQty>0 
  and CONVERT(varchar(7),a.FPlanCommitDate,120)<=CONVERT(varchar(7), GETDATE(),120) 
  and a.FStatus  in (5)
  group by a.FBillNo,b.FBillNo,a.FPlanCommitDate,d.FName,d.FItemID,a.FAuxQty,d.FNumber
  )a
  group by wlID

   select wlID,count(*) xywllcp,SUM(SCSL) XYJHSL
   into #cpql2
   from 
  (
  select d.FItemID wlID,d.FName cpwl,
  CONVERT(varchar(7),a.FPlanCommitDate,120) FPlanCommitDate ,
  a.FBillNo RWNO,b.FBillNo TLNO,a.FAuxQty SCSL
  from ICMO a inner join PPBOM b on a.FInterID=b.FICMOInterID 
  left join PPBOMEntry  c on b.FInterID=c.FInterID 
  left join t_ICItem d on a.FItemID=d.FItemID
  where c.FAuxQtyPick-c.FAuxStockQty>0 
  and CONVERT(varchar(7),a.FPlanCommitDate,120)=CONVERT(varchar(7), dateadd(mm,1,GETDATE()),120) 
  and a.FStatus in (5)
  group by a.FBillNo,b.FBillNo,a.FPlanCommitDate,d.FName,d.FItemID,a.FAuxQty
  )a
  group by wlID


   select wlID,count(*) cywllcp,SUM(SCSL) CYJHSL
   into #cpql3
   from 
  (
  select d.FItemID wlID,d.FName cpwl
  ,CONVERT(varchar(7),a.FPlanCommitDate,120) FPlanCommitDate
  ,a.FBillNo RWNO,b.FBillNo TLNO,a.FAuxQty SCSL
  from ICMO a inner join PPBOM b on a.FInterID=b.FICMOInterID 
  left join PPBOMEntry  c on b.FInterID=c.FInterID 
  left join t_ICItem d on a.FItemID=d.FItemID
  where c.FAuxQtyPick-c.FAuxStockQty>0 
  and CONVERT(varchar(7),a.FPlanCommitDate,120)=CONVERT(varchar(7),dateadd(mm,2,GETDATE()),120) 
  and a.FStatus in (5)
  group by a.FBillNo,b.FBillNo,a.FPlanCommitDate,d.FName,d.FItemID,a.FAuxQty
  )a
  group by wlID

   select 
   a.*,isnull(f.FBegQty,0)期初库存, b.[期初库存-可用库存],b.剩余库存,b.剩余库存日期,
   b.[期初库存-预留库存],BYJHSL,XYJHSL,CYJHSL
   ,k.FName 基本单位,l.FName mrp单位--,b.[期初库存-可用库存]
   into #summary
   from #count a left join #stock b on a.物料ID=b.期初物料ID
   left join #cpql1 c on a.物料ID=c.wlID
   left join #cpql2 d on a.物料ID=d.wlID
   left join #cpql3 e on a.物料ID=e.wlID
   left join #qcstock f on a.物料ID=f.FItemID
   left join t_ICItem j on a.物料ID=j.FItemID
   LEFT join t_MeasureUnit k on j.FUnitID=k.FItemID
   LEFT join t_MeasureUnit l on j.FProductUnitID=l.FItemID

   

  select 
  剩余库存日期,物料代码, 物料名称, 规格型号,[期初库存-可用库存] 期初库存可用库存,
  [期初库存-预留库存] 期初库存预留库存,即时库存,[毛需求-预测] 毛需求预测,[毛需求-销售] 毛需求销售,
  [毛需求-相关] 毛需求相关,[已分配量-拖期销售] 已分配量拖期销售,[已分配量-计划] 已分配量计划,
  [已分配量-任务] 已分配量任务,[已分配量-库存调出] 已分配量库存调出,[预计入库-计划] 预计入库计划,
  [预计入库-在制] [预计入库在途/在制],isnull(BYJHSL,0) 当月计划未领料机型,isnull(XYJHSL,0) 下月计划未领料机型
  ,isnull(CYJHSL,0) 次月计划未领料机型,isnull(BYJHSL,0)+isnull(XYJHSL,0)+isnull(CYJHSL,0) 整机汇总,
  case when 
  ([毛需求-预测]+[毛需求-销售]+[毛需求-相关]+[已分配量-拖期销售]+[已分配量-计划]
  +[已分配量-任务]+[已分配量-库存调出]-[预计入库-在制]-[预计入库-计划]-[期初库存-可用库存]-[期初库存-预留库存])<=0  then 0 
  else ([毛需求-预测]+[毛需求-销售]+[毛需求-相关]+[已分配量-拖期销售]+[已分配量-计划]
  +[已分配量-任务]+[已分配量-库存调出]-[预计入库-在制]-[预计入库-计划]-[期初库存-可用库存]-[期初库存-预留库存]) end 净需求,
  case when ([毛需求-预测]+[毛需求-销售]+[毛需求-相关]+[已分配量-拖期销售]+[已分配量-计划]
  +[已分配量-任务]+[已分配量-库存调出]-[预计入库-在制]-[预计入库-计划]-[期初库存-可用库存]-[期初库存-预留库存])<=0 then 
  -([毛需求-预测]+[毛需求-销售]+[毛需求-相关]+[已分配量-拖期销售]+[已分配量-计划]
  +[已分配量-任务]+[已分配量-库存调出]-[预计入库-在制]-[预计入库-计划]-[期初库存-可用库存]-[期初库存-预留库存])
  else 0 end 剩余库存,
  不良品数量,最小订货量,最大订货量,安全库存,
  [已分配量-计划]+[已分配量-任务] 已分配量,
  [毛需求-相关]+[毛需求-销售]+[已分配量-计划]+[已分配量-任务]+[已分配量-拖期销售] 毛需求汇总
  ,基本单位,mrp单位,期初库存,代管仓数量
  into #result
  from #summary

  
     --  mrpdetail '02.04050008','','','','7'
  
  select  剩余库存日期,物料代码, 物料名称, 规格型号,mrp单位,
   当月计划未领料机型,下月计划未领料机型,次月计划未领料机型,整机汇总,
   期初库存,基本单位,即时库存,毛需求相关 [毛需求预测+销售],毛需求销售 售后耗材需求, 已分配量拖期销售 售后拖期物料,
   已分配量,毛需求汇总, 预计入库计划 申请未采购--已分配量计划, 已分配量任务, 已分配量库存调出,
   ,[预计入库在途/在制],净需求,净需求 计划订单量,剩余库存,
  代管仓数量,不良品数量,最小订货量,最大订货量,安全库存
  from #result 
  order by 物料代码,剩余库存日期


  --select * from t_TableDescription where FDescription like '%方案%'
  --select * from t_FieldDescription where FTableID=470000 and FDescription like '%数量%'

  drop table #head
  drop table #body
  drop table #tab1
  drop table #sum 
  drop table #stock
  drop table #count
  drop table #result
  drop table #summary
  drop table #tab2
  drop table #cpql1
  drop table #cpql2
  drop table #cpql3
  drop table #qcstock
  end 