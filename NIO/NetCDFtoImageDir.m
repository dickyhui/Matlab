function [ ] = NetCDFtoImageDir(ncid,variables,start,count,levels,times,piclevels,picinterval)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType
%  NetCDF生成箭头
%  ncid：NetCDF的ID
%  variables:箭头的数据参数(参数只能是一个或者两个)
%  start:nc文件数据的起点位置
%  count:向后计数 二维为经度和纬度，三维加层数或时间
%  levels:该参数数据的层数
%  times:该参数数据的时间数
%  piclevels：生成图片的级别（3,4,5,6）
%  picinterval：根据图片的不同级别设置数据间隔（32,16,8,4）
%  Time_interval：数据时间间隔
%  Level_interval：数据层数间隔
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  VectorPicSize：输出图片大小，大小对应于levels的最小级别的图片
%  DataType:数据类型（Wind/Wave/..）
%  MFILE:   NetCDFtoImageDir.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

switch length(variables)
    case 1  %只有一个参数，画无大小的箭头
        vid=netcdf.inqVarID(ncid,variables{1}); % 获取变量名的ID
        ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
        l=1;
        %循环级别
        for level=piclevels
            %根据不同的级别(level)设置出图的大小，呈指数递增
            set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
            i=0;j=0;
            %循环层数
            while i<levels
                %循环时间
                while j<times
                    %出图的图层路径（包括文件名）
                    fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
                    %画箭头(矩阵逆时针旋转90°)
                    if(levels==1&&times~=1)%三维，经度纬度时间
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,j+1)'));
                    elseif(levels~=1&&times==1)%三维，经度纬度层数
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,i+1)'));
                    else
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,i+1,j+1)'));
                    end
                    j=j+Time_interval;
                end
                j=0;
                i=i+Level_interval;
            end
            l=l+1;
        end
    case 2  %有两个参数，画带大小的箭头
        vidU=netcdf.inqVarID(ncid,variables{1}); % 获取U变量名的ID
        vidV=netcdf.inqVarID(ncid,variables{2}); % 获取V变量名的ID
        ecU=netcdf.getVar(ncid,vidU,start,count); % 读取U变量
        ecV=netcdf.getVar(ncid,vidV,start,count); % 读取V变量
        l=1;
        %循环级别
        for level=piclevels
            %根据不同的级别(level)设置出图的大小，呈指数递增
            set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
            i=0;j=0;
            %循环层数
            while i<levels
                %循环时间
                while j<times
                    %出图的图层路径（包括文件名）
                    fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},variables{2},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
                    %画箭头(矩阵逆时针旋转90°)
                    if(levels==1&&times~=1)%三维，经度纬度时间
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,j+1)'),flipud(ecV(:,:,j+1)'));
                    elseif(levels~=1&&times==1)%三维，经度纬度层数
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,i+1)'),flipud(ecV(:,:,i+1)'));
                    else
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,i+1,j+1)'),flipud(ecV(:,:,i+1,j+1)'));
                    end
                    j=j+Time_interval;
                end
                j=0;
                i=i+Level_interval;
            end
            l=l+1;
        end
        
        clear ec;
end

