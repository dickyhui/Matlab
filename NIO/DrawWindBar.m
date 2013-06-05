function [] = DrawWindBar( ec0U,ec0V,name,interval )
global L_range B_range L_matrix B_matrix MaskValue
%  画风向标
%  ec0U：矩阵数据水平分量
%  ec0V：矩阵数据竖直分量
%  fullPath:出图的图层路径（包括文件名）
%  interval：数据间隔
%  L_range：WGS84经度范围
%  B_range;WGS84纬度范围
%  L_matrix:与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix:与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  MaskValue:缺省值
%  MFILE:   DrawWindBar.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:  

hold off;
ec0U=double(ec0U);% 矩阵逆时针旋转90°
ec0V=double(ec0V);% 矩阵逆时针旋转90°
ec0U(ec0U(:,:)==MaskValue)=nan;% 将-9999设为nan
ec0V(ec0V(:,:)==MaskValue)=nan;% 将-9999设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'linear');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'linear');
[x,y]=meshgrid(1:size(L_range,2),1:size(B_range,2));%经纬度的范围，主要是生成等距的网格
%quiver(flipud(ec0U(1:4:end,1:4:end)),flipud(ec0V(1:4:end,1:4:end))); %生成箭头
ec0U=flipud(ec0U);
ec0V=flipud(ec0V);
ec0U1=ec0U;
ec0U1(flipud(B_matrix)<0)=0;
ec0V1=ec0V;
ec0V1(flipud(B_matrix)<0)=0;
WindBar(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U1(1:interval:end,1:interval:end),ec0V1(1:interval:end,1:interval:end),1)%生成风向标
hold on
ec0U1=ec0U;
ec0U1(flipud(B_matrix)>=0)=0;
ec0V1=ec0V;
ec0V1(flipud(B_matrix)>=0)=0;
WindBar(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U1(1:interval:end,1:interval:end),ec0V1(1:interval:end,1:interval:end),-1)%生成风向标
set(gca,'XLim',[1 size(L_range,2)],'YLim',[1 size(B_range,2)]);%设置坐标范围windbarbm函数会改变坐标范围
SaveImageWind(name);%保存图片
clear ec0U ec0V;
end
