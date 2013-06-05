function [ ] = NetCDFtoImageWindBar(ncid,variables,dimLon,dimLat,levels,times,piclevels,picinterval)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType Time_Start
%  ����NetCDF�ķ����
%  ncid��NetCDF��ID
%  variables:���������ݲ���
%  start:nc�ļ����ݵ����λ��
%  count:������ ��άΪ���Ⱥ�γ�ȣ���ά�Ӳ�����ʱ��
%  levels:�ò������ݵĲ���
%  times:�ò������ݵ�ʱ����
%  piclevels������ͼƬ�ļ���3,4,5,6��
%  picinterval������ͼƬ�Ĳ�ͬ�����������ݼ����32,16,8,4��
%  Time_interval������ʱ����
%  Level_interval�����ݲ������
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  VectorPicSize�����ͼƬ��С����С��Ӧ��piclevels����С�����ͼƬ
%  DataType:�������ͣ�Wind/Wave/..��
%  MFILE:   NetCDFtoImageWindBar.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-27)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

variable=variables;
vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
%ecU=netcdf.getVar(ncid,vidU,start,count); % ��ȡU����
%ecV=netcdf.getVar(ncid,vidV,start,count); % ��ȡV����
try    
levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
    m = 1;
    for n=1:length(levelval)       
        if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
            levelist(m) = n-1;
            m = m + 1;
        end
    end
catch me
end
l=1;
%ѭ������
for level=piclevels
    %���ݲ�ͬ�ļ���(level)���ó�ͼ�Ĵ�С����ָ������
    set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;j=Time_Start;p=0;
    
    if(levels==1&&times~=1)   %��ά������γ��ʱ��
        while j<times
            %��ͼ��ͼ��·���������ļ�����
            fullPath = [OutputDirectory,Date,'\',DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
            ecU=netcdf.getVar(ncid,vidU,[0,0,j],[dimLon,dimLat,1]); % ��ȡU����
            ecV=netcdf.getVar(ncid,vidV,[0,0,j],[dimLon,dimLat,1]); % ��ȡV����
            DrawWindBar(flipud(ecU(:,:,1)'),flipud(ecV(:,:,1)'),fullPath,picinterval(l));
            j=j+Time_interval;
        end
    elseif(levels~=1&&times==1) %��ά������γ�Ȳ���
        while i<levels
            fullPath = [OutputDirectory,Date,'\',DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
            ecU=netcdf.getVar(ncid,vidU,[0,0,i],[dimLon,dimLat,1]); % ��ȡU����
            ecV=netcdf.getVar(ncid,vidV,[0,0,i],[dimLon,dimLat,1]); % ��ȡV����
            DrawWindBar(flipud(ecU(:,:,1)'),flipud(ecV(:,:,1)'),fullPath,picinterval(l));
            i=i+Level_interval;
        end
    else   
        %ѭ������
        for i=levelist
            %ѭ��ʱ��
            while j<times
                %��ͼ��ͼ��·���������ļ�����
                fullPath = [OutputDirectory,Date,'\',DataType,'-', variable{1},variable{2},'-',num2str(j) ,'-',num2str(p) ,'-',Date , '-L',num2str(level), '.png'];            
                %�������(������ʱ����ת90��)
                ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡU����
                ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡV����
                DrawWindBar(flipud(ecU(:,:,1,1)'),flipud(ecV(:,:,1,1)'),fullPath,picinterval(l));           
                j=j+Time_interval;
            end
            j=Time_Start;
            p = p + 1;
        end
    end
    l=l+1;
end

clear ecU ecV;
end

