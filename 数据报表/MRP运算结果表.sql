

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
             ,t1.FMTONo,(CASE ISNULL(t1.FMTONo,'') WHEN '' THEN 'MTS�ƻ�ģʽ' ELSE 'MTO�ƻ�ģʽ' END) FPlanMode 
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
  a.FItemID ����ID,a.FNumber ���ϴ���,a.FName ��������,a.FModel ����ͺ�,a.FPlanMode �ƻ�ģʽ,a.FMTONo �ƻ����ٺ�
  ,a.FUnitID ������λ,a.FSecInv ��ȫ���,a.FQty ��ʱ���,a.FOrderTrategy ��������,a.FLeadTime �䶯��ǰ��,a.FFixLeadTime �̶���ǰ��,
  a.FBatChangeEconomy �䶯��ǰ������,a.FBatchAppendQty ��������,a.FQtyMin ��С������ ,a.FMaxQty ��󶩻���,a.FBomNumber BOM���,
  CONVERT(nvarchar(10),b.FNeedDate,102) ����,b.FBeginStockQty [�ڳ����-���ÿ��],FQty_Inv_Lock [�ڳ����-Ԥ�����],
  FQty_In_Plan [Ԥ�����-�ƻ�],FQty_In_OnDo [Ԥ�����-����],FQty_In_Prep [Ԥ�����-�ڼ�],FQty_In_Repl [Ԥ�����-�����],FStockInQty [Ԥ�����-������],
  FQty_Out_Delay [�ѷ�����-��������],FQty_Out_Plan [�ѷ�����-�ƻ�],FQty_Out_Task [�ѷ�����-����],FQty_Out_Repl [�ѷ�����-�������],FQty_Out_Lock [�ѷ�����-����],FStockOutQty [�ѷ�����-������],
  FQty_Req_Fore [ë����-Ԥ��],FQty_Req_Sale [ë����-����],FQty_Req_Rela [ë����-���],
  FMRPLockQty ����������,FFactNeedQty ������,FPlanOrderQty �ƻ�������,FWillStockQty ʣ����
  ,d.FBLQty ����Ʒ����,E.FDGQty ���ܲ�����
  into #sum 
  from #head a inner join #body b on a.FItemID=b.FItemID 
  left join t_ICItem c on a.FItemID=c.FItemID
  left join (select FItemID,sum(FQty)FBLQty from ICInventory where FStockID in(282)group by FItemID )d on a.FItemID=d.FItemID
  left join (select FItemID,sum(FQty)FDGQty from ICInventory where FStockID in(4233)group by FItemID )e on a.FItemID=e.FItemID
  where c.FNumber between @itemstart and @itemend 

   --select * from t_TableDescription where FDescription like '%��λ%'
   --select * from t_FieldDescription where FTableID=17 and FDescription like '%��λ%'
   --select b.FName,d.FName,E.FName from t_ICItem a inner join t_MeasureUnit b on a.FProductUnitID=b.FItemID 
   --LEFT join t_MeasureUnit d on a.FUnitID=d.FItemID
   --LEFT join t_MeasureUnit e on a.FCUUnitID=e.FItemID
   --where a.FNumber='04.02060001'
   --FProductUnitID   ����������λ    
    
--select a.FProcessID,b.FItemID,ic.FName,sum(b.FQtyAct) pdqckc,a.FDate
--into #qcstock
--from icstockcheckprocess a 
--inner join ICInvBackup b on a.FID=b.FInterID
--inner join t_ICItem ic on ic.FItemID=b.FItemID
--where CONVERT(varchar(7),a.FDate,120)=CONVERT(varchar(7), dateadd(mm,-1,GETDATE()),120)
--group by a.FProcessID,b.FItemID,ic.FName,a.FDate
--order by b.FItemID
--�̵�ʵ������

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
  where  FYear=YEAR(GETDATE()) and	FPeriod=@KJQJ --��ǰ�·�ǰһ��
  and t.FTypeID not in(501,502,503,504) and FStockID not in (4233,282,283)
  group by [FYear]
      ,[FPeriod]
      ,j.FNumber
	  ,ic.FItemID


   select 
   ���� �ڳ�����,����ID,[�ڳ����-���ÿ��],[�ڳ����-Ԥ�����]
   into #tab1
   from #sum  where fno=1

   
   select 
   ���� ʣ��������,����ID,ʣ����
   into #tab2
   from #sum  where fnodesc=1


   select    
   a.����ID �ڳ�����ID,[�ڳ����-���ÿ��], ʣ��������,b.����ID ʣ��������ID,ʣ����,a.[�ڳ����-Ԥ�����]
   into #stock
   from  #tab1 a inner join #tab2 b on a.����ID=b.����ID 
 
 --  mrpdetail '','','','',''

   select 
    ����ID, ���ϴ���, ��������, ����ͺ�, �ƻ�ģʽ, �ƻ����ٺ�
  , ������λ, ��ȫ���, ��ʱ���, ��������, �䶯��ǰ��, �̶���ǰ��,
   �䶯��ǰ������, ��������, ��С������ , ��󶩻���, BOM���,
   sum(isnull([Ԥ�����-�ƻ�],0)) [Ԥ�����-�ƻ�], sum(isnull([Ԥ�����-����],0)) [Ԥ�����-����],
   sum(isnull( [Ԥ�����-�ڼ�],0))[Ԥ�����-�ڼ�],sum(isnull( [Ԥ�����-�����],0)) [Ԥ�����-�����],
   sum(isnull([Ԥ�����-������],0)) [Ԥ�����-������], sum(isnull([�ѷ�����-��������],0)) [�ѷ�����-��������],
   sum(isnull([�ѷ�����-�ƻ�],0)) [�ѷ�����-�ƻ�], sum(isnull([�ѷ�����-����],0)) [�ѷ�����-����],
   sum(isnull([�ѷ�����-�������],0)) [�ѷ�����-�������], sum(isnull([�ѷ�����-����],0)) [�ѷ�����-����],
   sum(isnull([�ѷ�����-������],0)) [�ѷ�����-������], sum(isnull([ë����-Ԥ��],0))[ë����-Ԥ��], 
   sum(isnull([ë����-����],0))[ë����-����], sum(isnull([ë����-���],0))[ë����-���],
   ����������
   ,isnull(����Ʒ����,0) ����Ʒ����,isnull(���ܲ�����,0)���ܲ�����
   into #count
   from #sum
   group by ����ID, ���ϴ���, ��������, ����ͺ�, �ƻ�ģʽ, �ƻ����ٺ�
  , ������λ, ��ȫ���, ��ʱ���, ��������, �䶯��ǰ��, �̶���ǰ��,
   �䶯��ǰ������, ��������, ��С������ , ��󶩻���
   , BOM���,����������,����Ʒ����,���ܲ�����
   order by ���ϴ���

   update a  set
    [ë����-����]=0,[Ԥ�����-�ƻ�]=0,[Ԥ�����-����]=0,
	[Ԥ�����-�ڼ�]=0,[Ԥ�����-�����]=0,[Ԥ�����-������]=0
	,[�ѷ�����-��������]=0,[�ѷ�����-�ƻ�]=0,[�ѷ�����-����]=0
	,[�ѷ�����-�������]=0,[�ѷ�����-����]=0,[�ѷ�����-������]=0
	,[ë����-Ԥ��]=0,[ë����-���]=0
	from #count a  where ���ϴ��� like '01.%'

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
   a.*,isnull(f.FBegQty,0)�ڳ����, b.[�ڳ����-���ÿ��],b.ʣ����,b.ʣ��������,
   b.[�ڳ����-Ԥ�����],BYJHSL,XYJHSL,CYJHSL
   ,k.FName ������λ,l.FName mrp��λ--,b.[�ڳ����-���ÿ��]
   into #summary
   from #count a left join #stock b on a.����ID=b.�ڳ�����ID
   left join #cpql1 c on a.����ID=c.wlID
   left join #cpql2 d on a.����ID=d.wlID
   left join #cpql3 e on a.����ID=e.wlID
   left join #qcstock f on a.����ID=f.FItemID
   left join t_ICItem j on a.����ID=j.FItemID
   LEFT join t_MeasureUnit k on j.FUnitID=k.FItemID
   LEFT join t_MeasureUnit l on j.FProductUnitID=l.FItemID

   

  select 
  ʣ��������,���ϴ���, ��������, ����ͺ�,[�ڳ����-���ÿ��] �ڳ������ÿ��,
  [�ڳ����-Ԥ�����] �ڳ����Ԥ�����,��ʱ���,[ë����-Ԥ��] ë����Ԥ��,[ë����-����] ë��������,
  [ë����-���] ë�������,[�ѷ�����-��������] �ѷ�������������,[�ѷ�����-�ƻ�] �ѷ������ƻ�,
  [�ѷ�����-����] �ѷ���������,[�ѷ�����-������] �ѷ�����������,[Ԥ�����-�ƻ�] Ԥ�����ƻ�,
  [Ԥ�����-����] [Ԥ�������;/����],isnull(BYJHSL,0) ���¼ƻ�δ���ϻ���,isnull(XYJHSL,0) ���¼ƻ�δ���ϻ���
  ,isnull(CYJHSL,0) ���¼ƻ�δ���ϻ���,isnull(BYJHSL,0)+isnull(XYJHSL,0)+isnull(CYJHSL,0) ��������,
  case when 
  ([ë����-Ԥ��]+[ë����-����]+[ë����-���]+[�ѷ�����-��������]+[�ѷ�����-�ƻ�]
  +[�ѷ�����-����]+[�ѷ�����-������]-[Ԥ�����-����]-[Ԥ�����-�ƻ�]-[�ڳ����-���ÿ��]-[�ڳ����-Ԥ�����])<=0  then 0 
  else ([ë����-Ԥ��]+[ë����-����]+[ë����-���]+[�ѷ�����-��������]+[�ѷ�����-�ƻ�]
  +[�ѷ�����-����]+[�ѷ�����-������]-[Ԥ�����-����]-[Ԥ�����-�ƻ�]-[�ڳ����-���ÿ��]-[�ڳ����-Ԥ�����]) end ������,
  case when ([ë����-Ԥ��]+[ë����-����]+[ë����-���]+[�ѷ�����-��������]+[�ѷ�����-�ƻ�]
  +[�ѷ�����-����]+[�ѷ�����-������]-[Ԥ�����-����]-[Ԥ�����-�ƻ�]-[�ڳ����-���ÿ��]-[�ڳ����-Ԥ�����])<=0 then 
  -([ë����-Ԥ��]+[ë����-����]+[ë����-���]+[�ѷ�����-��������]+[�ѷ�����-�ƻ�]
  +[�ѷ�����-����]+[�ѷ�����-������]-[Ԥ�����-����]-[Ԥ�����-�ƻ�]-[�ڳ����-���ÿ��]-[�ڳ����-Ԥ�����])
  else 0 end ʣ����,
  ����Ʒ����,��С������,��󶩻���,��ȫ���,
  [�ѷ�����-�ƻ�]+[�ѷ�����-����] �ѷ�����,
  [ë����-���]+[ë����-����]+[�ѷ�����-�ƻ�]+[�ѷ�����-����]+[�ѷ�����-��������] ë�������
  ,������λ,mrp��λ,�ڳ����,���ܲ�����
  into #result
  from #summary

  
     --  mrpdetail '02.04050008','','','','7'
  
  select  ʣ��������,���ϴ���, ��������, ����ͺ�,mrp��λ,
   ���¼ƻ�δ���ϻ���,���¼ƻ�δ���ϻ���,���¼ƻ�δ���ϻ���,��������,
   �ڳ����,������λ,��ʱ���,ë������� [ë����Ԥ��+����],ë�������� �ۺ�Ĳ�����, �ѷ������������� �ۺ���������,
   �ѷ�����,ë�������, Ԥ�����ƻ� ����δ�ɹ�--�ѷ������ƻ�, �ѷ���������, �ѷ�����������,
   ,[Ԥ�������;/����],������,������ �ƻ�������,ʣ����,
  ���ܲ�����,����Ʒ����,��С������,��󶩻���,��ȫ���
  from #result 
  order by ���ϴ���,ʣ��������


  --select * from t_TableDescription where FDescription like '%����%'
  --select * from t_FieldDescription where FTableID=470000 and FDescription like '%����%'

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