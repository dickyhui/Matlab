function [] = datagrid(ec,dn,limitvalue)
%  根据输入的二维矩阵数据输出格网图
%  ec为（2m+1)*(2*n+1)的数据，其中m为要显示的数据行数，n为要显示的数据列数
%  ec中奇数行与奇数列构造网格，偶数行和偶数列构造显示数字
%  dn为格网中的数字保留小数点后的位数
%  limitvalue为警戒值，超过了用红色表示
%  MFILE:   datagrid.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

hold off;
[ecm,ecn]=size(ec);
% 构造列网格
xc=[1:2:ecn;1:2:ecn];
yc=ones(2,size(xc,2));
yc(2,:)=yc(2,:)*ecm;
plot(xc,yc,'color','k');
hold on;
% 构造行网格
yr=[1:2:ecm;1:2:ecm];
xr=ones(2,size(yr,2));
xr(2,:)=xr(2,:)*ecn;
plot(xr,yr,'color','k');
% 显示数字
[x,y]=meshgrid(2:2:ecn,2:2:ecm);
[mx,nx]=size(x);
x=reshape(x,1,mx*nx);
y=reshape(y,1,mx*nx);

ec=flipud(ec);
value=reshape(ec(2:2:ecm,2:2:ecn),mx*nx,1);
value=roundn(value,-dn);%value=round(value*10^dn)/10^dn;%保留小数点后三位有效数字
%小于limitvalue为黑色
valueBlack = value;
valueBlack(valueBlack>=limitvalue)=nan;%大于limitvalue设为NaN
showvalue=~isnan(valueBlack);%构造要显示数值的矩阵（1为显示，0为不显示）
text(x(showvalue),y(showvalue),num2str(valueBlack(showvalue)),'Color','black','FontSize',10,'FontUnits','points','HorizontalAlignment','center');
%大于limitvalue为红色
valueRed = value;
valueRed(valueRed<limitvalue)=nan;%小于limitvalue设为NaN
showvalue=~isnan(valueRed);%构造要显示数值的矩阵（1为显示，0为不显示）
text(x(showvalue),y(showvalue),num2str(valueRed(showvalue)),'Color','red','FontSize',10,'FontUnits','points','HorizontalAlignment','center');
end