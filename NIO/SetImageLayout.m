function [  ] = SetImageLayout(  )
global Dimensions OutputDirectory Date DataType
%  设置全局的图片输出的格式
%  Dimensions：数据参数四个维度的大小 经度，纬度，层数，时间
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:

%set(gcf,'visible','off');%不显示figure
% 图像去掉背景白框 axes在figure中的左边界，下边界，宽度，高度
set(gca,'position',[0 0 1 1] );
% 背景色和坐标轴背景设置为透明
%set(gcf,'color','nan');
%set(gca,'color','nan');
%set(gcf,'InvertHardCopy','off');
% 设置gcf窗口的大小为Dimensions，print或saveas输出图片的大小要计算dpi，将print的dpi设为屏幕dpi，
%   paperposition的长和宽设为Dimensions除屏幕dpi，这样打印出来的大小为Dimensions大小
%   Position的大小是窗口的大小，paperposition大小是输出图像的大小
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%设置色带拉伸方式
colormap(jet(256));
if(exist([OutputDirectory,Date],'dir')~=7)
    mkdir([OutputDirectory,Date]);% 在当前文件夹下新建img文件夹，如果已存在会warning，不影响运行
end
end

