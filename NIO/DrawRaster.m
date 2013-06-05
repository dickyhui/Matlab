function [maxValue,minValue] = DrawRaster( eci,fullPath )
global L_range B_range L_matrix B_matrix MaskValue
%  画填色图
%  eci：矩阵数据
%  fullPath:出图的图层路径（包括文件名）
%  L_range：WGS84经度范围
%  B_range;WGS84纬度范围
%  L_matrix:与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix:与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  MaskValue:缺省值
%  MFILE:   DrawRaster.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE: 

hold off;
eci=double(eci);
eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
% imagesc 输出的图像的各个象元的位置与输入矩阵的值的位置一一对应
% L_range,B_range与eci与L_matrix,B_matrix三者值的位置统一，这里都设置成与地理坐标的位置一致
% 输出的eci不会旋转
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
maxValue=max(max(eci));%最大值
minValue=min(min(eci));%最小值
h=imagesc(eci);% 画图
set(h,'alphadata',~isnan(eci));%将nan值设为白色（默认为蓝色）
SaveImage(fullPath);%保存图片
clear eci;
end
