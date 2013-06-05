function [  ] = NetCDFtoImageContour( ncid,variables,start,count,levels,times,piclevels,vector)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType LandMatrix
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
    ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
    l=1;
    %ѭ������
    for level=piclevels
        %���ݲ�ͬ�ļ���(level)���ó�ͼ�Ĵ�С����ָ������
        set(gcf,'paperposition',[0 0 2^(l-1)*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2^(l-1)*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;j=0;
        %ѭ������
        while i<levels
            %ѭ��ʱ��
            while j<times
                %��ͼ��ͼ��·���������ļ�����
                fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'Contour','-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
               
                if(levels==1&&times~=1)%��ά������γ��ʱ��
                    eci=flipud(ec(:,:,j+1)');
                elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
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

