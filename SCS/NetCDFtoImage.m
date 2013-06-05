function [ output_args ] = NetCDFtoImage( importFile,outputDir,timeInterval )
%  ��ȡNetCDF��ʽ��ֵԤ����Ʒ����������ת�����ڲ壬�������ͼƬ
%  importFileΪ�����ļ�
%  outputDirΪ����ļ���
%  output_args����1Ϊ�������У�0Ϊ����
%  ��ͼ���ݸ�ʽ��
%  ��ά��ֵ�ߣ�Wind_��Ʒ_ʱ��_ʱ��_����
%  Wind_PSFC_0_2012112108_L3
%  ��ά����꣺Wind_��Ʒ_ʱ��_ʱ��_����
%  Wind_W10_0_2012112108_L3
%  ��ά������߼���ֵ����ɫͼ��Wind_��ƷContour_ʱ��_ʱ��
%  Wind_W10Contour_0_2012112108
%  MFILE:   NetCDFtoImage.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
% importFile = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\nmefc_wrf_2013012108.nc';
% outputDir = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\';
% timeInterval = 12;

global Dimensions L_range B_range L_matrix B_matrix Time_interval yesterday VectorPicSize outputDirectory
% �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
Dimensions = [251,251,6,121];
%ʸ��ͼ�γ�ͼ��С�������㣩
VectorPicSize = [285,331];
% ����ͼ���ʱ�����Ͳ������
Time_interval = timeInterval;
% ��ȡ�ļ����е����ڣ����죬��������ļ���
[~, name, ~] = fileparts(importFile);
yesterday=name(end-9:end);
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
outputDirectory=outputDir;
% wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
L_range = linspace(100,150,Dimensions(1));
B_range = linspace(50,0,Dimensions(2));
% �����ֵ������Ҫ����ľ�γ�Ⱦ������
[L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
%% main do
try
    % �жϴ�����ļ�����
    if(size(strfind(name,'nmefc_wrf'),1) == 1)
        output_args = NCtoImage(importFile);
    end
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
end

%% NCtoImage
% NC�ļ�����ͼƬ
function [ output_args ] = NCtoImage( input_args )
global Dimensions Time_interval yesterday VectorPicSize outputDirectory
try
    %% image init
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    ncid = netcdf.open( input_args, 'NC_NOWRITE' );% ���ļ�
    variableContour3D={'PSFC'};% ��ά��ֵ��
    variableUV3D={'U10','V10'};% ��ά�����
    
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',sprintf(yesterday));%����ʱ������
    %% variableContour3D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variableContour3D
    for variable=variableContour3D
        hold off;
        start=[0,0,0]; % ���λ�� [0,0,0]
        count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % ������ ���ȣ�γ�ȣ�ʱ��
        vid=netcdf.inqVarID(ncid,variable{1}); % ��ȡ��������ID
        ec=netcdf.getVar(ncid,vid,start,count); % ��ȡ����
        %t=clock;% ��ʼ��ʱ
        % ��ʼ����ͼƬ
        set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L3' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L4' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L5' , '.png']);
            i=i+Time_interval;
        end
        set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
        i=0;
        while i<count(3)
            DrawContour3D( ec(:,:,i+1)/(100),[outputDirectory,yesterday,'\Wind_', variable{1},'_',num2str(i),'_',yesterday , '_L6' , '.png']);
            i=i+Time_interval;
        end
        clear ec;
        %disp(fix(etime(clock,t)));% ��ʾ���ѵ�ʱ��
    end
    %% variableUV3D ������6����ֵ��
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %variableUV3D ������ά�����
    variable=variableUV3D;
    start=[0,0,0]; % ���λ�� [0,0,0]
    count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % ������ ���ȣ�γ�ȣ�ʱ��
    vidU=netcdf.inqVarID(ncid,variable{1}); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,variable{2}); % ��ȡV��������ID
    ecU=netcdf.getVar(ncid,vidU,start,count); % ��ȡU����
    ecV=netcdf.getVar(ncid,vidV,start,count); % ��ȡV����
    %t=clock;% ��ʼ��ʱ
    %����6����ֵ����ɫͼ(4��Ϊ��ʹ�Ŵ��Ч����һ��)
    set(gcf,'paperposition',[0 0 4*Dimensions(1)/get(0,'ScreenPixelsPerInch') 4*Dimensions(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUVContour3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10Contour','_',num2str(i) ,'_',yesterday , '.png']);
        i=i+Time_interval;
    end
    % ����VectorPicSize������map3�㣩
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L3', '.png'],32);
        i=i+Time_interval;
    end
    % ����ͼƬ2*VectorPicSize������map4�㣩
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L4', '.png'],16);
        i=i+Time_interval;
    end
    % ����ͼƬ2*VectorPicSize������map5�㣩
    set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L5', '.png'],8);
        i=i+Time_interval;
    end
    % ����ͼƬ ���ɴ��ŵ�ͼƬ8*VectorPicSize������map6-8�㣩
    set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    i=0;
    while i<count(3)
        DrawUV3D4D(ecU(:,:,i+1),ecV(:,:,i+1),[outputDirectory,yesterday,'\Wind_', 'W10','_',num2str(i) ,'_',yesterday , '_L6', '.png'],4);
        i=i+Time_interval;
    end
    clear ecU ecV;
    
    output_args = 1;
    hour = yesterday(end-1:end);
    xmlwrite([outputDirectory,'wind',hour,'.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
% �ر��ļ�
netcdf.close(ncid);
end

%% DrawContour3D
%����ά��ֵ�ߣ�iΪ�ڼ���,variableΪ������
function [] = DrawContour3D( eci,name )
global B_range L_range B_matrix L_matrix
hold off;
eci=flipud(eci');% ������ʱ����ת90��
eci(eci(:,:)==-9999)=nan;% ��-9999��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'cubic');
[C,h] = contour(flipud(eci),'b');% ��ͼ
clabel(C,h);
%set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);
SaveImage(name);%����ͼƬ
clear eci;
end

%% DrawUV3D4D
%�������ͼ��iΪ�ڼ��㣬intervalΪ�����ļ��(���Ӽ��Ϊ251*251)
function [] = DrawUV3D4D( ec0U,ec0V,name,interval )
global B_range L_range B_matrix L_matrix
hold off;
ec0U=flipud(ec0U');% ������ʱ����ת90��
ec0V=flipud(ec0V');% ������ʱ����ת90��
ec0U(ec0U(:,:)==-9999)=nan;% ��-9999��Ϊnan
ec0V(ec0V(:,:)==-9999)=nan;% ��-9999��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'cubic');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'cubic');
[x,y]=meshgrid(1:size(L_range,2),1:size(B_range,2));%��γ�ȵķ�Χ����Ҫ�����ɵȾ������
%quiver(flipud(ec0U(1:4:end,1:4:end)),flipud(ec0V(1:4:end,1:4:end))); %���ɼ�ͷ
ec0U=flipud(ec0U);
ec0V=flipud(ec0V);
windbarbm(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U(1:interval:end,1:interval:end),ec0V(1:interval:end,1:interval:end))%���ɷ����
set(gca,'XLim',[1 size(L_range,2)],'YLim',[1 size(B_range,2)]);%�������귶Χwindbarbm������ı����귶Χ
SaveImage(name);%����ͼƬ
clear ec0U ec0V;
end
%% DrawUVContour3D4D
%�������ͼ��iΪ�ڼ��㣬intervalΪ�����ļ��(���Ӽ��Ϊ251*251)
function [] = DrawUVContour3D4D( ec0U,ec0V,name )
global B_range L_range B_matrix L_matrix
hold off;
ec0U=flipud(ec0U');% ������ʱ����ת90��
ec0V=flipud(ec0V');% ������ʱ����ת90��
ec0U(ec0U(:,:)==-9999)=nan;% ��-9999��Ϊnan
ec0V(ec0V(:,:)==-9999)=nan;% ��-9999��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'cubic');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'cubic');
eci=flipud(sqrt(ec0U.^2+ec0V.^2));
%����ɫ������(11)
[~,h]=contourf(eci(1:end,1:end),[11 11],'LineColor','blue');
ch=get(h,'children');
for k=ch
    set(k,'FaceColor','blue','FaceAlpha',1);
end
%����ɫ�߼���(13)
hold on;
[~,h2]=contourf(eci(1:end,1:end),[13 13],'LineColor','yellow');
ch2=get(h2,'children');
for k2=ch2
    set(k2,'FaceColor','yellow','FaceAlpha',1);
end
SaveImage(name);%����ͼƬ
clear ec0U ec0V eci;
end
%% SaveImage
%����ͼƬ,input_argsΪͼ����
function [  ] = SaveImage( input_args )
global outputDirectory yesterday
axis off;% �ر�������
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[outputDirectory,yesterday,'\default.png']);% ���ͼƬ
%saveas(gcf,'img\default.png','png');
img = imread([outputDirectory,yesterday,'\default.png']);% ��ȡͼƬ
siz=size(img);
alpha=ones(siz(1),siz(2));
alpha((img(:,:,1)==255)&(img(:,:,2)==255)&(img(:,:,3)==255))=0;% ��ɫ��Ϊ͸��
imwrite(img,input_args,'alpha',alpha);% �����͸��������ͼƬ
end

%% SetImageLayout
%����ȫ�ֵ�ͼƬ����ĸ�ʽ
function [  ] = SetImageLayout(  )
global Dimensions outputDirectory yesterday
%set(gcf,'visible','off');%����ʾfigure
% ͼ��ȥ�������׿� axes��figure�е���߽磬�±߽磬��ȣ��߶�
set(gca,'position',[0 0 1 1] );
% ����ɫ�������ᱳ������Ϊ͸��
%set(gcf,'color','nan');
%set(gca,'color','nan');
%set(gcf,'InvertHardCopy','off');
% ����gcf���ڵĴ�СΪDimensions��print��saveas���ͼƬ�Ĵ�СҪ����dpi����print��dpi��Ϊ��Ļdpi��
%   paperposition�ĳ��Ϳ���ΪDimensions����Ļdpi��������ӡ�����Ĵ�СΪDimensions��С
%   Position�Ĵ�С�Ǵ��ڵĴ�С��paperposition��С�����ͼ��Ĵ�С
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%����ɫ�����췽ʽ
colormap(jet(256));
if(exist([outputDirectory,yesterday],'dir')~=7)
    mkdir([outputDirectory,yesterday]);% �ڵ�ǰ�ļ������½�img�ļ��У�����Ѵ��ڻ�warning����Ӱ������
end
end