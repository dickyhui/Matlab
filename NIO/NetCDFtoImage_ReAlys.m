function [ output_args ] = NetCDFtoImage_ReAlys( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval
%  ��ȡ�ٷ���NetCDF��ʽ��ֵԤ����Ʒ����ͼƬ
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
%  MFILE:   NetCDFtoImage_ReAlys.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-26
%  MODIFY:  
%  DATE:    
try
    %% image init   
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [184,91,35,1];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [521,265];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30.5,122,Dimensions(1));
    B_range = linspace(30,-15,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-7:end);
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'ReAlys';    
    variable3D={'density','soundspeed','salt','temp'};% ��ά��ɫͼ
    variable2D={'el'};% ��ά��ɫͼ
    variableDir3D={'u','v'};% ��ά��ͷ
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',sprintf(Date));%����ʱ������    
    
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
        mkdir(outputFolder);  %�����ļ���
    end
    xmlwrite([outputFolder,'reAlys_',Date,'.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end


