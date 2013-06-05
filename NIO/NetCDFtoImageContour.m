function [  ] = NetCDFtoImageContour( ncid,variables,start,count,levels,times,piclevels,vector)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType LandMatrix
%  生成NetCDF的等值线图
%  ncid：NetCDF的ID
%  variables:等值线的数据参数
%  start:nc文件数据的起点位置
%  count:向后计数 二维为经度和纬度，三维加层数或时间
%  levels:该参数数据的层数
%  times:该参数数据的时间数
%  piclevels：生成图片的级别（3,4,5,6）
%  vector:指定等值线的绘制高度
%  Time_interval：数据时间间隔
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  VectorPicSize：输出图片大小，大小对应于levels的最小级别的图片
%  DataType:数据类型（Wind/Wave/..）
%  MFILE:   NetCDFtoImageContour.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

for variable=variables
    hold off;
    vid=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
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
                fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'Contour','-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
               
                if(levels==1&&times~=1)%三维，经度纬度时间
                    eci=flipud(ec(:,:,j+1)');
                elseif(levels~=1&&times==1)%三维，经度纬度层数
                    eci=flipud(ec(:,:,i+1)');
                else
                    eci=flipud(ec(:,:,i+1,j+1)');
                end
                DrawContour( eci,fullPath,vector);
               
                j=j+Time_interval;
            end
            j=0;
            i=i+Level_interval;
        end
        l=l+1;
    end
    clear ec;
end
end

