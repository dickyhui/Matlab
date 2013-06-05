function [  ] = NetCDFtoImageContourWind( ncid,variables,dimLon,dimLat,levels,times,piclevels,vector)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType LandMatrix Time_Start L_range B_range L_matrix B_matrix MaskValue
%  ����NetCDF�ĵ�ֵ��ͼ
%  ncid��NetCDF��ID
%  variables:��ֵ�ߵ����ݲ���
%  start:nc�ļ����ݵ����λ��
%  count:������ ��άΪ���Ⱥ�γ�ȣ���ά�Ӳ�����ʱ��
%  levels:�ò������ݵĲ���
%  times:�ò������ݵ�ʱ����
%  piclevels������ͼƬ�ļ���3,4,5,6��
%  vector:ָ����ֵ�ߵĻ��Ƹ߶�
%  Time_interval������ʱ����
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  VectorPicSize�����ͼƬ��С����С��Ӧ��levels����С�����ͼƬ
%  DataType:�������ͣ�Wind/Wave/..��
%  MFILE:   NetCDFtoImageContour.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

for variable=variables
    hold off;
    vid=netcdf.inqVarID(ncid,variable{1}); % ��ȡ��������ID
    %ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
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
    
    l=1;
    %ѭ������
    for level=piclevels
        %���ݲ�ͬ�ļ���(level)���ó�ͼ�Ĵ�С����ָ������
        set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;j=Time_Start;p=0;
        %ѭ������
        for i=levelist
            %ѭ��ʱ��
            while j<times
                %��ͼ��ͼ��·���������ļ�����
                fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'Contour','-',num2str(j) ,'-',num2str(p) ,'-',Date , '-L',num2str(level), '.png'];
                
                if(levels==1&&times~=1)%��ά������γ��ʱ��
                    ec=netcdf.getVar(ncid,vid,[0,0,j],[dimLon,dimLat,1]); % ��ȡ����
                    eci=flipud(ec(:,:,1)');
                elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                    ec=netcdf.getVar(ncid,vid,[0,0,i],[dimLon,dimLat,1]); % ��ȡ����
                    eci=flipud(ec(:,:,1)');
                else
                    ec=netcdf.getVar(ncid,vid,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡ����
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
                    [min max] = getMinMax(ecc,2);%�����ı�׼��
                    max=realMax;%middle���ֵ��Ϊʵ�����ֵ������ֻ�е�ֵ����ֵ��ɫ��
                    vectorMiddle=min:2.5:max;
                    min0=max;
                    max0=floor((realMax-min0)/10)*10+min0;
                    vectorMax=min0:100:max0;
                    max0=min;
                    min0=max0-floor((max0-realMin)/10)*10;
                    vectorMin=min0:100:max0;
                    vector=[vectorMin,vectorMiddle];%�ȸ���û�и�ֵ��
                    colormap(setColorMap('bluered',vectorMin,vectorMiddle,vectorMax));
                    DrawContourf( eci,fullPath,vector);
                elseif(strcmp(variable{1},'TT'))
                    eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
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
                    eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
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

