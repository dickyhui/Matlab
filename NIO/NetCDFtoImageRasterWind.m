function [ ] = NetCDFtoImageRasterWind( ncid,variables,dimLon,dimLat,levels,times )
global Time_interval Date OutputDirectory DataType Time_Start LandMatrix
%  ����NetCDF����ɫͼ
%  ncid��NetCDF��ID
%  variables:��ɫͼ�����ݲ���
%  start:nc�ļ����ݵ����λ��
%  count:������ ��άΪ���Ⱥ�γ�ȣ���ά�Ӳ�����ʱ��
%  levels:�ò������ݵĲ���
%  times:�ò������ݵ�ʱ����
%  docNode��xml�ļ���������ɫͼ�������Сֵ����������
%  docRootNode��xml�ļ��ĸ��ڵ�
%  Time_interval������ʱ����
%  Level_interval�����ݲ������
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  DataType:�������ͣ�Wind/Wave/..��
%  MFILE:   NetCDFtoImageRaster.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

for variable=variables
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
    i=0;j=Time_Start;p=0;
    
    for i = levelist        
        while j<times 
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(p) , '-',Date];%�ļ���
            fullPath = [OutputDirectory,Date,'\',name, '.png'];%��ͼ��ͼ��·���������ļ�����
            
            if(levels==1&&times~=1)   %��ά������γ��ʱ��
                ec=netcdf.getVar(ncid,vid,[0,0,j],[dimLon,dimLat,1]); % ��ȡ����
                eci = flipud(ec(:,:,1)');
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                ec=netcdf.getVar(ncid,vid,[0,0,i],[dimLon,dimLat,1]); % ��ȡ����
                eci = flipud(ec(:,:,1)');
            else
                ec=netcdf.getVar(ncid,vid,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡ����
                eci = flipud(ec(:,:,1,1)');
            end
            
            colormap(jet(256));
            %�¶�С��15����Ϊnan
            if((strcmp(variable{1},'TT')&&p==0)||strcmp(variable{1},'T2'))
                %eci(eci<288.15)=nan; 
                %eci(isnan(LandMatrix))=nan;
            %���ױ�ʪȥ��С��0.015
            elseif(strcmp(variable{1},'Q2'))
                colormap(setColorMap('blue'));
                 %eci(eci<0.015)=nan; 
            %��ˮ��Χ��Ϊ0-128
            elseif(strcmp(variable{1},'RAINC')||strcmp(variable{1},'RAINNC'))
                 colormap(setColorMap('blue'));
                 eci(eci<0)=0; 
                 %eci(eci>128)=nan; 
            %QVAPOR��ϱ�ȥ������
            elseif(strcmp(variable{1},'QVAPOR'))
                colormap(setColorMap('blue'));
                 eci(eci<0)=0; 
            %QCLOUD��ϱ�ȥ��������0
            elseif(strcmp(variable{1},'QCLOUD'))
                colormap(setColorMap('blue'));
                 eci(eci<=0)=0; 
                 %eci(eci>0.0001)=nan;
            %��ѹ1000����������Ϊnan
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