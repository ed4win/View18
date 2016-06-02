{
select a.comcode,a.proposalno,a.policyno, a.sumpremium,
case when today>=a.enddate
then a.sumpremium
else a.sumpremium*(today-a.startdate+1)/(a.enddate-a.startdate+1)
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
       MonopolyCode,  --送修码
       projectcode,   --项目代码
       case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --交强商业标记
       b.flag[5] dxflag,   --电销业务类型标记位
       null::varchar(10) xbflag,
       null::varchar(22) oldproposalno,
        null::varchar(22) nextproposalno,
        null::varchar(60) oldagentcode,
        null::varchar(200) oldagentname,
        null::varchar(60) nextagentcode,
        null::varchar(200) nextagentname
from prpcmain a,prpcitem_car  b,
outer gd4400dms3gdb:prpdagent e
where 1=1
and (a.operatedate between '2015-01-01 00:00:00' and '2015-05-31 23:59:59'
        or  a.operatedate between '2016-01-01 00:00:00' and '2016-05-31 23:59:59')
and a.agentcode in ('44003H100860','44003H100399','44003H100210')
and a.proposalno=b.proposalno
and length(a.policyno) = 22
and a.comcode[1,4] = '4418' --清远
and a.policyno[1]='P'
and a.othflag[4]<>"1"           --非注销
and a.othflag[4]<>"2"           --非删除
--and b.UseNatureCode='120'
and a.agentcode=e.agentcode
into temp chengbao_qibao2 with no log;



update chengbao_qibao2 set xbflag = '新车'
where extend(startdate,year to month)-enrolldate <= "0-09"
;


create index idx5 on chengbao_qibao2(proposalno);


merge into chengbao_qibao2 a
using baobiaodb@p595p2_tcp:middle_car_renewal b
on a.proposalno = b.preproposalno and length(b.oldproposalno) = 22 and a.operatedate between '2016-01-01 00:00:00' and '2016-05-31 23:59:59'
when matched then update set a.xbflag = '续保' ,a.oldproposalno = b.oldproposalno
;

merge into chengbao_qibao2 a
using baobiaodb@p595p2_tcp:middle_car_renewal b
on a.proposalno = b.preproposalno and length(b.nextproposalno) = 22 and a.operatedate between  '2015-01-01 00:00:00' and '2015-05-31 23:59:59'
when matched then update set a.xbflag = '被续保' ,a.nextproposalno = b.nextproposalno
;

unload to 'qudaozhuanhuan.unl'
select * from chengbao_qibao2
where 1=1;

create index idx1 on chengbao_qibao2(oldproposalno);
merge into chengbao_qibao2 a
using prpcmain b
on a.oldproposalno = b.proposalno and xbflag = '续保'
when matched then update set a.oldagentcode = b.agentcode
;


create index idx2 on chengbao_qibao2(nextproposalno);

merge into chengbao_qibao2 a
using prpcmain b
on a.nextproposalno = b.proposalno and xbflag = '被续保'
when matched then update set a.nextagentcode = b.agentcode
;
}
unload to 'agentzhuanhuan.unl'
select * from chengbao_qibao2
;
--where nextproposalno = 'TDZA201644180000045790' ;
