function [] = datagrid(ec,dn,limitvalue)
%  ��������Ķ�ά���������������ͼ
%  ecΪ��2m+1)*(2*n+1)�����ݣ�����mΪҪ��ʾ������������nΪҪ��ʾ����������
%  ec���������������й�������ż���к�ż���й�����ʾ����
%  dnΪ�����е����ֱ���С������λ��
%  limitvalueΪ����ֵ���������ú�ɫ��ʾ
%  MFILE:   datagrid.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

hold off;
[ecm,ecn]=size(ec);
% ����������
xc=[1:2:ecn;1:2:ecn];
yc=ones(2,size(xc,2));
yc(2,:)=yc(2,:)*ecm;
plot(xc,yc,'color','k');
hold on;
% ����������
yr=[1:2:ecm;1:2:ecm];
xr=ones(2,size(yr,2));
xr(2,:)=xr(2,:)*ecn;
plot(xr,yr,'color','k');
% ��ʾ����
[x,y]=meshgrid(2:2:ecn,2:2:ecm);
[mx,nx]=size(x);
x=reshape(x,1,mx*nx);
y=reshape(y,1,mx*nx);

ec=flipud(ec);
value=reshape(ec(2:2:ecm,2:2:ecn),mx*nx,1);
value=roundn(value,-dn);%value=round(value*10^dn)/10^dn;%����С�������λ��Ч����
%С��limitvalueΪ��ɫ
valueBlack = value;
valueBlack(valueBlack>=limitvalue)=nan;%����limitvalue��ΪNaN
showvalue=~isnan(valueBlack);%����Ҫ��ʾ��ֵ�ľ���1Ϊ��ʾ��0Ϊ����ʾ��
text(x(showvalue),y(showvalue),num2str(valueBlack(showvalue)),'Color','black','FontSize',10,'FontUnits','points','HorizontalAlignment','center');
%����limitvalueΪ��ɫ
valueRed = value;
valueRed(valueRed<limitvalue)=nan;%С��limitvalue��ΪNaN
showvalue=~isnan(valueRed);%����Ҫ��ʾ��ֵ�ľ���1Ϊ��ʾ��0Ϊ����ʾ��
text(x(showvalue),y(showvalue),num2str(valueRed(showvalue)),'Color','red','FontSize',10,'FontUnits','points','HorizontalAlignment','center');
end