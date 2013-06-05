function [ output_args ] = NetCDFtoImage_Wind( importFile,outputDir,timeInterval,levelInterval,timeStart )
global Dimensions L_range B_range L_matrix B_matrix Date VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval Time_Start LandMatrix
%  ��ȡ�糡NetCDF��ʽ��ֵԤ����Ʒ����ͼƬ
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
    %% image init
%     importFile = 'E:\win7workspace\NIO\MATLAB_NIO\����\indian_wrf_2013052312.nc';
%     OutputDirectory = 'E:\win7workspace\NIO\MATLAB_NIO\����\';
%     Time_interval = 60;
%     Level_interval = 1;
%     Time_Start = 0;
    
    % ����ͼ���ʱ���� ������� ����ļ���
       Time_interval = str2num(timeInterval);
       Level_interval = str2num(levelInterval);
       if(outputDir(end)~='\')
           outputDir(end+1)='\';
       end
       OutputDirectory = outputDir;
       Time_Start = str2num(timeStart);
    
    land=load('land.mat');
    LandMatrix = land.eccc;
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [476,251,6,121];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [540,295];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30,125,Dimensions(1));
    B_range = linspace(30,-20,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-9:end);
    MaskValue=-9999;
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Wind';
    variable3D={'Q2','RAINC','RAINNC'};% ��ά��ɫͼ
    variable4D={'QVAPOR','QCLOUD'};% ��ά��ɫͼ
    variable3DRain={'RAINC','RAINNC'};
    variable4DQVaporCloud={'QVAPOR','QCLOUD'};
    variableContour3DT2={'T2'};% ��ά��ֵ��
    variableContour3DPSFC={'PSFC'};% ��ά��ֵ��
    variableContour4DTT={'TT'};% ��ά��ֵ��
    variableUV3D={'U10','V10'};% ��ά�����
    variableUV4D={'UU','VV'};% ��ά�����
    OutputDirectory = [OutputDirectory,DataType,'\'];
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
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
    %% variableUV3D �����
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageWindBar( ncid,variableUV3D,Dimensions(1),Dimensions(2),1,Dimensions(4),[3,4,5],[32,16,8]);
    %% variableUV4D �����
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NetCDFtoImageWindBar( ncid,variableUV4D,Dimensions(1),Dimensions(2),3,Dimensions(4),[3,4,5],[32,16,8]);
    
    %% �������ֵ��ͼ
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
% �ر��ļ�
netcdf.close(ncid);
end


