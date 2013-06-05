function [ ] = NetCDFtoImageRasterWind( ncid,variables,dimLon,dimLat,levels,times )
global Time_interval Date OutputDirectory DataType Time_Start LandMatrix
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

for variable=variables
    vid=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
    %ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
    if(levels==1&&times~=1)   %三维，经度纬度时间
        levelist = 0;
    else
        levelval = netcdf.getAtt(ncid,vid, 'level_hpa');
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
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(p) , '-',Date];%文件名
            fullPath = [OutputDirectory,Date,'\',name, '.png'];%出图的图层路径（包括文件名）
            
            if(levels==1&&times~=1)   %三维，经度纬度时间
                ec=netcdf.getVar(ncid,vid,[0,0,j],[dimLon,dimLat,1]); % 读取变量
                eci = flipud(ec(:,:,1)');
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                ec=netcdf.getVar(ncid,vid,[0,0,i],[dimLon,dimLat,1]); % 读取变量
                eci = flipud(ec(:,:,1)');
            else
                ec=netcdf.getVar(ncid,vid,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取变量
                eci = flipud(ec(:,:,1,1)');
            end
            
            colormap(jet(256));
            %温度小于15°设为nan
            if((strcmp(variable{1},'TT')&&p==0)||strcmp(variable{1},'T2'))
                %eci(eci<288.15)=nan; 
                %eci(isnan(LandMatrix))=nan;
            %两米比湿去掉小于0.015
            elseif(strcmp(variable{1},'Q2'))
                colormap(setColorMap('blue'));
                 %eci(eci<0.015)=nan; 
            %降水范围设为0-128
            elseif(strcmp(variable{1},'RAINC')||strcmp(variable{1},'RAINNC'))
                 colormap(setColorMap('blue'));
                 eci(eci<0)=0; 
                 %eci(eci>128)=nan; 
            %QVAPOR混合比去掉负数
            elseif(strcmp(variable{1},'QVAPOR'))
                colormap(setColorMap('blue'));
                 eci(eci<0)=0; 
            %QCLOUD混合比去掉负数和0
            elseif(strcmp(variable{1},'QCLOUD'))
                colormap(setColorMap('blue'));
                 eci(eci<=0)=0; 
                 %eci(eci>0.0001)=nan;
            %气压1000百帕以下设为nan
            elseif(strcmp(variable{1},'PSFC'))
                %eci(eci<80000)=nan; 
                %eci(isnan(LandMatrix))=nan;
            end
            [maxValue,minValue]=DrawRasterWind(eci,fullPath);
                
            j=j+Time_interval;
        end
        j = Time_Start;
        p = p + 1;
    end
    clear ec;
end
end