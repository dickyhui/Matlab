function [] = DrawContourf( eci,fullPath,vector)
global L_range B_range L_matrix B_matrix MaskValue
%  画等值线
%  eci：矩阵数据
%  fullPath:出图的图层路径（包括文件名）
%  vector:指定等值线的绘制高度
%  L_range：WGS84经度范围
%  B_range;WGS84纬度范围
%  L_matrix:与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix:与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  MaskValue:缺省值
%  MFILE:   DrawContour.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:
%  DATE:

hold off;

[C,h] = contourf(flipud(eci),[-1000,vector],'k');% 画图
clabel(C,h);
caxis([min(vector),max(vector)]);
%set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);
SaveImageWind(fullPath);%保存图片
clear eci;
end