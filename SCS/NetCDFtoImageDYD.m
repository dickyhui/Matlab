function [ output_args ] = NetCDFtoImageDYD( importFile,outputDir,timeInterval )
%  读取DAT格式数值预报产品，经过坐标转换和内插，最后生成钓鱼岛海区格网图片
%  importFile为输入文件
%  outputDir为输出文件夹
%  output_args返回1为正常运行，0为出错
%  出图数据格式：（目前只有W10产品）
%  Wind_产品DYD_时次_时间_级别
%  Wind_W10DYD_0_2012112108_D0
%  MFILE:   NetCDFtoImageDYD.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
%  importFile = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\nmefc_wrf_2013012108.nc';
%  outputDir = 'E:\win7workspace\SCS\系统备份\20121201\target\fstdata\';
%  timeInterval = 12;

global Dimensions L_range B_range Time_interval VectorPicSize yesterday outputDirectory
% 四个维度的大小 经度，纬度，时间
Dimensions = [251,251,6,121];
%矢量图形出图大小（第三层）
VectorPicSize = [547,255];
% 设置图层的时间间隔，数据源就是6小时间隔，所以要是6的倍数
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
% NC文件生成图片，浪高填色图
function [ output_args ] = NCtoImage( input_args )
global Dimensions Time_interval yesterday VectorPicSize L_range B_range L_matrixDYD B_matrixDYD outputDirectory
try
    %设置全局的图片输出的格式
    SetImageLayout();
    %% W10 风向标
    ncid = netcdf.open( input_args, 'NC_NOWRITE' );% 打开文件
    start=[0,0,0]; % 起点位置 [0,0,0]
    count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % 向后计数 经度，纬度，时间
    vidU=netcdf.inqVarID(ncid,'U10'); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,'V10'); % 获取V变量名的ID
    ecU=netcdf.getVar(ncid,vidU,start,count); % 读取U变量
    ecV=netcdf.getVar(ncid,vidV,start,count); % 读取V变量
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %空图层，3-5级用
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    cla;
    i=0;
    while i<Dimensions(4)
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D0'];
        SaveImage([outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %第六级图层
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0V=flipud(ecV(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0U(ec0U(:,:)==-9999)=nan;% 将-9999设为nan
        ec0V(ec0V(:,:)==-9999)=nan;% 将-9999设为nan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        DimensionsDYD = [2*20+1,2*10+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % 构造插值运算需要输入的经纬度矩阵参数
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%将风的大小改为等级
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D6'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %第七级图层
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0V=flipud(ecV(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0U(ec0U(:,:)==-9999)=nan;% 将-9999设为nan
        ec0V(ec0V(:,:)==-9999)=nan;% 将-9999设为nan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        DimensionsDYD = [2*40+1,2*20+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % 构造插值运算需要输入的经纬度矩阵参数
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%将风的大小改为等级
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D7'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %第八级图层
    set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0V=flipud(ecV(:,:,i+1)');% 矩阵逆时针旋转90°
        ec0U(ec0U(:,:)==-9999)=nan;% 将-9999设为nan
        ec0V(ec0V(:,:)==-9999)=nan;% 将-9999设为nan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        DimensionsDYD = [2*80+1,2*40+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % 构造插值运算需要输入的经纬度矩阵参数
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%将风的大小改为等级
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D8'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
    
    output_args = 1;
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
netcdf.close(ncid);
end

%% DrawW10
%画填色图
function [] = DrawW10( eci,name )
global L_matrixDYD
hold off;
datagrid(eci,0,6);% 画格网图
set(gca,'XLim',[1 size(L_matrixDYD,2)],'YLim',[1 size(L_matrixDYD,1)]);%设置坐标范围datagrid函数会改变坐标范围
SaveImage(name);%保存图片
end

%% windLevel
%画填色图
function [ec] = windLevel( ec )
ec(ec<3)=1;
ec(ec>=3&ec<5)=2;
ec(ec>=5&ec<7)=3;
ec(ec>=7&ec<9)=4;
ec(ec>=9&ec<11)=5;
ec(ec>=11&ec<13)=6;
ec(ec>=13&ec<15)=7;
ec(ec>=15&ec<17)=8;
ec(ec>=17)=9;
end

%% SaveImage
%保存图片,input_args为图层名
function [  ] = SaveImage( input_args )
global outputDirectory yesterday
axis off;% 关闭坐标轴
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[ outputDirectory,yesterday,'\default.png']);% 输出图片
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
global Dimensions  outputDirectory yesterday
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