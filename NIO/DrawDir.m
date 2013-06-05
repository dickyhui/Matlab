function [ ] = DrawDir( fullPath,interval,varargin )
global L_range B_range L_matrix B_matrix MaskValue
%  画箭头
%  fullPath:出图的图层路径（包括文件名）
%  interval：数据间隔
%  varargin:可变数据参数，若只有一个参数，画无大小的箭头，若有两个参数，画带大小的箭头
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
switch length(varargin)
    case 1  %只有一个参数，画无大小的箭头
        eci=double(varargin{1});
        eci(eci(:,:)==MaskValue)=nan;% 将-999设为nan
        % 矩阵内插 原始矩阵eci的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
        eci=flipud(eci(1:interval:end,1:interval:end));
        dx=cos(eci*pi/180);
        dy=sin(eci*pi/180);
    case 2  %有两个参数，画带大小的箭头
        dx=double(varargin{1});
        dy=double(varargin{2});
        dx(dx(:,:)==MaskValue)=nan;% 将MaskValue设为nan
        dy(dy(:,:)==MaskValue)=nan;% 将MaskValue设为nan
        % 矩阵内插 原始矩阵eci的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        dx=interp2(L_range,B_range,dx,L_matrix,B_matrix,'linear');
        dy=interp2(L_range,B_range,dy,L_matrix,B_matrix,'linear');
        dx=flipud(dx(1:interval:end,1:interval:end));
        dy=flipud(dy(1:interval:end,1:interval:end));
end
hold off;
h=quiver(dx,dy,'color','k'); %生成箭头
set(h,'autoscalefactor',0.8,'Marker','none','MaxHeadSize',0.5);
set(gca,'XLim',[1 size(dx,2)],'YLim',[1 size(dx,1)]);%设置坐标范围
SaveImage(fullPath);%保存图片
clear eci dx dy;
end

