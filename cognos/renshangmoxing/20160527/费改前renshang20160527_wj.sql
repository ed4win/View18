#:<<block
dbaccess  -e gd4400car3gdb <<!
select a.comcode,a.proposalno,a.policyno, a.sumpremium, 
case when '2015-05-31'>=a.enddate 
then a.sumpremium 
else a.sumpremium*('2015-05-31'-a.startdate+1)/(a.enddate-a.startdate+1)
end premium_yz , 
---截止提数时间已赚签单保费
e.agenttype, a.agentcode, 
 b.clausetype,  b.carkindcode, b.useyears,  b.enrolldate,  --初登日期
       a.startdate,   --起保日期
       a.enddate,     --终保日期
       b.licenseno,   --号牌号码
       b.licensecolorcode, --号牌底色
       b.engineno,    
       b.frameno,
       handler1code,     --归属人员
       handlercode,      --经办人员
       businessnature,   --业务来源
       case when length(contractno) = 22 then '车队'
            else '单车' end as policytype,         --保单种类
       case when underwriteflag = '3' then '自动'
            else '人工' end as uwtype,             --核保方式
       operatedate,   --签单日期
       sumamount,     --保险金额
       a.riskcode,    --承保险种
       a.contractno,  --团单号/合同号
       licensetype,   --号牌种类
       --vinno,
       usenaturecode, --使用性质
       runmiles,
       modelcode,     --车型代码
       brandname,     --车型名称
       purchaseprice, --新车购置价
       actualvalue,   --实际价值
       seatcount,     --载客数
       toncount,      --载质量
       exhaustscale,  --排量
       runareaname,   --行驶区域
       MonopolyCode,  --送修码
       projectcode,   --项目代码
       case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --交强商业标记
       b.flag[5] dxflag,   --电销业务类型标记位

0.00::decimal(20,2) B050100,--机动车交通事故强制责任保险
0.00::decimal(20,3) B050200,--机动车损失保险
0.00::decimal(20,4) B050500,--盗抢险
0.00::decimal(20,5) B050600,--第三者责任保险
0.00::decimal(20,6) B050701,--车上人员责任险（司机）
0.00::decimal(20,7) B050702,--车上人员责任险（乘客）
0.00::decimal(20,8) B050911,--不计免赔率（车损险）
0.00::decimal(20,9) B050912,--不计免赔率（三者险）
0.00::decimal(20,10) B050921,--不计免赔率（机动车盗抢险）
0.00::decimal(20,11) B050928,--不计免赔率（车上人员责任险（司机））
0.00::decimal(20,12) B050929,--不计免赔率（车上人员责任险（乘客））  

       case when d.CarChecker="" then "没有填"
            else d.CarChecker
       end CarChecker
from prpcmain a,prpcitem_car  b,
     outer prpcmain_car d, outer gd4400dms3gdb:prpdagent e
where 1=1
and a.startdate between '20150101' and '2015-05-31'
and a.proposalno=b.proposalno
and length(a.policyno) = 22
and a.comcode[1,4] = '4418' --清远
and a.policyno[1]='P'
and a.othflag[4]<>"1"           --非注销
and a.othflag[4]<>"2"           --非删除
and b.UseNatureCode='120' 
and a.proposalno=d.proposalno
and a.agentcode=e.agentcode
into temp chengbao_qibao with no log;


unload to 'chengbao_qibao_first.unl'
select * from chengbao_qibao where 1=1;




create index idx1 on chengbao_qibao(proposalno) ;


update statistics for table chengbao_qibao;

select x.proposalno, x.kindcode,x.premium
from prpcitemkind x,chengbao_qibao y
where y.proposalno = x.proposalno
into temp t_itemkind with no log;



create index idx2 on t_itemkind(proposalno) ;

create index idx3 on t_itemkind(kindcode) ;

update statistics for table t_itemkind;



merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050100' when matched then update set a.B050100= b.premium;--机动车交通事故强制责任保险
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050200' when matched then update set a.B050200= b.premium;--机动车损失保险
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050500' when matched then update set a.B050500= b.premium;--盗抢险
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050600' when matched then update set a.B050600= b.premium;--第三者责任保险
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050701' when matched then update set a.B050701= b.premium;--车上人员责任险（司机）
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050702' when matched then update set a.B050702= b.premium;--车上人员责任险（乘客）
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050911' when matched then update set a.B050911= b.premium;--不计免赔率（车损险）
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050912' when matched then update set a.B050912= b.premium;--不计免赔率（三者险）
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050921' when matched then update set a.B050921= b.premium;--不计免赔率（机动车盗抢险）
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050928' when matched then update set a.B050928= b.premium;--不计免赔率（车上人员责任险（司机））
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050929' when matched then update set a.B050929= b.premium;--不计免赔率（车上人员责任险（乘客））



-- --计算个险别已赚保费 ---
update chengbao_qibao set B050100=B050100*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--机动车交通事故强制责任保险
update chengbao_qibao set B050200=B050200*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--机动车损失保险
update chengbao_qibao set B050500=B050500*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--盗抢险
update chengbao_qibao set B050600=B050600*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--第三者责任保险
update chengbao_qibao set B050701=B050701*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--车上人员责任险（司机）
update chengbao_qibao set B050702=B050702*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--车上人员责任险（乘客）
update chengbao_qibao set B050911=B050911*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--不计免赔率（车损险）
update chengbao_qibao set B050912=B050912*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--不计免赔率（三者险）
update chengbao_qibao set B050921=B050921*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--不计免赔率（机动车盗抢险）
update chengbao_qibao set B050928=B050928*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--不计免赔率（车上人员责任险（司机））
update chengbao_qibao set B050929=B050929*('2015-05-31'-startdate+1)/(enddate-startdate+1) where '2015-05-31' < enddate;--不计免赔率（车上人员责任险（乘客））



unload to 'chengbao_qibao.unl'
select * from chengbao_qibao where 1=1;

!
block


dbaccess -e $_LPDB <<!
select a.comcode,     --归属机构
       a.proposalno,
       a.policyno,    --保单号
       a.sumpremium,  --应交保费
	   a.sumpremium premium_yz ,--已赚保费
       e.agenttype,   --渠道类型
       a.agentcode,   --渠道代码
       b.clausetype,  --条款产品
       b.carkindcode, --车辆种类
       b.useyears,    --使用年限
       b.enrolldate,  --初登日期
       a.startdate,   --起保日期
       a.enddate,     --终保日期
       b.licenseno,   --号牌号码
       b.licensecolorcode, --号牌底色
       b.engineno,    
       b.frameno,
       handler1code,     --归属人员
       handlercode,      --经办人员
       businessnature,   --业务来源
       --case when length(contractno) = 22 then '车队'
            --else '单车' end as policytype,         --保单种类
       '                  ' policytype,
       --case when underwriteflag = '3' then '自动'
            --else '人工' end as uwtype,             --核保方式
	   '                    ' uwtype,
       operatedate,   --签单日期
       sumamount,     --保险金额
       a.riskcode,    --承保险种
       a.contractno,  --团单号/合同号
       licensetype,   --号牌种类
       --vinno,
       usenaturecode, --使用性质
       runmiles,
       modelcode,     --车型代码
       brandname,     --车型名称
       purchaseprice, --新车购置价
       actualvalue,   --实际价值
       seatcount,     --载客数
       toncount,      --载质量
       exhaustscale,  --排量
       runareaname,   --行驶区域
       MonopolyCode,  --送修码
       projectcode,   --项目代码
       --case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --交强商业标记
	   '     ' biciflag,
       b.flag[5] dxflag,   --电销业务类型标记位
	-------------------
0.00::decimal(20,2) B050100,--机动车交通事故强制责任保险
0.00::decimal(20,3) B050200,--机动车损失保险
0.00::decimal(20,4) B050500,--盗抢险
0.00::decimal(20,5) B050600,--第三者责任保险
0.00::decimal(20,6) B050701,--车上人员责任险（司机）
0.00::decimal(20,7) B050702,--车上人员责任险（乘客）
0.00::decimal(20,8) B050911,--不计免赔率（车损险）
0.00::decimal(20,9) B050912,--不计免赔率（三者险）
0.00::decimal(20,10) B050921,--不计免赔率（机动车盗抢险）
0.00::decimal(20,11) B050928,--不计免赔率（车上人员责任险（司机））
0.00::decimal(20,12) B050929,--不计免赔率（车上人员责任险（乘客））  
	   d.carchecker
from   gd4400car3gdb@gd_4400_cb_bcv1:prpcmain a,
       gd4400car3gdb@gd_4400_cb_bcv1:prpcitem_car  b,
   gd4400car3gdb@gd_4400_cb_bcv1:prpcmain_car d, 
       gd4400dms3gdb@gd_4400_cb_bcv1:prpdagent e
		--,gd4400car3gdb:prpcitemkind f
where 1 = 2
into temp chengbao_qibao with no log;

load from 'chengbao_qibao.unl'
insert into chengbao_qibao;






select policyno from chengbao_qibao
where 1=1
-- and policyno = 'PDZA201344180000056430'
into temp t_policyno with no log;

--------------------
----------保单 理赔信息未结合-----
--------------------

-----------未决案件清单----------------
select x.policyno, x.claimno,x.registno,x.SUMESTIPAID, 
'0' renshangflag,
'0' siwangflag,
'0' shangcanflag
from prplclaim x,t_policyno y
--,prplregist z -------------增加出险日期判断
where x.policyno = y.policyno
and x.canceldate is null
----------------------------------
and x.endcasedate is   null  ------未结案
--and z.registno = x.registno 
--and z.reportdate between '20150715' and '20150823'
into temp t_claim with no log;

update t_claim set renshangflag = '0',
siwangflag = '0' ,
shangcanflag = '0'
where 1=1;



-----判断人伤---------
select distinct x.claimno 
from t_claim x,prplbpmmain y
where y.businessno = x.registno
and y.nodeid = '500'
into temp t_rs with no log;

merge into t_claim x
using t_rs y
on (x.claimno= y.claimno)
when matched then update set x.renshangflag = '1'
;

drop table t_rs;

---------判断死亡-----------
select distinct y.claimno
from PrpLinjured x,t_claim y
where x.registno = y.registno
and x.woundcode in ('03','05')
into temp t_siwang with no log;


merge into t_claim x
using t_siwang y
on (x.claimno = y.claimno)
when matched then update 
set (x.siwangflag,x.renshangflag) = ('1','1');


drop table t_siwang;

--------判断伤残-----------

select distinct y.claimno
from PrpLinjured x,t_claim y
where x.registno = y.registno
and x.woundcode in ('02')
into temp t_shangchan with no log;


merge into t_claim x
using t_shangchan y
on (x.claimno = y.claimno ) 
when matched then update set (x.shangcanflag,x.renshangflag)= ('1','1');

drop table t_shangchan ;

--drop table 
select x.*,
	   y.feetype,y.feetypecode,
	   y.itemkindno,y.clausecode,
	   y.kindcode,y.itemcode,
	   y.sumclaim,-- 估损
	   y.estipaid ,--估赔
	   y.sumpaid,--险别已赔付金额
	   --y.outstanding, --险别未决赔款金额
	   y.sumrest --残值
from t_claim x,prplclaimfee y
where y.claimno = x.claimno
and y.validflag = '1'
into temp t_claimfee with  no log;




--select distinct kindcode from t_claimfee;
--select count(*) from t_claim;


select x.*,
0.00::decimal(20,2) lianshu,
0.00::decimal(20,2) renshangshu,
0.00::decimal(20,2) xiesishu,
0.00::decimal(20,2) xiecanshu,
0.00::decimal(20,2) z_peifu,
0.00::decimal(20,2) A050100,
0.00::decimal(20,2) A050200,
0.00::decimal(20,2) A050500,
0.00::decimal(20,2) A050600,
0.00::decimal(20,2) A050701,
0.00::decimal(20,2) A050702,
0.00::decimal(20,2) A050911,
0.00::decimal(20,2) A050912,
0.00::decimal(20,2) A050921,
0.00::decimal(20,2) A050928,
0.00::decimal(20,2) A050929,
'未结案'    endcasefalg  ---结案状态
from chengbao_qibao  x
where 1=1 into temp chengbao_list with no log;

-----------汇总立案数--------------
select policyno ,count(claimno) lianshu
from t_claim 
where 1=1 
group by policyno 
into temp t_lianshu with no log;

select distinct * from t_lianshu 
where 1=1 into temp t1 with no log;

merge into chengbao_list a
using t1 b 
on (a.policyno = b.policyno)
when matched then update set a.lianshu = b.lianshu;

drop table t_lianshu;
drop table t1;

-------汇总人伤案件数量-


select policyno ,count(claimno) lianshu_renshang
from t_claim 
where 1=1 
and renshangflag = '1'
group by policyno 
into temp t_lianshu_renshang with no log;

select distinct * from t_lianshu_renshang 
where 1=1 into temp t1 with no log;



merge into chengbao_list a
using t1 b 
on (a.policyno = b.policyno)
when matched then update set a.renshangshu = b.lianshu_renshang;

drop table t_lianshu_renshang;
drop table t1;
-----汇总伤残案件数量---

select policyno ,count(claimno) lianshu_renshang
from t_claim 
where 1=1 
and renshangflag = '1'
and shangcanflag = '1'
group by policyno 
into temp t_lianshu_renshang with no log;

select distinct * from t_lianshu_renshang 
where 1=1 into temp t1 with no log;


merge into chengbao_list a
using t1 b 
on (a.policyno = b.policyno)
when matched then update set a.xiecanshu = b.lianshu_renshang;

drop table t_lianshu_renshang;
drop table t1;
--------

unload to '人伤分析_claim_未决.unl'
select * from t_claim where 1=1;

-------汇总死亡数量-----

select policyno ,count(claimno) lianshu_renshang
from t_claim 
where 1=1 
and renshangflag = '1'
and siwangflag = '1'
group by policyno 
into temp t_lianshu_renshang with no log;

select distinct * from t_lianshu_renshang 
where 1=1 into temp t1 with no log;

merge into chengbao_list a
using t1 b
on a.policyno = b.policyno
when matched then update set a.xiesishu= b.lianshu_renshang;

drop table t_lianshu_renshang;
drop table t1;

--------
----------总赔付金额汇总---------
--drop table t_sumpaid;
select x.policyno,x.claimno,y.sumestipaid
from t_claim x,prplclaim y
where y.claimno = x.claimno
group by 1,2,3
into temp t_sumpaid with no log;


select policyno ,sum(sumestipaid) sumpaid
from t_claim
where 1=1 
group by policyno
into temp t_sumpaid2 with no log;

merge into chengbao_list a
using t_sumpaid2 b
on (a.policyno = b.policyno)
when matched then update set a.z_peifu = b.sumpaid;

drop table t_sumpaid;
drop table t_sumpaid2;



------------------------
--select * from t_claimfee;
--select * from chengbao_list where lianshu >= 1
--and renshangshu >= 1;

---交强险的再细分赔款-------
--select claimno,policyno,feetype,feetypecode from t_claimfee 
--where kindcode = '050100'
--and feetypecode = '01'
--;

---------增加交强险细分赔付分类-----------
select * ,
0.00::decimal(20,2) A050100A , ----feetypecode=52---------itemcode = 1 财产
0.00::decimal(20,2) A050100B ,------feetypecode=51--------itemcode =2 '人员伤亡
0.00::decimal(20,2) A050100C ------feetypecode=49---------itemcode =3  医疗
from chengbao_list
where 1=1 into temp chengbao_list2 with no log;

drop table chengbao_list;
--select * from chengbao_list2;

create index idx1 on chengbao_list2(policyno);



------------汇总各个险别的赔款情况--------
select policyno ,kindcode,sum(estipaid) estipaid
	from  t_claimfee 
where 1=1
group by policyno,kindcode 
into temp t_bi_paid
;


create index idx2 on t_bi_paid(policyno);
create index idx3 on t_bi_paid(kindcode);


--select * from t_bi_paid;
-------商业险险别逐个更新-------------


--050100
--050200
--050210
--050220
--050231
--050252
--050260
--050291
--050310
--050350
--050501
--050602
--050711
--050712
--050800
--050911
--050912
--050921
--050922
--050923
--050924
--050925
--050928
--050929
--050941
--050942
--050944



--merge into chengbao_list2 a
--using t_bi_paid b
--on a.policyno = b.policyno and b.kindcode = '050202'
--when matched then update set a.A050200 = b.estipaid;

merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050100' when matched then update set a.A050100= b.estipaid;--机动车交通事故强制责任保险
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050200' when matched then update set a.A050200= b.estipaid;--机动车损失保险
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050500' when matched then update set a.A050500= b.estipaid;--盗抢险
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050600' when matched then update set a.A050600= b.estipaid;--第三者责任保险
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050701' when matched then update set a.A050701= b.estipaid;--车上人员责任险（司机）
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050702' when matched then update set a.A050702= b.estipaid;--车上人员责任险（乘客）
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050911' when matched then update set a.A050911= b.estipaid;--不计免赔率（车损险）
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050912' when matched then update set a.A050912= b.estipaid;--不计免赔率（三者险）
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050921' when matched then update set a.A050921= b.estipaid;--不计免赔率（机动车盗抢险）
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050928' when matched then update set a.A050928= b.estipaid;--不计免赔率（车上人员责任险（司机））
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050929' when matched then update set a.A050929= b.estipaid;--不计免赔率（车上人员责任险（乘客））

----------------交强险赔款再细分------------------------
--select * from chengbao_list2 where policyno = 'PDAT20144418T000009987';

select policyno ,kindcode,feetypecode ,sum(estipaid) estipaid 
from t_claimfee 
where 1=1
and kindcode = '050100'
and feetypecode in ('49','51','52')
group by policyno,kindcode,feetypecode
into temp t_ci_paid with no log;

merge into chengbao_list2 a
using t_ci_paid b 
on a.policyno = b.policyno and b.kindcode = '050100' and feetypecode = '52'
when matched then update set a.A050100A = b.estipaid; 

merge into chengbao_list2 a
using t_ci_paid b 
on a.policyno = b.policyno and b.kindcode = '050100' and feetypecode = '51'
when matched then update set a.A050100B = b.estipaid; 

merge into chengbao_list2 a
using t_ci_paid b 
on a.policyno = b.policyno and b.kindcode = '050100' and feetypecode = '49'
when matched then update set a.A050100C = b.estipaid; 


--unload to 'renshang805title.csv' delimiter ','
--select * from chengbao_list2 where policyno = 'PDZA201544180000014224';





--drop table chengbao_result;

select 
comcode	,
proposalno	,
policyno	,
sumpremium	,
premium_yz  ,
agenttype	,
agentcode	,
clausetype	,
carkindcode	,
useyears	,
enrolldate	,
startdate	,
enddate	,
licenseno	,
licensecolorcode	,
engineno	,
frameno	,
handler1code	,
handlercode	,
businessnature	,
policytype	,
uwtype	,
operatedate	,
sumamount	,
riskcode	,
contractno	,
licensetype	,
usenaturecode	,
runmiles	,
modelcode	,
brandname	,
purchaseprice	,
actualvalue	,
seatcount	,
case when seatcount < 6 then '6座以下'
	 when seatcount < 10 then '6至10座'
	 when seatcount < 20 then '10至20座'
	 when seatcount < 36 then '20至36座'
	else '36座以上' end as seattype,
toncount	,
case when toncount <500 then '小于0.5T'
	when toncount < 1000 then '0.5至1T'
	when toncount < 2000 then '1至2T'
	when toncount < 5000 then '2至5T'
	when toncount < 10000 then '5至10T'
	else '10T以上' end as toncountType,
exhaustscale	,
case when exhaustscale < 1 then '小于1L'
	when exhaustscale <1.6 then '1至1.6L'
	when exhaustscale <2.5 then '1.6至2.5L'
	when exhaustscale <4.0 then '2.5至4L'
	else '超4.0L' end as exhaustscaleType,
--runareaname	,--	去掉行驶里程
monopolycode	,
projectcode	,
biciflag	,
dxflag	,
'转保'::varchar(10)  xbflag,
B050100,--机动车交通事故强制责任保险
B050200,--机动车损失保险
B050500,--盗抢险
B050600,--第三者责任保险
B050701,--车上人员责任险（司机）
B050702,--车上人员责任险（乘客）
B050911,--不计免赔率（车损险）
B050912,--不计免赔率（三者险）
B050921,--不计免赔率（机动车盗抢险）
B050928,--不计免赔率（车上人员责任险（司机））
B050929,--不计免赔率（车上人员责任险（乘客））
carchecker	,
lianshu	,
renshangshu	,
xiesishu	,
xiecanshu	,
z_peifu	,
A050100,--机动车交通事故强制责任保险
A050200,--机动车损失保险
A050500,--盗抢险
A050600,--第三者责任保险
A050701,--车上人员责任险（司机）
A050702,--车上人员责任险（乘客）
A050911,--不计免赔率（车损险）
A050912,--不计免赔率（三者险）
A050921,--不计免赔率（机动车盗抢险）
A050928,--不计免赔率（车上人员责任险（司机））
A050929,--不计免赔率（车上人员责任险（乘客））
endcasefalg	,
a050100a	,
a050100b	,
a050100c,
'0' renshangflag,
'0' siwangflag,
'0' shangcanflag	
from chengbao_list2 where 1=1
into temp chengbao_result with no log;

update chengbao_result set xbflag = '新车'
where extend(startdate,year to month)-enrolldate <= "0-09"
;

update chengbao_result set renshangflag = '1' where renshangshu >= 1;

update chengbao_result set siwangflag = '1' where xiesishu >= 1;

update chengbao_result set shangcanflag = '1' where xiecanshu >= 1;

create index idx4 on chengbao_result(policyno);

--select * from chengbao_result;

create index idx5 on chengbao_result(proposalno);
merge into chengbao_result a
using baobiaodb@p595p2_tcp:middle_car_renewal b
on a.proposalno = b.preproposalno and length(b.oldproposalno) = 22
when matched then update set a.xbflag = '续保'
;


--unload to 'renshang805title.csv' delimiter ','

--select * from chengbao_result where policyno = 'PDZA201544180000014224';




select *,
0::int flag1,
0::int flag2,
0::int flag3,
0::int flag4,
0::int flag5,
null::varchar(20) Tflag
from chengbao_result 
where 1=1
into temp chengbao_result2 with no log
;
--车损
update chengbao_result2 set flag1 = 1
where B050200 > 0.00
;
--三者
update chengbao_result2 set flag2 = 1
where B050600 > 0.00
;
--盗抢
update chengbao_result2 set flag3 = 1
where B050500 > 0.00
;

--司机或乘客
update chengbao_result2 set flag4 = 1
where B050701 > 0.00 or B050702 > 0.00
;


update chengbao_result2 set tflag='不保车损'
where flag1 = 0;

update chengbao_result2 set tflag='车损+3主险'
where flag1 = 1 and (flag2+flag3+flag4) = 3;


update chengbao_result2 set tflag='车损+2主险'
where flag1 = 1 and (flag2+flag3+flag4) = 2;


update chengbao_result2 set tflag='单保车损'
where flag1 = 1 and ((flag2+flag3+flag4) = 1 or (flag2+flag3+flag4) = 0);


-- ----------------------未决承保度量取0--------------------

-- --计算个险别已赚保费 ---
update chengbao_result2 set B050100=B050100*0 where 1 = 1;--机动车交通事故强制责任保险
update chengbao_result2 set B050200=B050200*0 where 1 = 1;--机动车损失保险
update chengbao_result2 set B050500=B050500*0 where 1 = 1;--盗抢险
update chengbao_result2 set B050600=B050600*0 where 1 = 1;--第三者责任保险
update chengbao_result2 set B050701=B050701*0 where 1 = 1;--车上人员责任险（司机）
update chengbao_result2 set B050702=B050702*0 where 1 = 1;--车上人员责任险（乘客）
update chengbao_result2 set B050911=B050911*0 where 1 = 1;--不计免赔率（车损险）
update chengbao_result2 set B050912=B050912*0 where 1 = 1;--不计免赔率（三者险）
update chengbao_result2 set B050921=B050921*0 where 1 = 1;--不计免赔率（机动车盗抢险）
update chengbao_result2 set B050928=B050928*0 where 1 = 1;--不计免赔率（车上人员责任险（司机））
update chengbao_result2 set B050929=B050929*0 where 1 = 1;--不计免赔率（车上人员责任险（乘客））

update chengbao_result2 set sumpremium = 0.00 ,premium_yz = 0.00 where 1=1;



unload to 'renshang_wj.unl' delimiter '	'	 
select * from chengbao_result2 where 1=1
;


unload to 'renshang_wj.unl_orl' 
select * from chengbao_result2 where 1=1
;







{
select *,'bili' bili,
case when B050100 = 0.00 then 0.00 else A050100/B050100 end as AB050100,
case when B050200 = 0.00 then 0.00 else A050200/B050200 end as AB050200,
case when B050210 = 0.00 then 0.00 else A050210/B050210 end as AB050210,
case when B050220 = 0.00 then 0.00 else A050220/B050220 end as AB050220,
case when B050231 = 0.00 then 0.00 else A050231/B050231 end as AB050231,
case when B050252 = 0.00 then 0.00 else A050252/B050252 end as AB050252,
case when B050260 = 0.00 then 0.00 else A050260/B050260 end as AB050260,
case when B050291 = 0.00 then 0.00 else A050291/B050291 end as AB050291,
case when B050310 = 0.00 then 0.00 else A050310/B050310 end as AB050310,
case when B050350 = 0.00 then 0.00 else A050350/B050350 end as AB050350,
case when B050500 = 0.00 then 0.00 else A050500/B050500 end as AB050500,
case when B050600 = 0.00 then 0.00 else A050600/B050600 end as AB050600,
case when B050701 = 0.00 then 0.00 else A050701/B050701 end as AB050701,
case when B050702 = 0.00 then 0.00 else A050702/B050702 end as AB050702,
case when B050800 = 0.00 then 0.00 else A050800/B050800 end as AB050800,
case when B050911 = 0.00 then 0.00 else A050911/B050911 end as AB050911,
case when B050912 = 0.00 then 0.00 else A050912/B050912 end as AB050912,
case when B050921 = 0.00 then 0.00 else A050921/B050921 end as AB050921,
case when B050922 = 0.00 then 0.00 else A050922/B050922 end as AB050922,
case when B050923 = 0.00 then 0.00 else A050923/B050923 end as AB050923,
case when B050924 = 0.00 then 0.00 else A050924/B050924 end as AB050924,
case when B050925 = 0.00 then 0.00 else A050925/B050925 end as AB050925,
case when B050928 = 0.00 then 0.00 else A050928/B050928 end as AB050928,
case when B050929 = 0.00 then 0.00 else A050929/B050929 end as AB050929,
case when B050941 = 0.00 then 0.00 else A050941/B050941 end as AB050941,
case when B050942 = 0.00 then 0.00 else A050942/B050942 end as AB050942,
case when B050944 = 0.00 then 0.00 else A050944/B050944 end as AB050944
	from chengbao_result
	where lianshu >0
;

}

!

#sed '1i\
#机构代码	投保单号	保单号	应交保费	已赚保费	渠道类型	渠道代码	产品条款	车辆种类	使用年限	初登日期	起保日期	终保日期	车牌	号牌底色	发动机号	车架号	归属人员	经办人员	业务来源	保单种类	核保方式	签单日期	保险金额	承保险种	合同号	车牌种类	使用性质	行驶里程	车型代码	车型名称	新车购置价	实际价值	载客数量	座位数	载重	吨位数	排量	排量分类	送修码	项目代码	商业交强标志	电销业务类型标记	新续传标志	CB机动车交通事故强制责任保险	CB机动车损失保险	CB车身划痕损失险	CB火灾、爆炸、自燃损失险条款	CB玻璃单独破碎险	CB指定修理厂特约条款	CB新增加设备损失保险	CB发动机特别损失险	CB车辆自燃损失保险	CB起重、装卸、挖掘车辆损失扩展条款	CB车辆盗抢保险	CB第三者责任保险	CB车上人员责任险	CB车上乘客责任险	CB车上货物责任险	CB不计免赔率(车辆损失险)	CB不计免赔率(三者险)	CB不计免赔率(机动车盗抢险)	CB不计免赔率(车身划痕损失险)	CB不计免赔率(新增加设备损失保险)	CB不计免赔率(发动机特别损失险)	CB不计免赔率（车上货物责任险）	CB不计免赔率(车上人员责任险(司机))	CB不计免赔率(车上人员责任险(乘客))	CB教练车特约条款(车损险)	CB教练车特约条款(三者险)	CB教练车特约条款(车上人员责任险(乘客))	验车人	立案数量	人伤案件数量	死亡案件数量	伤残案件数量	总赔付金额	LP机动车交通事故强制责任保险	LP机动车损失保险	LP车身划痕损失险	LP火灾、爆炸、自燃损失险条款	LP玻璃单独破碎险	LP指定修理厂特约条款	LP新增加设备损失保险	LP发动机特别损失险	LP车辆自燃损失保险	LP起重、装卸、挖掘车辆损失扩展条款	LP车辆盗抢保险	LP第三者责任保险	LP车上人员责任险	LP车上乘客责任险	LP车上货物责任险	LP不计免赔率(车辆损失险)	LP不计免赔率(三者险)	LP不计免赔率(机动车盗抢险)	LP不计免赔率(车身划痕损失险)	LP不计免赔率(新增加设备损失保险)	LP不计免赔率(发动机特别损失险)	LP不计免赔率（车上货物责任险）	LP不计免赔率(车上人员责任险(司机))	LP不计免赔率(车上人员责任险(乘客))	LP教练车特约条款(车损险)	LP教练车特约条款(三者险)	LP教练车特约条款(车上人员责任险(乘客))	"结案标志	"	"LP交强险--财产	"	LP交强险(死亡伤残)	LP交强险(医疗费)	是否人伤案件	是否死亡案件	是否伤残案件'  





