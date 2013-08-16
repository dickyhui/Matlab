function [ output_value ] = weatherforcastInterp( importFile,varname )
%importFile = 'E:\win7workspace\Weather\weather_forecast_nc\ecfine.I2013032512.000.F2013032512.nc';
%importFile = 'E:\win7workspace\Weather\weather_forecast_nc\gfs.I2013032512.000.F2013032512.nc';
%importFile = 'E:\win7workspace\Weather\weather_forecast_nc\jmafine.I2013032512.000.F2013032512.nc';
%importFile = 'E:\win7workspace\Weather\weather_forecast_nc\t639.I2013032512.000.F2013032512.nc';
%varname = 'h';

try
	% Open a netCDF file.
	ncid = netcdf.open( importFile, 'NC_NOWRITE' );
    % Get ID of variable, given its name.
    varid = netcdf.inqVarID(ncid,varname);
    % Get information about the variable in the file.
    [varname, ~, dimids, ~] = netcdf.inqVar(ncid,varid);
    
    Dimensions = [];
    for di=dimids
        % Get name and length of first dimension
        [~, dimlen] = netcdf.inqDim(ncid,di);
        Dimensions = [Dimensions dimlen];
    end
    
    start=[];
    count=Dimensions;
    for di=Dimensions
        start = [start 1];
        if length(start)>2
            count(length(start))=1;
        end
    end
    netcdf.close(ncid);
    %��ȡ������ֵ
    %ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
    ec=ncread(importFile,varname,start,count);
    ec(ec(:,:)==-32800)=nan;% ��-9999��Ϊnan
    L_range = reshape(ncread(importFile,'lon'),1,[]);
    B_range = reshape(ncread(importFile,'lat'),1,[]);
    %ת��
    ec=ec';
    %����������
    points = [120.17,30.23;119.7,30.22;119.02,29.62;119.27,29.48;119.68,29.82];
    %�����ֵ���
    interPvalue = [];
    
    for i=1:5
        point = points(i,:);
        interPvalue=[interPvalue,interp2(L_range,B_range,ec,point(1),point(2),'linear')];
    end
    output_value = interPvalue;
catch ME
    output_value = [-32800 -32800 -32800 -32800 -32800];
end
end