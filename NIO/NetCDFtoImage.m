function [ output_args ] = NetCDFtoImage( importFile,outputDir,timeInterval,levelInterval )
%  ��ȡNetCDF��ʽ��ֵԤ����Ʒ����������ת�����ڲ壬�������ͼƬ
%  importFile�������ļ�
%  outputDir������ļ���
%  timeInterval����ͼʱ����
%  levelInterval����ͼ�������
%  output_args����1Ϊ�������У�����Ϊ����
%  MFILE:   NetCDFtoImage.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13
%  MODIFY:  LinXianhui
%  DATE:    2013-03-20

%% main init
global Time_interval Level_interval OutputDirectory

% ����ͼ���ʱ���� ������� ����ļ���
Time_interval = timeInterval;
Level_interval = levelInterval;
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
OutputDirectory = outputDir;

%% main do
try
    % �жϴ�����ļ�����
    %if(size(strfind(importFile,'indian_wrf'),1) == 1)
        %output_args = NetCDFtoImage_Wind(importFile);
    %else
    if(size(strfind(importFile,'NCEP_aden_cu'),1) == 1)
        output_args = NetCDFtoImage_Cu(importFile);
    elseif(size(strfind(importFile,'wave'),1) == 1)
        output_args = NetCDFtoImage_Wave(importFile);
    elseif(size(strfind(importFile,'BLD'),1) == 1)
        output_args = NetCDFtoImage_BLD(importFile);
    elseif(size(strfind(importFile,'MLD'),1) == 1)
        output_args = NetCDFtoImage_MLD(importFile);
    elseif(size(strfind(importFile,'surfacecurrent'),1) == 1)
        output_args = NetCDFtoImage_SurfCur(importFile);
    elseif(size(strfind(importFile,'TC_'),1) == 1)
        output_args = NetCDFtoImage_TC(importFile);
    elseif(size(strfind(importFile,'TD_'),1) == 1)
        output_args = NetCDFtoImage_TD(importFile);
    else
        output_args = NetCDFtoImage_ReAlys(importFile);
    end
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
end

% %% GetNCLongLat
% %��ȡnc�ľ�γ�ȷ�Χ
% function [L_range B_range] = GetNCLonLat(ncid)
% try
%     lonVarId = netcdf.inqVarID(ncid,'longitude');
%     latVarId = netcdf.inqVarID(ncid,'latitude');
% catch e
%     lonVarId = netcdf.inqVarID(ncid,'lon');
%     latVarId = netcdf.inqVarID(ncid,'lat');
% end
% L_range = netcdf.getVar(ncid,lonVarId);
% B_range = netcdf.getVar(ncid,latVarId);
% L_range = reshape(L_range,size(L_range,2),size(L_range,1));
% B_range = reshape(B_range,size(B_range,2),size(B_range,1));
% end