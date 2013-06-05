function [ output_args ] = NetCDFtoImage_Cu( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue
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
%  MFILE:   NetCDFtoImage_Cu.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:    
try
    %% image init
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [721,421,13,13];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [683,445];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30.083,150.083,Dimensions(1));
    B_range = linspace(50.083,-19.917,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-14:end-5);
    MaskValue=32767;
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Cu';
    variable4D={'tz_h'};% ��ά��ɫͼ
    variableUV4D={'uz_h','vz_h'};% ��ά��ͷ
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',sprintf(Date));%����ʱ������
    %% variable4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    MaskValue=32767;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRaster(  ncid,variable4D,[0,0,0,0],[Dimensions(1),Dimensions(2),Dimensions(3),Dimensions(4)],Dimensions(3),Dimensions(4),docNode,docRootNode );
    %% variableUV4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageDir( ncid,variableUV4D,[0,0,0,0],[Dimensions(1),Dimensions(2),Dimensions(3),Dimensions(4)],Dimensions(3),Dimensions(4),[3,4,5],[24,12,6] );
    
    output_args = 1;
    hour = Date(end-1:end);
    xmlwrite([OutputDirectory,'cu',hour,'.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end



