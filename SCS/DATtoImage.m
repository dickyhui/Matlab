function [ output_args ] = DATtoImage( importFile,outputDir,timeInterval )
%  读取DAT格式数值预报产品，经过坐标转换和内插，最后生成图片
%  importFile为输入文件
%  outputDir为输出文件夹
%  output_args返回1为正常运行，0为出错
%  出图数据格式：
%  浪高：Wave_产品_时次_时间
%  Wave_HS_0_20121121
%  浪高7级等值线填色图：Wave_产品_时次_时间
%  Wave_HSContour_0_20121121
%  浪向：Wave_产品_时次_时间_级别
%  Wave_DIR_0_20121121_L3
%  MFILE:   DATtoImage.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
% importFile = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\dirjinhai620130121.dat';%hsjinhai620130121%dirjinhai620130121
% outputDir = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\';
% timeInterval = 12;

global Dimensions L_range B_range L_matrix B_matrix Time_interval VectorPicSize yesterday outputDirectory
% 三个维度的大小 经度，纬度，时间
Dimensions = [751,1201,121];
%矢量图形出图大小（第三层）
VectorPicSize = [143,259];
% 设置图层的时间间隔，数据源就是6小时间隔，所以要是6的倍数
Time_interval = timeInterval;
% 获取文件名中的日期，昨天
[~, name, ~] = fileparts(importFile);
yesterday=name(end-7:end);
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
outputDirectory=outputDir;
% wgs84初始的等分的经纬度坐标范围
L_range = linspace(105,130,Dimensions(1));
B_range = linspace(45,5,Dimensions(2));
% 构造插值运算需要输入的经纬度矩阵参数
[L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
%% main do
try
    % 判断传入的文件类型
    if(size(strfind(name,'hsjinhai'),1) == 1)
        output_args = HStoImage(importFile);
    elseif(size(strfind(name,'dirjinhai'),1) == 1)
        output_args = DIRtoImage(importFile);
    end
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
end

%% HStoImage
% HS文件生成图片，浪高填色图
function [ output_args ] = HStoImage( input_args )
global Dimensions Time_interval yesterday outputDirectory
try
    %设置全局的图片输出的格式
    SetImageLayout();
    %fid = fopen(input_args, 'r');% 打开文件
    dat = load(input_args);% 打开文件
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%创建xml，记录填色图的最大最小值
    docRootNode = docNode.getDocumentElement;%获取xml跟节点
    docRootNode.setAttribute('date',yesterday);%设置时间属性
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);
    %开始生成图片
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % 读取变量
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        name=['Wave_HS_',num2str(i), '_',yesterday];
        [maxValue,minValue]=DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        %DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        
        newSlide=docNode.createElement(name);%新建newSlide节点
        newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
        newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
        docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
        
        i=i+Time_interval;
        clear ec;
    end
    output_args = 1;
    xmlwrite([outputDirectory,'wave.xml'],docNode);%保存xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
clear dat;
end

%% DIRtoImage
% DIR文件生成浪向箭头
function [ output_args ] = DIRtoImage( input_args )
global Dimensions Time_interval VectorPicSize yesterday outputDirectory
try
    %设置全局的图片输出的格式
    SetImageLayout();
    %fid = fopen(input_args, 'r');% 打开文件
    dat = load(input_args);% 打开文件
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %开始生成图片
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % 读取变量
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i),'_',yesterday , '_L3.png'],100);
        i=i+Time_interval;
        clear ec;
    end
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %开始生成图片
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L4.png'],50);
        i=i+Time_interval;
        clear ec;
    end
     set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %开始生成图片
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L5.png'],25);
        i=i+Time_interval;
        clear ec;
    end
    set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %开始生成图片
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % 读取变量
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L6.png'],15);
        i=i+Time_interval;
        clear ec;
    end
    output_args = 1;
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
clear dat;
end

%% DrawHS
%画填色图
function [maxValue,minValue] = DrawHS( eci,name )
global B_range L_range B_matrix L_matrix
hold off;
%eci=flipud(eci');% 矩阵逆时针旋转90°
eci(eci(:,:)==-9)=nan;% 将-9999设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
% imagesc 输出的图像的各个象元的位置与输入矩阵的值的位置一一对应
% L_range,B_range与eci与L_matrix,B_matrix三者值的位置统一，这里都设置成与地理坐标的位置一致
% 输出的eci不会旋转
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
maxValue=max(max(eci));%最大值
minValue=min(min(eci));%最小值
h=imagesc(eci);% 画图
% eci=flipud(eci);
% [~,h]=contourf(eci(1:end,1:end),[0 0.5 1 1.5 2 2.5 3 3.5 100],'LineColor','blue');
% ch=get(h,'children');
% set(ch(1),'FaceColor','yellow','FaceAlpha',1);
% set(ch(2),'FaceColor','yellow','FaceAlpha',1);
% set(ch(3),'FaceColor','yellow','FaceAlpha',1);
% set(ch(4),'FaceColor','yellow','FaceAlpha',1);
% set(ch(5),'FaceColor','yellow','FaceAlpha',1);
% set(ch(6),'FaceColor','yellow','FaceAlpha',1);
% set(ch(7),'FaceColor','yellow','FaceAlpha',1);
% set(ch(8),'FaceColor','yellow','FaceAlpha',1);

set(h,'alphadata',~isnan(eci));%将nan值设为白色（默认为蓝色）
SaveImage(name);%保存图片
clear eci;
end

%% DrawDIR
%画浪向箭头，interval为风向标的间隔
function [] = DrawDIR( ec,name,interval )
global B_range L_range B_matrix L_matrix
hold off;
ec(ec(:,:)==-999)=nan;% 将-999设为nan
% 矩阵内插 原始矩阵ec的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
ec=interp2(L_range,B_range,ec,L_matrix,B_matrix,'linear');
ec=flipud(ec(1:interval:end,1:interval:end));
dx=cos(ec*pi/180);
dy=sin(ec*pi/180);
h=quiver(dx,dy,'color','k'); %生成箭头
set(h,'autoscalefactor',0.5,'Marker','none','MaxHeadSize',0.8);
set(gca,'XLim',[1 size(ec,2)],'YLim',[1 size(ec,1)]);%设置坐标范围
% for i=1:size(ec,1)
%     for j=1:size(ec,2)
%      if (isnan(ec(i,j)))
%         continue;
%      else
%         h=quiver(j,i,-sin(ec(i,j)),-cos(ec(i,j)));
%         hold on
%     end
%     end
% end
%set(h,'autoscalefactor',0.5,'Marker','none','color','b');
SaveImage(name);%保存图片
clear ec ecx ecy;
end

%% SaveImage
%保存图片,input_args为图层名
function [  ] = SaveImage( input_args )
global outputDirectory yesterday
axis off;% 关闭坐标轴
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[outputDirectory,yesterday,'\default.png']);% 输出图片
%saveas(gcf,'img\default.png','png');
img = imread([outputDirectory,yesterday,'\default.png']);% 读取图片
siz=size(img);
alpha=ones(siz(1),siz(2));
alpha((img(:,:,1)==255)&(img(:,:,2)==255)&(img(:,:,3)==255))=0;% 白色设为透明
imwrite(img,input_args,'alpha',alpha);% 输出有透明背景的图片
end

%% SetImageLayout
%设置全局的图片输出的格式
function [  ] = SetImageLayout(  )
global Dimensions outputDirectory yesterday
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
%set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 250 250]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);%get(0,'ScreenPixelsPerInch')

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%设置色带拉伸方式
colormap(jet(256));
if(exist([outputDirectory,yesterday],'dir')~=7)
    mkdir([outputDirectory,yesterday]);% 在当前文件夹下新建img文件夹，如果已存在会warning，不影响运行
end
end