function [  ] = NetCDFtoImageRasterWindMerge( ncid,variable,dimLon,dimLat,levels,times )
global Time_interval Date OutputDirectory DataType Time_Start MaskValue
%  生成NetCDF的填色图
%  ncid：NetCDF的ID
%  variables:填色图的数据参数
%  start:nc文件数据的起点位置
%  count:向后计数 二维为经度和纬度，三维加层数或时间
%  levels:该参数数据的层数
%  times:该参数数据的时间数
%  docNode：xml文件，保存填色图的最大最小值和数据日期
%  docRootNode：xml文件的根节点
%  Time_interval：数据时间间隔
%  Level_interval：数据层数间隔
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  DataType:数据类型（Wind/Wave/..）
%  MFILE:   NetCDFtoImageRaster.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

vid1=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
vid2=netcdf.inqVarID(ncid,variable{2}); % 获取变量名的ID
%ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
if(levels==1&&times~=1)   %三维，经度纬度时间
    levelist = 0;
else
    levelval = netcdf.getAtt(ncid,vid1, 'level_hpa');
    m = 1;
    for n=1:length(levelval)
        if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
            levelist(m) = n-1;
            m = m + 1;
        end
    end
end
i=0;j=Time_Start;p=0;

for i = levelist
    while j<times
        name=[DataType,'-', variable{1}, variable{2}, '-', num2str(j) , '-', num2str(p) , '-',Date];%文件名
        fullPath = [OutputDirectory,Date,'\',name, '.png'];%出图的图层路径（包括文件名）
        if(levels==1&&times~=1)   %三维，经度纬度时间
            ec1=netcdf.getVar(ncid,vid1,[0,0,j],[dimLon,dimLat,1]); % 读取变量
            ec1(ec1(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec2=netcdf.getVar(ncid,vid2,[0,0,j],[dimLon,dimLat,1]); % 读取变量
            ec2(ec2(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1)'+ec2(:,:,1)');
        elseif(levels~=1&&times==1)%三维，经度纬度层数
            ec1=netcdf.getVar(ncid,vid1,[0,0,i],[dimLon,dimLat,1]); % 读取变量
            ec1(ec1(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec2=netcdf.getVar(ncid,vid2,[0,0,i],[dimLon,dimLat,1]); % 读取变量
            ec2(ec2(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1)'+ec2(:,:,1)');
        else
            ec1=netcdf.getVar(ncid,vid1,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取变量
            ec1(ec1(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec2=netcdf.getVar(ncid,vid2,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取变量
            ec2(ec2(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1,1)'+ec2(:,:,1,1)');
        end
        
        colormap(setColorMap('blue'));
        DrawRasterWind(eci,fullPath);
        
        j=j+Time_interval;
    end
    j = Time_Start;
    p = p + 1;
end
clear ec;
end