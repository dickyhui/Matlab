function [ output_args ] = NetCDFtoImage_Wave( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval Time_Start
%  ��ȡ����NetCDF��ʽ��ֵԤ����Ʒ����ͼƬ
%  importFile�������ļ�
%  output_args����1Ϊ�������У�����Ϊ����
%  Dimensions�����ݲ����ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
%  L_range��WGS84���ȷ�Χ
%  B_range;WGS84γ�ȷ�Χ
%  L_matrix:��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrix:��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  VectorPicSize�����ͼƬ��С����С��Ӧ��levels����С�����ͼƬ
%  DataType:�������ͣ�Wind/Wave/..��
%  MaskValue:ȱʡֵ
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:    
try
%     importFile = 'E:\win7workspace\NIO\MATLAB_NIO\����\wave20121121.nc';
%     OutputDirectory = 'E:\win7workspace\NIO\MATLAB_NIO\����\';
%     Time_interval = 60;
%     Level_interval = 1;
%     Time_Start = 0;
    %% image init  
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [553,271,1,73];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [523,265];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30,122,Dimensions(1));
    B_range = linspace(30,-15,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-7:end);
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Wave';
    MaskValue=-900;
    variable3D={'swh'};% ��ά��ɫͼ
    variableContour3D={'tps'};% ��ά��ֵ��
    variableDir3D={'dir'};% ��ά��ͷ
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',sprintf(Date));%����ʱ������
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    MaskValue=-900;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRaster(ncid,variable3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(4)],1,Dimensions(4),docNode,docRootNode);
    
    %% variableContour3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MaskValue=-90;
    NetCDFtoImageRaster(ncid,variableContour3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(4)],1,Dimensions(4),docNode,docRootNode);
     %% variableDir3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MaskValue=-9;
    NetCDFtoImageDir( ncid,variableDir3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(4)],1,Dimensions(4),[3,4,5],[16,8,4] );

    output_args = 1;
    xmlwrite([OutputDirectory,'wave','.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end


