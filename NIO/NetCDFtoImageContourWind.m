function [  ] = NetCDFtoImageContourWind( ncid,variables,dimLon,dimLat,levels,times,piclevels,vector)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType LandMatrix Time_Start L_range B_range L_matrix B_matrix MaskValue
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
    
    l=1;
    %循环级别
    for level=piclevels
        %根据不同的级别(level)设置出图的大小，呈指数递增
        set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;j=Time_Start;p=0;
        %循环层数
        for i=levelist
            %循环时间
            while j<times
                %出图的图层路径（包括文件名）
                fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'Contour','-',num2str(j) ,'-',num2str(p) ,'-',Date , '-L',num2str(level), '.png'];
                
                if(levels==1&&times~=1)%三维，经度纬度时间
                    ec=netcdf.getVar(ncid,vid,[0,0,j],[dimLon,dimLat,1]); % 读取变量
                    eci=flipud(ec(:,:,1)');
                elseif(levels~=1&&times==1)%三维，经度纬度层数
                    ec=netcdf.getVar(ncid,vid,[0,0,i],[dimLon,dimLat,1]); % 读取变量
                    eci=flipud(ec(:,:,1)');
                else
                    ec=netcdf.getVar(ncid,vid,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取变量
                    eci=flipud(ec(:,:,1,1)');
                end
                
                %气压
                if(strcmp(variable{1},'PSFC'))
                    eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                    eci=eci/100;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    eccc=eci;
                    eccc(~isnan(LandMatrix))=nan;
                    eccc=interp2(L_range,B_range,eccc,L_matrix,B_matrix,'linear');
                    [realMin realMax] = getRealMinMax(eccc);
                    [min max] = getMinMax(ecc,2);%两倍的标准差
                    max=realMax;%middle最大值设为实际最大值，所以只有低值和中值的色带
                    vectorMiddle=min:2.5:max;
                    min0=max;
                    max0=floor((realMax-min0)/10)*10+min0;
                    vectorMax=min0:100:max0;
                    max0=min;
                    min0=max0-floor((max0-realMin)/10)*10;
                    vectorMin=min0:100:max0;
                    vector=[vectorMin,vectorMiddle];%等高线没有高值区
                    colormap(setColorMap('bluered',vectorMin,vectorMiddle,vectorMax));
                    DrawContourf( eci,fullPath,vector);
                elseif(strcmp(variable{1},'TT'))
                    eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                    eci=eci-273.15;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    eccc=eci;
                    eccc(~isnan(LandMatrix))=nan;
                    eccc=interp2(L_range,B_range,eccc,L_matrix,B_matrix,'linear');
                    [realMin realMax] = getRealMinMax(eccc);
                    [min max] = getMinMax(ecc,1);
                    vectorMiddle=min:1:max;
                    min0=max;
                    max0=floor((realMax-min0)/10)*10+min0;
                    vectorMax=min0:10:max0;
                    max0=min;
                    min0=max0-floor((max0-realMin)/10)*10;
                    vectorMin=min0:10:max0;
                    vector=[vectorMin,vectorMiddle,vectorMax];
                    colormap(setColorMap('bluered',vectorMin,vectorMiddle,vectorMax));
                    DrawContourf( eci,fullPath,vector);
                elseif(strcmp(variable{1},'T2'))
                    eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                    eci=eci-273.15;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    eccc=eci;
                    eccc(~isnan(LandMatrix))=nan;
                    eccc=interp2(L_range,B_range,eccc,L_matrix,B_matrix,'linear');
                    [realMin realMax] = getRealMinMax(eccc);
                    [min max] = getMinMax(ecc,1);
                    vectorMiddle=min:0.5:max;
                    min0=max;
                    max0=floor((realMax-min0)/10)*10+min0;
                    vectorMax=min0:10:max0;
                    max0=min;
                    min0=max0-floor((max0-realMin)/10)*10;
                    vectorMin=min0:10:max0;
                    vector=[vectorMin,vectorMiddle,vectorMax];
                    colormap(setColorMap('bluered',vectorMin,vectorMiddle,vectorMax));
                    DrawContourf( eci,fullPath,vector);
                else
                    DrawContour( eci,fullPath,vector);
                end
                
                j=j+Time_interval;
            end
            j=Time_Start;
            p = p + 1;
        end
        l=l+1;
    end
    clear ec;
end
end

function [min max]=getMinMax(ecc,multiple)
meanValue=nanmean(reshape(ecc,1,[]));
std=nanstd(reshape(ecc,1,[]));
min=meanValue-multiple*std;
max=meanValue+multiple*std;
min=floor(min);
max=ceil(max);
end

function [realMin realMax]=getRealMinMax(eccc)
realMax=max(max(eccc));
realMin=min(min(eccc));
end

