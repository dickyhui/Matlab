function [ output_args ] = NetCDFtoImage( importFile,outputDir,timeInterval,levelInterval )
%  读取NetCDF格式数值预报产品，经过坐标转换和内插，最后生成图片
%  importFile：输入文件
%  outputDir：输出文件夹
%  timeInterval：出图时间间隔
%  levelInterval：出图层数间隔
%  output_args返回1为正常运行，其他为出错
%  MFILE:   NetCDFtoImage.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13
%  MODIFY:  LinXianhui
%  DATE:    2013-03-20

%% main init
global Time_interval Level_interval OutputDirectory

% 设置图层的时间间隔 层数间隔 输出文件夹
Time_interval = timeInterval;
Level_interval = levelInterval;
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
OutputDirectory = outputDir;

%% main do
try
    % 判断传入的文件类型
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
% %获取nc的经纬度范围
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