function [ ] = NetCDFtoImageRaster( ncid,variables,start,count,levels,times,docNode,docRootNode )
global Time_interval Level_interval Date OutputDirectory DataType
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
    %stride=[251,251,121];
    vid=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
    ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
    i=0;j=0;
    %循环层数
    while i<levels
        %循环时间
        while j<times
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(i) , '-',Date];%文件名
            fullPath = [OutputDirectory,Date,'\',name, '.png'];%出图的图层路径（包括文件名）
            %画填色图(矩阵逆时针旋转90°)
            if(levels==1&&times~=1)%三维，经度纬度时间
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,j+1)'),fullPath);
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,i+1)'),fullPath);
            else
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,i+1,j+1)'),fullPath);
            end
            %有效波高
            if(strcmp(variable{1},'swh'))
                maxValue=maxValue/100;
                minValue=minValue/100;
            %谱峰周期
            elseif(strcmp(variable{1},'tps'))
                maxValue=maxValue/10;
                minValue=minValue/10;
            end
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            
            j=j+Time_interval;
        end
        j=0;
        i=i+Level_interval;
    end
    clear ec;
end
end