function [ ] = DrawUVContour(ncid,variables,dimLon,dimLat,levels,times)
global Time_interval Date OutputDirectory DataType Time_Start L_range B_range L_matrix B_matrix  MaskValue
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
colormap(jet(256));
variable=variables;
vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
if(levels==1&&times~=1)   %��ά������γ��ʱ��
    levelist(1) = 0;
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
i=0;j=Time_Start;p=0;
for i = levelist
    while j<times
        fullPath = [OutputDirectory,Date,'\',DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date , '.png'];%��ͼ��ͼ��·���������ļ�����
        
        if(levels==1&&times~=1)   %��ά������γ��ʱ��
            ecU=netcdf.getVar(ncid,vidU,[0,0,j],[dimLon,dimLat,1]); % ��ȡU����
            ecV=netcdf.getVar(ncid,vidV,[0,0,j],[dimLon,dimLat,1]); % ��ȡV����
            ecU=flipud(ecU(:,:,1)');
            ecV=flipud(ecV(:,:,1)');
        elseif(levels~=1&&times==1)%��ά������γ�Ȳ���
            ecU=netcdf.getVar(ncid,vidU,[0,0,i],[dimLon,dimLat,1]); % ��ȡU����
            ecV=netcdf.getVar(ncid,vidV,[0,0,i],[dimLon,dimLat,1]); % ��ȡV����
            ecU=flipud(ecU(:,:,1)');
            ecV=flipud(ecV(:,:,1)');
        else
            ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡU����
            ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[dimLon,dimLat,1,1]); % ��ȡV����
            ecU=flipud(ecU(:,:,1,1)');
            ecV=flipud(ecV(:,:,1,1)');
        end
        
        ecU(ecU(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
        ecV(ecV(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
        ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
        
        eci=sqrt(ecU.^2+ecV.^2);
        %����ɫ������(11)
        %         [~,h]=contourf(eci(1:end,1:end),[11 11],'LineColor','blue');
        %         ch=get(h,'children');
        %         for k=ch
        %             set(k,'FaceColor','blue','FaceAlpha',1);
        %         end
        %         %����ɫ�߼���(13)
        %         hold on;
        %         [~,h2]=contourf(eci(1:end,1:end),[13 13],'LineColor','yellow');
        %         ch2=get(h2,'children');
        %         for k2=ch2
        %             set(k2,'FaceColor','yellow','FaceAlpha',1);
        %         end
        minValue=min(min(eci));%��Сֵ
        %eci(isnan(eci))=minValue;% ��nanֵ��Ϊ��Сֵ
        h=imagesc(eci);% ��ͼ
        set(h,'alphadata',~isnan(eci));%��nanֵ��Ϊ��ɫ��Ĭ��Ϊ��ɫ��
        SaveImageWind(fullPath);%����ͼƬ
        
        j=j+Time_interval;
    end
    j = Time_Start;
    p = p + 1;
end
clear ecU ecV eci;
end

