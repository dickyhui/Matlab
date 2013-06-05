function [ ] = NetCDFtoImageDir(ncid,variables,start,count,levels,times,piclevels,picinterval)
global Time_interval Level_interval Date OutputDirectory VectorPicSize DataType
%  NetCDF���ɼ�ͷ
%  ncid��NetCDF��ID
%  variables:��ͷ�����ݲ���(����ֻ����һ����������)
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
%  VectorPicSize�����ͼƬ��С����С��Ӧ��levels����С�����ͼƬ
%  DataType:�������ͣ�Wind/Wave/..��
%  MFILE:   NetCDFtoImageDir.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-20)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:

switch length(variables)
    case 1  %ֻ��һ�����������޴�С�ļ�ͷ
        vid=netcdf.inqVarID(ncid,variables{1}); % ��ȡ��������ID
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
                    fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
                    %����ͷ(������ʱ����ת90��)
                    if(levels==1&&times~=1)%��ά������γ��ʱ��
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,j+1)'));
                    elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,i+1)'));
                    else
                        DrawDir( fullPath,picinterval(l),flipud(ec(:,:,i+1,j+1)'));
                    end
                    j=j+Time_interval;
                end
                j=0;
                i=i+Level_interval;
            end
            l=l+1;
        end
    case 2  %������������������С�ļ�ͷ
        vidU=netcdf.inqVarID(ncid,variables{1}); % ��ȡU��������ID
        vidV=netcdf.inqVarID(ncid,variables{2}); % ��ȡV��������ID
        ecU=netcdf.getVar(ncid,vidU,start,count); % ��ȡU����
        ecV=netcdf.getVar(ncid,vidV,start,count); % ��ȡV����
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
                    fullPath = [OutputDirectory,Date,'\',DataType,'-', variables{1},variables{2},'-',num2str(j) ,'-',num2str(i) ,'-',Date , '-L',num2str(level), '.png'];
                    %����ͷ(������ʱ����ת90��)
                    if(levels==1&&times~=1)%��ά������γ��ʱ��
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,j+1)'),flipud(ecV(:,:,j+1)'));
                    elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,i+1)'),flipud(ecV(:,:,i+1)'));
                    else
                        DrawDir( fullPath,picinterval(l),flipud(ecU(:,:,i+1,j+1)'),flipud(ecV(:,:,i+1,j+1)'));
                    end
                    j=j+Time_interval;
                end
                j=0;
                i=i+Level_interval;
            end
            l=l+1;
        end
        
        clear ec;
end

