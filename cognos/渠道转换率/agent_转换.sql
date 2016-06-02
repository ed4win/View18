{
select a.comcode,a.proposalno,a.policyno, a.sumpremium,
case when today>=a.enddate
then a.sumpremium
else a.sumpremium*(today-a.startdate+1)/(a.enddate-a.startdate+1)
end premium_yz ,
---��ֹ����ʱ����׬ǩ������
e.agenttype, a.agentcode,
 b.clausetype,  b.carkindcode, b.useyears,  b.enrolldate,  --��������
       a.startdate,   --������
       a.enddate,     --�ձ�����
       b.licenseno,   --���ƺ���
       b.licensecolorcode, --���Ƶ�ɫ
       b.engineno,
       b.frameno,
       handler1code,     --������Ա
       handlercode,      --������Ա
       businessnature,   --ҵ����Դ
       case when length(contractno) = 22 then '����'
            else '����' end as policytype,         --��������
       case when underwriteflag = '3' then '�Զ�'
            else '�˹�' end as uwtype,             --�˱���ʽ
       operatedate,   --ǩ������
       sumamount,     --���ս��
       a.riskcode,    --�б�����
       a.contractno,  --�ŵ���/��ͬ��
       licensetype,   --��������
       --vinno,
       usenaturecode, --ʹ������
       runmiles,
       modelcode,     --���ʹ���
       brandname,     --��������
       purchaseprice, --�³����ü�
       actualvalue,   --ʵ�ʼ�ֵ
       seatcount,     --�ؿ���
       toncount,      --������
       exhaustscale,  --����
       MonopolyCode,  --������
       projectcode,   --��Ŀ����
       case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --��ǿ��ҵ���
       b.flag[5] dxflag,   --����ҵ�����ͱ��λ
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
and a.comcode[1,4] = '4418' --��Զ
and a.policyno[1]='P'
and a.othflag[4]<>"1"           --��ע��
and a.othflag[4]<>"2"           --��ɾ��
--and b.UseNatureCode='120'
and a.agentcode=e.agentcode
into temp chengbao_qibao2 with no log;



update chengbao_qibao2 set xbflag = '�³�'
where extend(startdate,year to month)-enrolldate <= "0-09"
;


create index idx5 on chengbao_qibao2(proposalno);


merge into chengbao_qibao2 a
using baobiaodb@p595p2_tcp:middle_car_renewal b
on a.proposalno = b.preproposalno and length(b.oldproposalno) = 22 and a.operatedate between '2016-01-01 00:00:00' and '2016-05-31 23:59:59'
when matched then update set a.xbflag = '����' ,a.oldproposalno = b.oldproposalno
;

merge into chengbao_qibao2 a
using baobiaodb@p595p2_tcp:middle_car_renewal b
on a.proposalno = b.preproposalno and length(b.nextproposalno) = 22 and a.operatedate between  '2015-01-01 00:00:00' and '2015-05-31 23:59:59'
when matched then update set a.xbflag = '������' ,a.nextproposalno = b.nextproposalno
;

unload to 'qudaozhuanhuan.unl'
select * from chengbao_qibao2
where 1=1;

create index idx1 on chengbao_qibao2(oldproposalno);
merge into chengbao_qibao2 a
using prpcmain b
on a.oldproposalno = b.proposalno and xbflag = '����'
when matched then update set a.oldagentcode = b.agentcode
;


create index idx2 on chengbao_qibao2(nextproposalno);

merge into chengbao_qibao2 a
using prpcmain b
on a.nextproposalno = b.proposalno and xbflag = '������'
when matched then update set a.nextagentcode = b.agentcode
;
}
unload to 'agentzhuanhuan.unl'
select * from chengbao_qibao2
;
--where nextproposalno = 'TDZA201644180000045790' ;
