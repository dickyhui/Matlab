function [ output_args ] = NetCDFtoImage_ReAlys( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval
%  读取再分析NetCDF格式数值预报产品生成图片
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
%  MFILE:   NetCDFtoImage_ReAlys.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-26
%  MODIFY:  
%  DATE:    
try
    %% image init   
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% 打开文件
    % 四个维度的大小 经度，纬度，层数，时间
    Dimensions = [184,91,35,1];
    %矢量图形出图大小（第三层）
    VectorPicSize = [521,265];
    % wgs84初始的等分的经纬度坐标范围
    L_range = linspace(30.5,122,Dimensions(1));
    B_range = linspace(30,-15,Dimensions(2));
    % 获取文件名中的日期
    [~, name, ~] = fileparts(importFile);
    Date=name(end-7:end);
    % 构造插值运算需要输入的经纬度矩阵参数
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'ReAlys';    
    variable3D={'density','soundspeed','salt','temp'};% 三维填色图
    variable2D={'el'};% 二维填色图
    variableDir3D={'u','v'};% 三维箭头
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %设置全局的图片输出的格式
    SetImageLayout();
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%创建xml，记录填色图的最大最小值
    docRootNode = docNode.getDocumentElement;%获取xml跟节点
    docRootNode.setAttribute('date',sprintf(Date));%设置时间属性    
    
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    MaskValue=9999;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRaster(ncid,variable3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(3)],35,1,docNode,docRootNode);
    %% variable2D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    MaskValue=9999;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRaster(ncid,variable2D,[0,0],[Dimensions(1),Dimensions(2)],1,1,docNode,docRootNode);
   %% variableDir3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MaskValue=9999;
    NetCDFtoImageDir( ncid,variableDir3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(3)],35,1,[3,4,5],[8,4,2] );
    
    output_args = 1;
    outputFolder = [OutputDirectory,'reAlys_xml\'];
    if(exist(outputFolder,'dir') ~= 7)
        mkdir(outputFolder);  %创建文件夹
    end
    xmlwrite([outputFolder,'reAlys_',Date,'.xml'],docNode);%保存xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% 关闭文件
netcdf.close(ncid);
end


