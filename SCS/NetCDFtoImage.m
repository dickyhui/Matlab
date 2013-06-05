function [ output_args ] = NetCDFtoImage( importFile,outputDir,timeInterval )
%  读取NetCDF格式数值预报产品，经过坐标转换和内插，最后生成图片
%  importFile为输入文件
%  outputDir为输出文件夹
%  output_args返回1为正常运行，0为出错
%  出图数据格式：
%  三维等值线：Wind_产品_时次_时间_级别
%  Wind_PSFC_0_2012112108_L3
%  三维风向标：Wind_产品_时次_时间_级别
%  Wind_W10_0_2012112108_L3
%  三维风向标七级等值线填色图：Wind_产品Contour_时次_时间
%  Wind_W10Contour_0_2012112108
%  MFILE:   NetCDFtoImage.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
% importFile = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\nmefc_wrf_2013012108.nc';
% outputDir = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\';
% timeInterval = 12;

global Dimensions L_range B_range L_matrix B_matrix Time_interval yesterday VectorPicSize outputDirectory
% 四个维度的大小 经度，纬度，层数，时间
Dimensions = [251,251,6,121];
%矢量图形出图大小（第三层）
VectorPicSize = [285,331];
% 设置图层的时间间隔和层数间隔
Time_interval = timeInterval;
% 获取文件名中的日期，昨天，设置输出文件夹
[~, name, ~] = fileparts(importFile);
yesterday=name(end-9:end);
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
outputDirectory=outputDir;
% wgs84初始的等分的经纬度坐标范围
L_range = linspace(100,150,Dimensions(1));
B_range = linspace(50,0,Dimensions(2));
% 构造插值运算需要输入的经纬度矩阵参数
[L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
%% main do
try
    % 判断传入的文件类型
    if(size(strfind(name,'nmefc_wrf'),1) == 1)
        output_args = NCtoImage(importFile);
    end
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
end

%% NCtoImage
% NC文件生成图片
function [ output_args ] = NCtoImage( input_args )
global Dimensions Time_interval yesterday VectorPicSize outputDirectory
try
    %% image init
    %设置全局的图片输出的格式
    SetImageLayout();
    ncid = netcdf.open( input_args, 'NC_NOWRITE' );% 打开文件
    variableContour3D={'PSFC'};% 三维等值线
    variableUV3D={'U10','V10'};% 三维风向标
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%创建xml，记录填色图的最大最小值
    docRootNode = docNode.getDocumentElement;%获取xml跟节点
    docRootNode.setAttribute('date',sprintf(yesterday));%设置时间属性
    %% variableContour3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variableContour3D
    for variable=variableContour3D
        hold off;
        start=[0,0,0]; % 起点位置 [0,0,0]
        count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % 向后计数 经度，纬度，时间
        vid=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
        ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
        %t=clock;% 开始计时
        % 开始生成图片
        set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L3' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L4' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L5' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L6' , '.png']);
            i=i+Time_interval;
        end
        clear ec;
        %disp(fix(etime(clock,t)));% 显示花费的时间
    end
    %% variableUV3D 风向标和6级等值线
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variableUV3D 生成三维风向标
    variable=variableUV3D;
    start=[0,0,0]; % 起点位置 [0,0,0]
    count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % 向后计数 经度，纬度，时间
    vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
    ecU=netcdf.getVar(ncid,vidU,start,count); % 读取U变量
    ecV=netcdf.getVar(ncid,vidV,start,count); % 读取V变量
    %t=clock;% 开始计时
    %生成6级等值线填色图(4倍为了使放大后效果好一点)
    set(gcf,'paperposition',[0 0 4*Dimensions(1)/get(0,'ScreenPixelsPerInch') 4*Dimensions(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUVContour3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10Contour','_',num2str(i) ,'_',yesterday , '.png']);
        i=i+Time_interval;
    end
    % 生成VectorPicSize（用于map3层）
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L3', '.png'],32);
        i=i+Time_interval;
    end
    % 生成图片2*VectorPicSize（用于map4层）
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L4', '.png'],16);
        i=i+Time_interval;
    end
    % 生成图片2*VectorPicSize（用于map5层）
    set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L5', '.png'],8);
        i=i+Time_interval;
    end
    % 生成图片 生成大张的图片8*VectorPicSize（用于map6-8层）
    set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L6', '.png'],4);
        i=i+Time_interval;
    end
    clear ecU ecV;
    
    output_args = 1;
    hour = yesterday(end-1:end);
    xmlwrite([outputDirectory,'wind',hour,'.xml'],docNode);%保存xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% 关闭文件
netcdf.close(ncid);
end

%% DrawContour3D
%画三维等值线，i为第几层,variable为参数名
function [] = DrawContour3D( eci,name )
global B_range L_range B_matrix L_matrix
hold off;
eci=flipud(eci');% 矩阵逆时针旋转90°
eci(eci(:,:)==-9999)=nan;% 将-9999设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'cubic');
[C,h] = contour(flipud(eci),'b');% 画图
clabel(C,h);
%set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);
SaveImage(name);%保存图片
clear eci;
end

%% DrawUV3D4D
%画风向标图，i为第几层，interval为风向标的间隔(不加间隔为251*251)
function [] = DrawUV3D4D( ec0U,ec0V,name,interval )
global B_range L_range B_matrix L_matrix
hold off;
ec0U=flipud(ec0U');% 矩阵逆时针旋转90°
ec0V=flipud(ec0V');% 矩阵逆时针旋转90°
ec0U(ec0U(:,:)==-9999)=nan;% 将-9999设为nan
ec0V(ec0V(:,:)==-9999)=nan;% 将-9999设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'cubic');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'cubic');
[x,y]=meshgrid(1:size(L_range,2),1:size(B_range,2));%经纬度的范围，主要是生成等距的网格
%quiver(flipud(ec0U(1:4:end,1:4:end)),flipud(ec0V(1:4:end,1:4:end))); %生成箭头
ec0U=flipud(ec0U);
ec0V=flipud(ec0V);
windbarbm(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U(1:interval:end,1:interval:end),ec0V(1:interval:end,1:interval:end))%生成风向标
set(gca,'XLim',[1 size(L_range,2)],'YLim',[1 size(B_range,2)]);%设置坐标范围windbarbm函数会改变坐标范围
SaveImage(name);%保存图片
clear ec0U ec0V;
end
%% DrawUVContour3D4D
%画风向标图，i为第几层，interval为风向标的间隔(不加间隔为251*251)
function [] = DrawUVContour3D4D( ec0U,ec0V,name )
global B_range L_range B_matrix L_matrix
hold off;
ec0U=flipud(ec0U');% 矩阵逆时针旋转90°
ec0V=flipud(ec0V');% 矩阵逆时针旋转90°
ec0U(ec0U(:,:)==-9999)=nan;% 将-9999设为nan
ec0V(ec0V(:,:)==-9999)=nan;% 将-9999设为nan
% 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'cubic');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'cubic');
eci=flipud(sqrt(ec0U.^2+ec0V.^2));
%画蓝色六级风(11)
[~,h]=contourf(eci(1:end,1:end),[11 11],'LineColor','blue');
ch=get(h,'children');
for k=ch
    set(k,'FaceColor','blue','FaceAlpha',1);
end
%画黄色七级风(13)
hold on;
[~,h2]=contourf(eci(1:end,1:end),[13 13],'LineColor','yellow');
ch2=get(h2,'children');
for k2=ch2
    set(k2,'FaceColor','yellow','FaceAlpha',1);
end
SaveImage(name);%保存图片
clear ec0U ec0V eci;
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
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%设置色带拉伸方式
colormap(jet(256));
if(exist([outputDirectory,yesterday],'dir')~=7)
    mkdir([outputDirectory,yesterday]);% 在当前文件夹下新建img文件夹，如果已存在会warning，不影响运行
end
end