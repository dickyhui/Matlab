function [ output_args ] = NetCDFtoImageWindXML( importFile,outputDir,timeInterval,levelInterval)
global Dimensions L_range B_range L_matrix B_matrix Date OutputDirectory DataType MaskValue Time_interval Level_interval
%  ��ȡ�糡NetCDF��ʽ��ֵԤ����Ʒ����ͼƬ
%  importFile�������ļ�
%  output_args����1Ϊ�������У�����Ϊ����
%  Dimensions�����ݲ����ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
%  L_range��WGS84���ȷ�Χ
%  B_range;WGS84γ�ȷ�Χ
%  L_matrix:��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrix:��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  VectorPicSize�����ͼƬ��С����С��Ӧ��levels����С�����ͼƬ
%  DataType:�������ͣ�Wind/Wave/..��
%  MaskValue:ȱʡֵ
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:
%  DATE:
try
    %% image init
%         importFile = 'E:\win7workspace\NIO\MATLAB_NIO\����\indian_wrf_2013052312.nc';
%         OutputDirectory = 'E:\win7workspace\NIO\MATLAB_NIO\����\';
%         Time_interval = 60;
%         Level_interval = 1;
    
    %����ͼ���ʱ���� ������� ����ļ���
    Time_interval = str2num(timeInterval);
    Level_interval = str2num(levelInterval);
    if(outputDir(end)~='\')
        outputDir(end+1)='\';
    end
    OutputDirectory = outputDir;
    
    land=load('land.mat');
    LandMatrix = land.eccc;
    ncid = netcdf.open( importFile, 'NC_NOWRITE' );% ���ļ�
    
    % �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
    Dimensions = [476,251,6,121];
    % wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
    L_range = linspace(30,125,Dimensions(1));
    B_range = linspace(30,-20,Dimensions(2));
    % ��ȡ�ļ����е�����
    [~, name, ~] = fileparts(importFile);
    Date=name(end-9:end);
    MaskValue=-9999;
    % �����ֵ������Ҫ����ľ�γ�Ⱦ������
    [L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
    DataType = 'Wind';
    variable3D={'Q2','RAINC','RAINNC'};% ��ά��ɫͼ
    variable4D={'QVAPOR','QCLOUD'};% ��ά��ɫͼ
    variable3DRain={'RAINC','RAINNC'};
    variable4DQVaporCloud={'QVAPOR','QCLOUD'};
    variableContourT2PSFCTT={'T2','PSFC','TT'};% �¶���ѹ��ֵ��
    variableUV3D={'U10','V10'};% ��ά�����
    variableUV4D={'UU','VV'};% ��ά�����
    set(gcf,'visible','off');
    OutputDirectory = [OutputDirectory,DataType,'\'];
    if(exist(OutputDirectory,'dir')~=7)
        mkdir(OutputDirectory);% �ڵ�ǰ�ļ������½�img�ļ��У�����Ѵ��ڻ�warning����Ӱ������
    end
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',sprintf(Date));%����ʱ������
    %% variable3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for variable=variable3D
        vid=netcdf.inqVarID(ncid,variable{1});
        i=0;j=0;
        %��ά������γ��ʱ��
        while j<Dimensions(4)
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(i) , '-',Date];%�ļ���
            %fullPath = [OutputDirectory,Date,'\',name, '.png'];%��ͼ��ͼ��·���������ļ�����
            ec=netcdf.getVar(ncid,vid,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡ����
            eci=double(flipud(ec(:,:,1)'));
            eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            %�¶�С��15����Ϊnan
            if(strcmp(variable{1},'T2'))
                eci(eci<288.15)=nan;
                %���ױ�ʪȥ��С��0.015
            elseif(strcmp(variable{1},'Q2'))
                eci(eci<0.015)=nan;
                %��ˮ��Χ��Ϊ0-128
            elseif(strcmp(variable{1},'RAINC')||strcmp(variable{1},'RAINNC'))
                eci(eci<0)=nan;
                eci(eci>128)=nan;
                %��ѹ1000����������Ϊnan
            elseif(strcmp(variable{1},'PSFC'))
                eci(eci<100000)=nan;
            end
            eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
            maxValue=max(max(eci));%���ֵ
            minValue=min(min(eci));%��Сֵ
            
            %���¶����⴦�������¶�ת��Ϊ���϶�
            if(strcmp(variable{1},'T2'))
                maxValue=maxValue-273.15;
                minValue=minValue-273.15;
                %�������ݳ���100
            elseif(strcmp(variable{1},'tz_h'))
                maxValue=maxValue/100;
                minValue=minValue/100;
                %����ѹ���⴦��λ��Ϊ����
            elseif(strcmp(variable{1},'PSFC'))
                maxValue=maxValue/100;
                minValue=minValue/100;
            end
            
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
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
            %ѭ��ʱ��
            while j<Dimensions(4)
                name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(p) , '-',Date];%�ļ���
                ec=netcdf.getVar(ncid,vid,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡ����
                eci=double(flipud(ec(:,:,1,1)'));
                eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
                %�¶�С��15����Ϊnan
                if(strcmp(variable{1},'TT')&&p==0)
                    eci(eci<288.15)=nan;
                    %QVAPOR��ϱ�ȥ������
                elseif(strcmp(variable{1},'QVAPOR'))
                    eci(eci<0)=nan;
                    %QCLOUD��ϱ�ȥ��������0
                elseif(strcmp(variable{1},'QCLOUD'))
                    eci(eci<=0)=nan;
                    eci(eci>0.0001)=nan;
                end
                eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
                maxValue=max(max(eci));%���ֵ
                minValue=min(min(eci));%��Сֵ
                
                %���¶����⴦�������¶�ת��Ϊ���϶�
                if(strcmp(variable{1},'TT'))
                    maxValue=maxValue-273.15;
                    minValue=minValue-273.15;
                    %QVAPOR��ϱ�*1000
                elseif(strcmp(variable{1},'QVAPOR'))
                    maxValue=maxValue*1000;
                    minValue=minValue*1000;
                    %QCLOUD��ϱ�*100000
                elseif(strcmp(variable{1},'QCLOUD'))
                    maxValue=maxValue*10000;
                    minValue=minValue*10000;
                end
                
                %���xml�ļ��ڵ�
                newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
                newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
                newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
                docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
                j=j+Time_interval;
            end
            j=0;
            p = p + 1;
        end
    end
    
    %% UV3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variableUV3D;
    vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
    levels=1;
    times=0;
    if(levels==1&&times~=1)   %��ά������γ��ʱ��
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
            name = [DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date];%��ͼ��ͼ��·���������ļ�����
            
            if(levels==1&&times~=1)   %��ά������γ��ʱ��
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecV(ecV(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=flipud(sqrt(ecU.^2+ecV.^2));
            maxValue=max(max(eci));%���ֵ
            minValue=min(min(eci));%��Сֵ
            
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% UV4D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variableUV4D;
    vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
    levels=0;
    times=0;
    if(levels==1&&times~=1)   %��ά������γ��ʱ��
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
            name = [DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date];%��ͼ��ͼ��·���������ļ�����
            
            if(levels==1&&times~=1)   %��ά������γ��ʱ��
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecV(ecV(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=flipud(sqrt(ecU.^2+ecV.^2));
            maxValue=max(max(eci));%���ֵ
            minValue=min(min(eci));%��Сֵ
            
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variable3DRain
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variable3DRain;
    vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
    levels=1;
    times=0;
    if(levels==1&&times~=1)   %��ά������γ��ʱ��
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
            name = [DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(p) ,'-',Date];%��ͼ��ͼ��·���������ļ�����
            
            if(levels==1&&times~=1)   %��ά������γ��ʱ��
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            
            ecU(ecU(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecV(ecV(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecU(ecU<0)=0;
            ecV(ecV<0)=0;
            
            % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=ecU+ecV;
            maxValue=max(max(eci));%���ֵ
            minValue=min(min(eci));%��Сֵ
            
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variable4DQVaporCloud
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable=variable4DQVaporCloud;
    vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
    levels=0;
    times=0;
    if(levels==1&&times~=1)   %��ά������γ��ʱ��
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
            name = [DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(p) ,'-',Date];%��ͼ��ͼ��·���������ļ�����
            
            if(levels==1&&times~=1)   %��ά������γ��ʱ��
                ecU=netcdf.getVar(ncid,vidU,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                ecU=netcdf.getVar(ncid,vidU,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1)');
                ecV=flipud(ecV(:,:,1)');
            else
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡV����
                ecU=flipud(ecU(:,:,1,1)');
                ecV=flipud(ecV(:,:,1,1)');
            end
            ecU(ecU(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecV(ecV(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ecU(ecU<0)=0;
            ecV(ecV<0)=0;
            
            % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
            ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
            ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
            eci=ecU+ecV;
            maxValue=max(max(eci));%���ֵ
            minValue=min(min(eci));%��Сֵ
            %QVaporCloud��ϱ�*1000
            if(strcmp(variable{1},'QVAPOR'))
                maxValue=maxValue*1000;
                minValue=minValue*1000;
            end
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
            j=j+Time_interval;
        end
        j = 0;
        p = p + 1;
    end
    
    %% variableContourT2PSFCTT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for variable=variableContourT2PSFCTT
        hold off;
        vid=netcdf.inqVarID(ncid,variable{1}); % ��ȡ��������ID
        %ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
        if(strcmp(variable{1},'TT'))
            levels=0;       
        else
            levels=1;
        end
        times=121;
        if(levels==1&&times~=1)   %��ά������γ��ʱ��
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
        %ѭ������
        for i=levelist
            %ѭ��ʱ��
            while j<times
                %��ͼ��ͼ��·���������ļ�����
                name = [DataType,'-', variable{1},'Contour','-',num2str(j) ,'-',num2str(p) ,'-',Date];%��ͼ��ͼ��·���������ļ�����
                if(levels==1&&times~=1)%��ά������γ��ʱ��
                    ec=netcdf.getVar(ncid,vid,[0,0,j],[Dimensions(1),Dimensions(2),1]); % ��ȡ����
                    eci=flipud(ec(:,:,1)');
                elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                    ec=netcdf.getVar(ncid,vid,[0,0,i],[Dimensions(1),Dimensions(2),1]); % ��ȡ����
                    eci=flipud(ec(:,:,1)');
                else
                    ec=netcdf.getVar(ncid,vid,[0,0,i,j],[Dimensions(1),Dimensions(2),1,1]); % ��ȡ����
                    eci=flipud(ec(:,:,1,1)');
                end
                
                %��ѹ
                if(strcmp(variable{1},'PSFC'))
                    eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
                    eci=eci/100;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    eccc=eci;
                    eccc(~isnan(LandMatrix))=nan;
                    eccc=interp2(L_range,B_range,eccc,L_matrix,B_matrix,'linear');
                    [realMin realMax] = getRealMinMax(eccc);
                    [minValue maxValue] = getMinMax(ecc,2);%�����ı�׼��
                    maxValue=realMax;%middle���ֵ��Ϊʵ�����ֵ������ֻ�е�ֵ����ֵ��ɫ��
                elseif(strcmp(variable{1},'TT'))
                    eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
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
                    eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
                    eci=eci-273.15;
                    ecc=eci;
                    ecc(isnan(LandMatrix))=nan;
                    ecc=interp2(L_range,B_range,ecc,L_matrix,B_matrix,'linear');
                    [minValue maxValue] = getMinMax(ecc,1);
                end
                %���xml�ļ��ڵ�
                newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
                newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
                newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
                docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
                j=j+Time_interval;
            end
            j=0;
            p = p + 1;
        end
    end
    clear ec;
    
    output_args = 1;
    hour = Date(end-1:end);
    xmlwrite([OutputDirectory,'wind',hour,'.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
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
