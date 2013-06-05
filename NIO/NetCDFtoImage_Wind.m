function [ output_args ] = NetCDFtoImage_Wind( importFile,outputDir,timeInterval,levelInterval,timeStart )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval Time_Start LandMatrix
%  读取风场NetCDF格式数值预报产品生成图片
%  importFile：输入文件
%  output_args返回1为正常运行，其他为出错
%  Dimensions：数据参数四个维度的大小 经度，纬度，层数，时间
%  L_range：WGS84经度范围
%  B_range;WGS84纬度范围
%  L_matrix:与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix:与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  VectorPicSize：输出图片大小，大小对应于levels的最小级别的图片
%  DataType:数据类型（Wind/Wave/..）
%  MaskValue:缺省值
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:
%  DATE:
try
    %% image init
%     importFile = 'E:\win7workspace\NIO\MATLAB_NIO\数据\indian_wrf_2013052312.nc';
%     OutputDirectory = 'E:\win7workspace\NIO\MATLAB_NIO\数据\';
%     Time_interval = 60;
%     Level_interval = 1;
%     Time_Start = 0;
    
    % 设置图层的时间间隔 层数间隔 输出文件夹
       Time_interval = str2num(timeInterval);
       Level_interval = str2num(levelInterval);
       if(outputDir(end)~='\')
           outputDir(end+1)='\';
       end
       OutputDirectory = outputDir;
       Time_Start = str2num(timeStart);
    
    land=load('land.mat');
    LandMatrix = land.eccc;
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% 打开文件
    
    % 四个维度的大小 经度，纬度，层数，时间
    Dimensions = [476,251,6,121];
    %矢量图形出图大小（第三层）
    VectorPicSize = [540,295];
    % wgs84初始的等分的经纬度坐标范围
    L_range = linspace(30,125,Dimensions(1));
    B_range = linspace(30,-20,Dimensions(2));
    % 获取文件名中的日期
    [~, name, ~] = fileparts(importFile);
    Date=name(end-9:end);
    MaskValue=-9999;
    % 构造插值运算需要输入的经纬度矩阵参数
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Wind';
    variable3D={'Q2','RAINC','RAINNC'};% 三维填色图
    variable4D={'QVAPOR','QCLOUD'};% 四维填色图
    variable3DRain={'RAINC','RAINNC'};
    variable4DQVaporCloud={'QVAPOR','QCLOUD'};
    variableContour3DT2={'T2'};% 三维等值线
    variableContour3DPSFC={'PSFC'};% 三维等值线
    variableContour4DTT={'TT'};% 三维等值线
    variableUV3D={'U10','V10'};% 三维风向标
    variableUV4D={'UU','VV'};% 四维风向标
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %设置全局的图片输出的格式
    SetImageLayout();
    
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRasterWind(ncid,variable3D,Dimensions(1),Dimensions(2),1,Dimensions(4));
    %% variable4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRasterWind(ncid,variable4D,Dimensions(1),Dimensions(2),3,Dimensions(4));
    %% variable3DRain
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRasterWindMerge(ncid,variable3DRain,Dimensions(1),Dimensions(2),1,Dimensions(4));
    %% variable4DQVaporCloud
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRasterWindMerge(ncid,variable4DQVaporCloud,Dimensions(1),Dimensions(2),3,Dimensions(4));
    %% variableContour3DT2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageContourWind( ncid,variableContour3DT2,Dimensions(1),Dimensions(2),1,Dimensions(4),[3,4,5],0 );%[0,10,20,26,27:0.5:32,34,40,50]
     %% variableContour3DPSFC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageContourWind( ncid,variableContour3DPSFC,Dimensions(1),Dimensions(2),1,Dimensions(4),[3,4,5],[800:4:1200] );
    %% variableContour4DTT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageContourWind( ncid,variableContour4DTT,Dimensions(1),Dimensions(2),3,Dimensions(4),[3,4,5],0 );
    %% variableUV3D 风向标
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageWindBar( ncid,variableUV3D,Dimensions(1),Dimensions(2),1,Dimensions(4),[3,4,5],[32,16,8]);
    %% variableUV4D 风向标
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageWindBar( ncid,variableUV4D,Dimensions(1),Dimensions(2),3,Dimensions(4),[3,4,5],[32,16,8]);
    
    %% 大风区等值线图
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    DrawUVContour(ncid,variableUV3D,Dimensions(1),Dimensions(2),1,Dimensions(4));
    hold off;
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    DrawUVContour(ncid,variableUV4D,Dimensions(1),Dimensions(2),3,Dimensions(4));
    
    output_args = 1;
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% 关闭文件
netcdf.close(ncid);
end


