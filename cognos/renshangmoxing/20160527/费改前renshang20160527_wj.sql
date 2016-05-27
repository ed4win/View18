:<<block
dbaccess  -e gd4400car3gdb <<!
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
       runareaname,   --��ʻ����
       MonopolyCode,  --������
       projectcode,   --��Ŀ����
       case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --��ǿ��ҵ���
       b.flag[5] dxflag,   --����ҵ�����ͱ��λ

0.00::decimal(20,2) B050100,--��������ͨ�¹�ǿ�����α���
0.00::decimal(20,3) B050200,--��������ʧ����
0.00::decimal(20,4) B050500,--������
0.00::decimal(20,5) B050600,--���������α���
0.00::decimal(20,6) B050701,--������Ա�����գ�˾����
0.00::decimal(20,7) B050702,--������Ա�����գ��˿ͣ�
0.00::decimal(20,8) B050911,--���������ʣ������գ�
0.00::decimal(20,9) B050912,--���������ʣ������գ�
0.00::decimal(20,10) B050921,--���������ʣ������������գ�
0.00::decimal(20,11) B050928,--���������ʣ�������Ա�����գ�˾������
0.00::decimal(20,12) B050929,--���������ʣ�������Ա�����գ��˿ͣ���  

       case when d.CarChecker="" then "û����"
            else d.CarChecker
       end CarChecker
from prpcmain a,prpcitem_car  b,
     outer prpcmain_car d, outer gd4400dms3gdb:prpdagent e
where 1=1
and a.startdate between '20160101' and today
and a.proposalno=b.proposalno
and length(a.policyno) = 22
and a.comcode[1,4] = '4418' --��Զ
and a.policyno[1]='P'
and a.othflag[4]<>"1"           --��ע��
and a.othflag[4]<>"2"           --��ɾ��
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



merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050100' when matched then update set a.B050100= b.premium;--��������ͨ�¹�ǿ�����α���
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050200' when matched then update set a.B050200= b.premium;--��������ʧ����
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050500' when matched then update set a.B050500= b.premium;--������
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050600' when matched then update set a.B050600= b.premium;--���������α���
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050701' when matched then update set a.B050701= b.premium;--������Ա�����գ�˾����
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050702' when matched then update set a.B050702= b.premium;--������Ա�����գ��˿ͣ�
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050911' when matched then update set a.B050911= b.premium;--���������ʣ������գ�
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050912' when matched then update set a.B050912= b.premium;--���������ʣ������գ�
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050921' when matched then update set a.B050921= b.premium;--���������ʣ������������գ�
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050928' when matched then update set a.B050928= b.premium;--���������ʣ�������Ա�����գ�˾������
merge into chengbao_qibao a using t_itemkind b on a.proposalno = b.proposalno and b.kindcode = '050929' when matched then update set a.B050929= b.premium;--���������ʣ�������Ա�����գ��˿ͣ���



-- --������ձ���׬���� ---
update chengbao_qibao set B050100=B050100*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--��������ͨ�¹�ǿ�����α���
update chengbao_qibao set B050200=B050200*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--��������ʧ����
update chengbao_qibao set B050500=B050500*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--������
update chengbao_qibao set B050600=B050600*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������α���
update chengbao_qibao set B050701=B050701*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--������Ա�����գ�˾����
update chengbao_qibao set B050702=B050702*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--������Ա�����գ��˿ͣ�
update chengbao_qibao set B050911=B050911*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������ʣ������գ�
update chengbao_qibao set B050912=B050912*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������ʣ������գ�
update chengbao_qibao set B050921=B050921*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������ʣ������������գ�
update chengbao_qibao set B050928=B050928*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������ʣ�������Ա�����գ�˾������
update chengbao_qibao set B050929=B050929*(today-startdate+1)/(enddate-startdate+1) where today < enddate;--���������ʣ�������Ա�����գ��˿ͣ���



unload to 'chengbao_qibao.unl'
select * from chengbao_qibao where 1=1;

!
block


dbaccess -e $_LPDB <<!
select a.comcode,     --��������
       a.proposalno,
       a.policyno,    --������
       a.sumpremium,  --Ӧ������
	   a.sumpremium premium_yz ,--��׬����
       e.agenttype,   --��������
       a.agentcode,   --��������
       b.clausetype,  --�����Ʒ
       b.carkindcode, --��������
       b.useyears,    --ʹ������
       b.enrolldate,  --��������
       a.startdate,   --������
       a.enddate,     --�ձ�����
       b.licenseno,   --���ƺ���
       b.licensecolorcode, --���Ƶ�ɫ
       b.engineno,    
       b.frameno,
       handler1code,     --������Ա
       handlercode,      --������Ա
       businessnature,   --ҵ����Դ
       --case when length(contractno) = 22 then '����'
            --else '����' end as policytype,         --��������
       '                  ' policytype,
       --case when underwriteflag = '3' then '�Զ�'
            --else '�˹�' end as uwtype,             --�˱���ʽ
	   '                    ' uwtype,
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
       runareaname,   --��ʻ����
       MonopolyCode,  --������
       projectcode,   --��Ŀ����
       --case when a.riskcode[1,2]='DZ' then 'ci'  else 'bi' end biciflag,  --��ǿ��ҵ���
	   '     ' biciflag,
       b.flag[5] dxflag,   --����ҵ�����ͱ��λ
	-------------------
0.00::decimal(20,2) B050100,--��������ͨ�¹�ǿ�����α���
0.00::decimal(20,3) B050200,--��������ʧ����
0.00::decimal(20,4) B050500,--������
0.00::decimal(20,5) B050600,--���������α���
0.00::decimal(20,6) B050701,--������Ա�����գ�˾����
0.00::decimal(20,7) B050702,--������Ա�����գ��˿ͣ�
0.00::decimal(20,8) B050911,--���������ʣ������գ�
0.00::decimal(20,9) B050912,--���������ʣ������գ�
0.00::decimal(20,10) B050921,--���������ʣ������������գ�
0.00::decimal(20,11) B050928,--���������ʣ�������Ա�����գ�˾������
0.00::decimal(20,12) B050929,--���������ʣ�������Ա�����գ��˿ͣ���  
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
----------���� ������Ϣδ���-----
--------------------

-----------δ�������嵥----------------
select x.policyno, x.claimno,x.registno,x.SUMESTIPAID, 
'0' renshangflag,
'0' siwangflag,
'0' shangcanflag
from prplclaim x,t_policyno y
--,prplregist z -------------���ӳ��������ж�
where x.policyno = y.policyno
and x.canceldate is null
----------------------------------
and x.endcasedate is   null  ------δ�᰸
--and z.registno = x.registno 
--and z.reportdate between '20150715' and '20150823'
into temp t_claim with no log;

update t_claim set renshangflag = '0',
siwangflag = '0' ,
shangcanflag = '0'
where 1=1;



-----�ж�����---------
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

---------�ж�����-----------
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

--------�ж��˲�-----------

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
	   y.sumclaim,-- ����
	   y.estipaid ,--����
	   y.sumpaid,--�ձ����⸶���
	   --y.outstanding, --�ձ�δ�������
	   y.sumrest --��ֵ
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
'δ�᰸'    endcasefalg  ---�᰸״̬
from chengbao_qibao  x
where 1=1 into temp chengbao_list with no log;

-----------����������--------------
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

-------�������˰�������-


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
-----�����˲а�������---

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

unload to '���˷���_claim_δ��.unl'
select * from t_claim where 1=1;

-------������������-----

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
----------���⸶������---------
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

---��ǿ�յ���ϸ�����-------
--select claimno,policyno,feetype,feetypecode from t_claimfee 
--where kindcode = '050100'
--and feetypecode = '01'
--;

---------���ӽ�ǿ��ϸ���⸶����-----------
select * ,
0.00::decimal(20,2) A050100A , ----feetypecode=52---------itemcode = 1 �Ʋ�
0.00::decimal(20,2) A050100B ,------feetypecode=51--------itemcode =2 '��Ա����
0.00::decimal(20,2) A050100C ------feetypecode=49---------itemcode =3  ҽ��
from chengbao_list
where 1=1 into temp chengbao_list2 with no log;

drop table chengbao_list;
--select * from chengbao_list2;

create index idx1 on chengbao_list2(policyno);



------------���ܸ����ձ��������--------
select policyno ,kindcode,sum(estipaid) estipaid
	from  t_claimfee 
where 1=1
group by policyno,kindcode 
into temp t_bi_paid
;


create index idx2 on t_bi_paid(policyno);
create index idx3 on t_bi_paid(kindcode);


--select * from t_bi_paid;
-------��ҵ���ձ��������-------------


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

merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050100' when matched then update set a.A050100= b.estipaid;--��������ͨ�¹�ǿ�����α���
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050200' when matched then update set a.A050200= b.estipaid;--��������ʧ����
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050500' when matched then update set a.A050500= b.estipaid;--������
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050600' when matched then update set a.A050600= b.estipaid;--���������α���
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050701' when matched then update set a.A050701= b.estipaid;--������Ա�����գ�˾����
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050702' when matched then update set a.A050702= b.estipaid;--������Ա�����գ��˿ͣ�
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050911' when matched then update set a.A050911= b.estipaid;--���������ʣ������գ�
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050912' when matched then update set a.A050912= b.estipaid;--���������ʣ������գ�
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050921' when matched then update set a.A050921= b.estipaid;--���������ʣ������������գ�
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050928' when matched then update set a.A050928= b.estipaid;--���������ʣ�������Ա�����գ�˾������
merge into chengbao_list2 a using t_bi_paid b on a.policyno = b.policyno and b.kindcode = '050929' when matched then update set a.A050929= b.estipaid;--���������ʣ�������Ա�����գ��˿ͣ���

----------------��ǿ�������ϸ��------------------------
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
case when seatcount < 6 then '6������'
	 when seatcount < 10 then '6��10��'
	 when seatcount < 20 then '10��20��'
	 when seatcount < 36 then '20��36��'
	else '36������' end as seattype,
toncount	,
case when toncount <500 then 'С��0.5T'
	when toncount < 1000 then '0.5��1T'
	when toncount < 2000 then '1��2T'
	when toncount < 5000 then '2��5T'
	when toncount < 10000 then '5��10T'
	else '10T����' end as toncountType,
exhaustscale	,
case when exhaustscale < 1 then 'С��1L'
	when exhaustscale <1.6 then '1��1.6L'
	when exhaustscale <2.5 then '1.6��2.5L'
	when exhaustscale <4.0 then '2.5��4L'
	else '��4.0L' end as exhaustscaleType,
--runareaname	,--	ȥ����ʻ���
monopolycode	,
projectcode	,
biciflag	,
dxflag	,
'ת��'::varchar(10)  xbflag,
B050100,--��������ͨ�¹�ǿ�����α���
B050200,--��������ʧ����
B050500,--������
B050600,--���������α���
B050701,--������Ա�����գ�˾����
B050702,--������Ա�����գ��˿ͣ�
B050911,--���������ʣ������գ�
B050912,--���������ʣ������գ�
B050921,--���������ʣ������������գ�
B050928,--���������ʣ�������Ա�����գ�˾������
B050929,--���������ʣ�������Ա�����գ��˿ͣ���
carchecker	,
lianshu	,
renshangshu	,
xiesishu	,
xiecanshu	,
z_peifu	,
A050100,--��������ͨ�¹�ǿ�����α���
A050200,--��������ʧ����
A050500,--������
A050600,--���������α���
A050701,--������Ա�����գ�˾����
A050702,--������Ա�����գ��˿ͣ�
A050911,--���������ʣ������գ�
A050912,--���������ʣ������գ�
A050921,--���������ʣ������������գ�
A050928,--���������ʣ�������Ա�����գ�˾������
A050929,--���������ʣ�������Ա�����գ��˿ͣ���
endcasefalg	,
a050100a	,
a050100b	,
a050100c,
'0' renshangflag,
'0' siwangflag,
'0' shangcanflag	
from chengbao_list2 where 1=1
into temp chengbao_result with no log;

update chengbao_result set xbflag = '�³�'
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
when matched then update set a.xbflag = '����'
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
--����
update chengbao_result2 set flag1 = 1
where B050200 > 0.00
;
--����
update chengbao_result2 set flag2 = 1
where B050600 > 0.00
;
--����
update chengbao_result2 set flag3 = 1
where B050500 > 0.00
;

--˾����˿�
update chengbao_result2 set flag4 = 1
where B050701 > 0.00 or B050702 > 0.00
;


update chengbao_result2 set tflag='��������'
where flag1 = 0;

update chengbao_result2 set tflag='����+3����'
where flag1 = 1 and (flag2+flag3+flag4) = 3;


update chengbao_result2 set tflag='����+2����'
where flag1 = 1 and (flag2+flag3+flag4) = 2;


update chengbao_result2 set tflag='��������'
where flag1 = 1 and ((flag2+flag3+flag4) = 1 or (flag2+flag3+flag4) = 0);


------------------------δ���б�����ȡ0--------------------

-- --������ձ���׬���� ---
update chengbao_result2 set 	B050100	 =	B050100	*0		where  1=1;
update chengbao_result2 set 	B050200	 =	B050200	*0		where  1=1;
update chengbao_result2 set 	B050210	 =	B050210	*0		where  1=1;
update chengbao_result2 set 	B050220	 =	B050220	*0		where  1=1;
update chengbao_result2 set 	B050231	 =	B050231	*0		where  1=1;
update chengbao_result2 set 	B050252	 =	B050252	*0		where  1=1;
update chengbao_result2 set 	B050260	 =	B050260	*0		where  1=1;
update chengbao_result2 set 	B050291	 =	B050291	*0		where  1=1;
update chengbao_result2 set 	B050310	 =	B050310	*0		where  1=1;
update chengbao_result2 set 	B050350	 =	B050350	*0	    where  1=1;
update chengbao_result2 set 	B050500	 =	B050500	*0		where  1=1;
update chengbao_result2 set 	B050600	 =	B050600	*0		where  1=1;
update chengbao_result2 set 	B050701	 =	B050701	*0		where  1=1;
update chengbao_result2 set 	B050702	 =	B050702	*0		where  1=1;
update chengbao_result2 set 	B050800	 =	B050800	*0		where  1=1;
update chengbao_result2 set 	B050911	 =	B050911	*0		where  1=1;
update chengbao_result2 set 	B050912	 =	B050912	*0		where  1=1;
update chengbao_result2 set 	B050921	 =	B050921	*0		where  1=1;
update chengbao_result2 set 	B050922	 =	B050922	*0		where  1=1;
update chengbao_result2 set 	B050923	 =	B050923	*0		where  1=1;
update chengbao_result2 set 	B050924	 =	B050924	*0		where  1=1;
update chengbao_result2 set 	B050925	 =	B050925	*0		where  1=1;
update chengbao_result2 set 	B050928	 =	B050928	*0	    where  1=1;
update chengbao_result2 set 	B050929	 =	B050929	*0		where  1=1;
update chengbao_result2 set 	B050941	 =	B050941	*0		where  1=1;
update chengbao_result2 set 	B050942	 =	B050942	*0		where  1=1;
update chengbao_result2 set 	B050944	 =	B050944	*0		where  1=1;

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

sed '1i\
��������	Ͷ������	������	Ӧ������	��׬����	��������	��������	��Ʒ����	��������	ʹ������	��������	������	�ձ�����	����	���Ƶ�ɫ	��������	���ܺ�	������Ա	������Ա	ҵ����Դ	��������	�˱���ʽ	ǩ������	���ս��	�б�����	��ͬ��	��������	ʹ������	��ʻ���	���ʹ���	��������	�³����ü�	ʵ�ʼ�ֵ	�ؿ�����	��λ��	����	��λ��	����	��������	������	��Ŀ����	��ҵ��ǿ��־	����ҵ�����ͱ��	��������־	CB��������ͨ�¹�ǿ�����α���	CB��������ʧ����	CB��������ʧ��	CB���֡���ը����ȼ��ʧ������	CB��������������	CBָ��������Լ����	CB�������豸��ʧ����	CB�������ر���ʧ��	CB������ȼ��ʧ����	CB���ء�װж���ھ�����ʧ��չ����	CB������������	CB���������α���	CB������Ա������	CB���ϳ˿�������	CB���ϻ���������	CB����������(������ʧ��)	CB����������(������)	CB����������(������������)	CB����������(��������ʧ��)	CB����������(�������豸��ʧ����)	CB����������(�������ر���ʧ��)	CB���������ʣ����ϻ��������գ�	CB����������(������Ա������(˾��))	CB����������(������Ա������(�˿�))	CB��������Լ����(������)	CB��������Լ����(������)	CB��������Լ����(������Ա������(�˿�))	�鳵��	��������	���˰�������	������������	�˲а�������	���⸶���	LP��������ͨ�¹�ǿ�����α���	LP��������ʧ����	LP��������ʧ��	LP���֡���ը����ȼ��ʧ������	LP��������������	LPָ��������Լ����	LP�������豸��ʧ����	LP�������ر���ʧ��	LP������ȼ��ʧ����	LP���ء�װж���ھ�����ʧ��չ����	LP������������	LP���������α���	LP������Ա������	LP���ϳ˿�������	LP���ϻ���������	LP����������(������ʧ��)	LP����������(������)	LP����������(������������)	LP����������(��������ʧ��)	LP����������(�������豸��ʧ����)	LP����������(�������ر���ʧ��)	LP���������ʣ����ϻ��������գ�	LP����������(������Ա������(˾��))	LP����������(������Ա������(�˿�))	LP��������Լ����(������)	LP��������Լ����(������)	LP��������Լ����(������Ա������(�˿�))	"�᰸��־	"	"LP��ǿ��--�Ʋ�	"	LP��ǿ��(�����˲�)	LP��ǿ��(ҽ�Ʒ�)	�Ƿ����˰���	�Ƿ���������	�Ƿ��˲а���'  renshang_yj.unl > renshang_yj.txt





