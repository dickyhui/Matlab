function [ output_args ] = NetCDFtoImageWindXML( importFile,outputDir,timeInterval,levelInterval)
global Dimensions L_range B_range L_matrix B_matrix Date OutputDirectory DataType MaskValue Time_interval Level_interval
%  读取风场NetCDF格式数值预报产品生成图片
%  importFile：输入文件
%  output_args返回1为正常运行，其他为出错
%  Dimensions：数据参数四个维度的大小 经度，纬度，层数，时间
%  L_range：WGS84经度范围
%  B_range;WGS84纬度范围
%  L_matrix:与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix:与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  VectorPicSize：输出图片大小，大小对应于levels的最小级别的图片
%  DataType:数据类型（Wind/Wave/..）
%  MaskValue:缺省值
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:
%  DATE:
try
    %% image init
%         importFile = 'E:\win7workspace\NIO\MATLAB_NIO\数据\indian_wrf_2013052312.nc';
%         OutputDirectory = 'E:\win7workspace\NIO\MATLAB_NIO\数据\';
%         Time_interval = 60;
%         Level_interval = 1;
    
    %设置图层的时间间隔 层数间隔 输出文件夹
    Time_interval = str2num(timeInterval);
    Level_interval = str2num(levelInterval);
    if(outputDir(end)~='\')
        outputDir(end+1)='\';
    end
    OutputDirectory = outputDir;
    
    land=load('land.mat');
    LandMatrix = land.eccc;
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% 打开文件
    
    % 四个维度的大小 经度，纬度，层数，时间
    Dimensions = [476,251,6,121];
    % wgs84初始的等分的经纬度坐标范围
    L_range = linspace(30,125,Dimensions(1));
    B_range = linspace(30,-20,Dimensions(2));
    % 获取文件名中的日期
    [~, name, ~] = fileparts(importFile);
    Date=name(end-9:end);
    MaskValue=-9999;
    % 构造插值运算需要输入的经纬度矩阵参数
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Wind';
    variable3D={'Q2','RAINC','RAINNC'};% 三维填色图
    variable4D={'QVAPOR','QCLOUD'};% 四维填色图
    variable3DRain={'RAINC','RAINNC'};
    variable4DQVaporCloud={'QVAPOR','QCLOUD'};
    variableContourT2PSFCTT={'T2','PSFC','TT'};% 温度气压等值线
    variableUV3D={'U10','V10'};% 三维风向标
    variableUV4D={'UU','VV'};% 四维风向标
    set(gcf,'visible','off');
    OutputDirectory = [OutputDirectory,DataType,'\'];
    if(exist(OutputDirectory,'dir')~=7)
        mkdir(OutputDirectory);% 在当前文件夹下新建img文件夹，如果已存在会warning，不影响运行
    end
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%创建xml，记录填色图的最大最小值
    docRootNode = docNode.getDocumentElement;%获取xml跟节点
    docRootNode.setAttribute('date',sprintf(Date));%设置时间属性
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for variable=variable3D
        vid=netcdf.inqVarID(ncid,variable{1});
        i=0;j=0;
        %三维，经度纬度时间
        while j<Dimensions(4)
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(i) , '-',Date];%文件名
            %fullPath = [OutputDirectory,Date,'\',name, '.png'];%出图的图层路径（包括文件名）
            ec=netcdf.getVar(ncid,vid,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取变量
            eci=double(flipud(ec(:,:,1)'));
            eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            %温度小于15°设为nan
            if(strcmp(variable{1},'T2'))
                eci(eci<288.15)=nan;
                %两米比湿去掉小于0.015
            elseif(strcmp(variable{1},'Q2'))
                eci(eci<0.015)=nan;
                %降水范围设为0-128
            elseif(strcmp(variable{1},'RAINC')||strcmp(variable{1},'RAINNC'))
                eci(eci<0)=nan;
                eci(eci>128)=nan;
                %气压1000百帕以下设为nan
            elseif(strcmp(variable{1},'PSFC'))
                eci(eci<100000)=nan;
            end
            eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
            maxValue=max(max(eci));%最大值
            minValue=min(min(eci));%最小值
            
            %对温度特殊处理，绝对温度转换为摄氏度
            if(strcmp(variable{1},'T2'))
                maxValue=maxValue-273.15;
                minValue=minValue-273.15;
                %海流数据除以100
            elseif(strcmp(variable{1},'tz_h'))
                maxValue=maxValue/100;
                minValue=minValue/100;
                %对气压特殊处理单位设为百帕
            elseif(strcmp(variable{1},'PSFC'))
                maxValue=maxValue/100;
                minValue=minValue/100;
            end
            
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            j=j+Time_interval;
        end
    end
    
    %% variable4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for variable=variable4D
        vid=netcdf.inqVarID(ncid,variable{1});
        levelval = netcdf.getAtt(ncid,vid, 'level_hpa');
        m = 1;
        for n=1:length(levelval)
            if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
                levelist(m) = n-1;
                m = m + 1;
            end
        end
        i=0;j=0;p=0;
        for i = levelist
            %循环时间
            while j<Dimensions(4)
                name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(p) , '-',Date];%文件名
                ec=netcdf.getVar(ncid,vid,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取变量
                eci=double(flipud(ec(:,:,1,1)'));
                eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                %温度小于15°设为nan
                if(strcmp(variable{1},'TT')&&p==0)
                    eci(eci<288.15)=nan;
                    %QVAPOR混合比去掉负数
                elseif(strcmp(variable{1},'QVAPOR'))
                    eci(eci<0)=nan;
                    %QCLOUD混合比去掉负数和0
                elseif(strcmp(variable{1},'QCLOUD'))
                    eci(eci<=0)=nan;
                    eci(eci>0.0001)=nan;
                end
                eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
                maxValue=max(max(eci));%最大值
                minValue=min(min(eci));%最小值
                
                %对温度特殊处理，绝对温度转换为摄氏度
                if(strcmp(variable{1},'TT'))
                    maxValue=maxValue-273.15;
                    minValue=minValue-273.15;
                    %QVAPOR混合比*1000
                elseif(strcmp(variable{1},'QVAPOR'))
                    maxValue=maxValue*1000;
                    minValue=minValue*1000;
                    %QCLOUD混合比*100000
                elseif(strcmp(variable{1},'QCLOUD'))
                    maxValue=maxValue*10000;
                    minValue=minValue*10000;
                end
                
                %添加xml文件节点
                newSlide=docNode.createElement(name);%新建newSlide节点
                newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
                newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
                docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
                j=j+Time_interval;
            end
            j=0;
            p = p + 1;
        end
    end
    
    %% UV3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variableUV3D;
    vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
    levels=1;
    times=0;
    if(levels==1&&times~=1)   %三维，经度纬度时间
        levelist = 0;
    else
        levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
        m = 1;
        for n=1:length(levelval)
            if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
                levelist(m) = n-1;
                m = m + 1;
            end
        end
    end
    i=0;j=0;p=0;
    for i = levelist
        while j<Dimensions(4)
            name = [DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date];%出图的图层路径（包括文件名）
            
            if(levels==1&&times~=1)   %三维，经度纬度时间
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取V变量
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecV(ecV(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=flipud(sqrt(ecU.^2+ecV.^2));
            maxValue=max(max(eci));%最大值
            minValue=min(min(eci));%最小值
            
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% UV4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variableUV4D;
    vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
    levels=0;
    times=0;
    if(levels==1&&times~=1)   %三维，经度纬度时间
        levelist = 0;
    else
        levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
        m = 1;
        for n=1:length(levelval)
            if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
                levelist(m) = n-1;
                m = m + 1;
            end
        end
    end
    i=0;j=0;p=0;
    for i = levelist
        while j<Dimensions(4)
            name = [DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date];%出图的图层路径（包括文件名）
            
            if(levels==1&&times~=1)   %三维，经度纬度时间
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取V变量
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecV(ecV(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=flipud(sqrt(ecU.^2+ecV.^2));
            maxValue=max(max(eci));%最大值
            minValue=min(min(eci));%最小值
            
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variable3DRain
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variable3DRain;
    vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
    levels=1;
    times=0;
    if(levels==1&&times~=1)   %三维，经度纬度时间
        levelist = 0;
    else
        levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
        m = 1;
        for n=1:length(levelval)
            if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
                levelist(m) = n-1;
                m = m + 1;
            end
        end
    end
    i=0;j=0;p=0;
    for i = levelist
        while j<Dimensions(4)
            name = [DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(p) ,'-',Date];%出图的图层路径（包括文件名）
            
            if(levels==1&&times~=1)   %三维，经度纬度时间
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取V变量
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecV(ecV(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecU(ecU<0)=0;
            ecV(ecV<0)=0;
            
            % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=ecU+ecV;
            maxValue=max(max(eci));%最大值
            minValue=min(min(eci));%最小值
            
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variable4DQVaporCloud
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variable4DQVaporCloud;
    vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
    levels=0;
    times=0;
    if(levels==1&&times~=1)   %三维，经度纬度时间
        levelist = 0;
    else
        levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
        m = 1;
        for n=1:length(levelval)
            if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
                levelist(m) = n-1;
                m = m + 1;
            end
        end
    end
    i=0;j=0;p=0;
    for i = levelist
        while j<Dimensions(4)
            name = [DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(p) ,'-',Date];%出图的图层路径（包括文件名）
            
            if(levels==1&&times~=1)   %三维，经度纬度时间
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%三维，经度纬度层数
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取V变量
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取U变量
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取V变量
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            ecU(ecU(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecV(ecV(:,:)==MaskValue)=nan;% 将MaskValue设为nan
            ecU(ecU<0)=0;
            ecV(ecV<0)=0;
            
            % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=ecU+ecV;
            maxValue=max(max(eci));%最大值
            minValue=min(min(eci));%最小值
            %QVaporCloud混合比*1000
            if(strcmp(variable{1},'QVAPOR'))
                maxValue=maxValue*1000;
                minValue=minValue*1000;
            end
            %添加xml文件节点
            newSlide=docNode.createElement(name);%新建newSlide节点
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
            newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
            docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variableContourT2PSFCTT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for variable=variableContourT2PSFCTT
        hold off;
        vid=netcdf.inqVarID(ncid,variable{1}); % 获取变量名的ID
        %ec=netcdf.getVar(ncid,vid,start,count); % 读取变量
        if(strcmp(variable{1},'TT'))
            levels=0;       
        else
            levels=1;
        end
        times=121;
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
        
        i=0;j=0;p=0;
        %循环层数
        for i=levelist
            %循环时间
            while j<times
                %出图的图层路径（包括文件名）
                name = [DataType,'-', variable{1},'Contour','-',num2str(j) ,'-',num2str(p) ,'-',Date];%出图的图层路径（包括文件名）
                if(levels==1&&times~=1)%三维，经度纬度时间
                    ec=netcdf.getVar(ncid,vid,[0,0,j],[Dimensions(1),Dimensions(2),1]); % 读取变量
                    eci=flipud(ec(:,:,1)');
                elseif(levels~=1&&times==1)%三维，经度纬度层数
                    ec=netcdf.getVar(ncid,vid,[0,0,i],[Dimensions(1),Dimensions(2),1]); % 读取变量
                    eci=flipud(ec(:,:,1)');
                else
                    ec=netcdf.getVar(ncid,vid,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % 读取变量
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
                    [minValue maxValue] = getMinMax(ecc,2);%两倍的标准差
                    maxValue=realMax;%middle最大值设为实际最大值，所以只有低值和中值的色带
                elseif(strcmp(variable{1},'TT'))
                    eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                    eci=eci-273.15;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    %  eccc=eci;
                    %  eccc(~isnan(LandMatrix))=nan;
                    % eccc=interp2(L_range,B_range,eccc,L_matrix,B_matrix,'linear');
                    % [realMin realMax] = getRealMinMax(eccc);
                    [minValue maxValue] = getMinMax(ecc,1);
                elseif(strcmp(variable{1},'T2'))
                    eci(eci(:,:)==MaskValue)=nan;% 将MaskValue设为nan
                    eci=eci-273.15;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    [minValue maxValue] = getMinMax(ecc,1);
                end
                %添加xml文件节点
                newSlide=docNode.createElement(name);%新建newSlide节点
                newSlide.setAttribute('Max',sprintf('%f',maxValue));%设置Max属性
                newSlide.setAttribute('Min',sprintf('%f',minValue));%设置Min属性
                docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
                j=j+Time_interval;
            end
            j=0;
            p = p + 1;
        end
    end
    clear ec;
    
    output_args = 1;
    hour = Date(end-1:end);
    xmlwrite([OutputDirectory,'wind',hour,'.xml'],docNode);%保存xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% 关闭文件
netcdf.close(ncid);
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
