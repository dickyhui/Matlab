function [ output_args ] = NetCDFtoImage_MLD( importFile )
global Dimensions L_range B_range L_matrix B_matrix Date DateTime VectorPicSize OutputDirectory DataType MaskValue Time_interval Level_interval
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
    %% image init
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [61,36,1,60];
    %ʸ��ͼ�γ�ͼ��С�������㣩
    VectorPicSize = [610,360];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(40,100,Dimensions(1));
    B_range = linspace(30,-5,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'AnlysDgnst';
    MaskValue=9999;
    variable3D={'mixeddp','mixedgmdp','mixedgmtp','mixedsp','mixedtmdp','mixedtmtp','mixedtp'};% ��ά��ɫͼ
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    Date='MLD';
    OutputDirectory = [OutputDirectory,DataType,'\'];
    SetImageLayout();
    DateTime=name(end-12:end-7);
    fullDir = [OutputDirectory,'MLD','.xml'];
    if(exist(fullDir,'file'))
        fid = fopen(fullDir);
        data = fread(fid,'*char')';
        data_new = strrep(data,char(10),'');
        fclose(fid);
        frid = fopen(fullDir,'w+');
        fprintf(frid,'%s',data_new);
        fclose(frid);
        docNode=xmlread(fullDir);%��ȡXML�ļ�
        docRootNode=docNode.getDocumentElement();%��ȡ���ڵ�
    else
        docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
        docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
        %docRootNode.setAttribute('date',sprintf(Date));%����ʱ������\
    end
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    NetCDFtoImageRasterAnlysDgnst(ncid,variable3D,[0,0,0],[Dimensions(1),Dimensions(2),Dimensions(4)],1,Dimensions(4),docNode,docRootNode);
    
    output_args = 1;
    xmlwrite(fullDir,docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end


