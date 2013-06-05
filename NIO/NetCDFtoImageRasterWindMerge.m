function [  ] = NetCDFtoImageRasterWindMerge( ncid,variable,dimLon,dimLat,levels,times )
global Time_interval Date OutputDirectory DataType Time_Start MaskValue
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

vid1=netcdf.inqVarID(ncid,variable{1}); % ��ȡ��������ID
vid2=netcdf.inqVarID(ncid,variable{2}); % ��ȡ��������ID
%ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
if(levels==1&&times~=1)   %��ά������γ��ʱ��
    levelist = 0;
else
    levelval = netcdf.getAtt(ncid,vid1, 'level_hpa');
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
        name=[DataType,'-', variable{1}, variable{2}, '-', num2str(j) , '-', num2str(p) , '-',Date];%�ļ���
        fullPath = [OutputDirectory,Date,'\',name, '.png'];%��ͼ��ͼ��·���������ļ�����
        if(levels==1&&times~=1)   %��ά������γ��ʱ��
            ec1=netcdf.getVar(ncid,vid1,[0,0,j],[dimLon,dimLat,1]); % ��ȡ����
            ec1(ec1(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec2=netcdf.getVar(ncid,vid2,[0,0,j],[dimLon,dimLat,1]); % ��ȡ����
            ec2(ec2(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1)'+ec2(:,:,1)');
        elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
            ec1=netcdf.getVar(ncid,vid1,[0,0,i],[dimLon,dimLat,1]); % ��ȡ����
            ec1(ec1(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec2=netcdf.getVar(ncid,vid2,[0,0,i],[dimLon,dimLat,1]); % ��ȡ����
            ec2(ec2(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1)'+ec2(:,:,1)');
        else
            ec1=netcdf.getVar(ncid,vid1,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡ����
            ec1(ec1(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec2=netcdf.getVar(ncid,vid2,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡ����
            ec2(ec2(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
            ec1(ec1<0)=0;
            ec2(ec2<0)=0;
            eci = flipud(ec1(:,:,1,1)'+ec2(:,:,1,1)');
        end
        
        colormap(setColorMap('blue'));
        DrawRasterWind(eci,fullPath);
        
        j=j+Time_interval;
    end
    j = Time_Start;
    p = p + 1;
end
clear ec;
end