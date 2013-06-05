function [ output_args ] = NetCDFtoImage_TC( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval
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
%  MFILE:   NetCDFtoImage_TC.m
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
    Dimensions = [553,271,21,1];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [523,265];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30,122,Dimensions(1));
    B_range = linspace(30,-15,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-9:end);
    MaskValue=-9999;
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'TC';
    variableUV3D={'U','V'};% ��ά��ͷ
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    OutputDirectory = [OutputDirectory,DataType,'\'];
    SetImageLayout();

    %% variableUV3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageDir( ncid,variableUV3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(3)],Dimensions(3),1,[3,4,5],[32,16,8] );
    
    output_args = 1;

catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end



