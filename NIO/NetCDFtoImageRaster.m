function [ ] = NetCDFtoImageRaster( ncid,variables,start,count,levels,times,docNode,docRootNode )
global Time_interval Level_interval Date OutputDirectory DataType
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
    %stride=[251,251,121];
    vid=netcdf.inqVarID(ncid,variable{1}); % ��ȡ��������ID
    ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
    i=0;j=0;
    %ѭ������
    while i<levels
        %ѭ��ʱ��
        while j<times
            name=[DataType,'-', variable{1}, '-', num2str(j) , '-', num2str(i) , '-',Date];%�ļ���
            fullPath = [OutputDirectory,Date,'\',name, '.png'];%��ͼ��ͼ��·���������ļ�����
            %����ɫͼ(������ʱ����ת90��)
            if(levels==1&&times~=1)%��ά������γ��ʱ��
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,j+1)'),fullPath);
            elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,i+1)'),fullPath);
            else
                [maxValue,minValue]=DrawRaster(flipud(ec(:,:,i+1,j+1)'),fullPath);
            end
            %��Ч����
            if(strcmp(variable{1},'swh'))
                maxValue=maxValue/100;
                minValue=minValue/100;
            %�׷�����
            elseif(strcmp(variable{1},'tps'))
                maxValue=maxValue/10;
                minValue=minValue/10;
            end
            %���xml�ļ��ڵ�
            newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
            newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
            newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
            docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
            
            j=j+Time_interval;
        end
        j=0;
        i=i+Level_interval;
    end
    clear ec;
end
end