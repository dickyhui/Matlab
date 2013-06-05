function [ output_args ] = NetCDFtoImageDYD( importFile,outputDir,timeInterval )
%  ��ȡDAT��ʽ��ֵԤ����Ʒ����������ת�����ڲ壬������ɵ��㵺��������ͼƬ
%  importFileΪ�����ļ�
%  outputDirΪ����ļ���
%  output_args����1Ϊ�������У�0Ϊ����
%  ��ͼ���ݸ�ʽ����Ŀǰֻ��W10��Ʒ��
%  Wind_��ƷDYD_ʱ��_ʱ��_����
%  Wind_W10DYD_0_2012112108_D0
%  MFILE:   NetCDFtoImageDYD.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
%  importFile = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\nmefc_wrf_2013012108.nc';
%  outputDir = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\';
%  timeInterval = 12;

global Dimensions L_range B_range Time_interval VectorPicSize yesterday outputDirectory
% �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�ʱ��
Dimensions = [251,251,6,121];
%ʸ��ͼ�γ�ͼ��С�������㣩
VectorPicSize = [547,255];
% ����ͼ���ʱ����������Դ����6Сʱ���������Ҫ��6�ı���
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
% NC�ļ�����ͼƬ���˸���ɫͼ
function [ output_args ] = NCtoImage( input_args )
global Dimensions Time_interval yesterday VectorPicSize L_range B_range L_matrixDYD B_matrixDYD outputDirectory
try
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    %% W10 �����
    ncid = netcdf.open( input_args, 'NC_NOWRITE' );% ���ļ�
    start=[0,0,0]; % ���λ�� [0,0,0]
    count=[Dimensions(1),Dimensions(2),Dimensions(4)]; % ������ ���ȣ�γ�ȣ�ʱ��
    vidU=netcdf.inqVarID(ncid,'U10'); % ��ȡU��������ID
    vidV=netcdf.inqVarID(ncid,'V10'); % ��ȡV��������ID
    ecU=netcdf.getVar(ncid,vidU,start,count); % ��ȡU����
    ecV=netcdf.getVar(ncid,vidV,start,count); % ��ȡV����
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %��ͼ�㣬3-5����
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    cla;
    i=0;
    while i<Dimensions(4)
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D0'];
        SaveImage([outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %������ͼ��
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% ������ʱ����ת90��
        ec0V=flipud(ecV(:,:,i+1)');% ������ʱ����ת90��
        ec0U(ec0U(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec0V(ec0V(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*20+1,2*10+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%����Ĵ�С��Ϊ�ȼ�
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D6'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %���߼�ͼ��
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% ������ʱ����ת90��
        ec0V=flipud(ecV(:,:,i+1)');% ������ʱ����ת90��
        ec0U(ec0U(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec0V(ec0V(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*40+1,2*20+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%����Ĵ�С��Ϊ�ȼ�
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D7'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %�ڰ˼�ͼ��
    set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(4)
        ec0U=flipud(ecU(:,:,i+1)');% ������ʱ����ת90��
        ec0V=flipud(ecV(:,:,i+1)');% ������ʱ����ת90��
        ec0U(ec0U(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec0V(ec0V(:,:)==-9999)=nan;% ��-9999��Ϊnan
        ec=sqrt(ec0U.^2+ec0V.^2);
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*80+1,2*40+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        ec=windLevel(ec);%����Ĵ�С��Ϊ�ȼ�
        name=['Wind_W10DYD_',num2str(i), '_',yesterday,'_D8'];
        DrawW10(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec0U ec0V;
    end
    
    output_args = 1;
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
netcdf.close(ncid);
end

%% DrawW10
%����ɫͼ
function [] = DrawW10( eci,name )
global L_matrixDYD
hold off;
datagrid(eci,0,6);% ������ͼ
set(gca,'XLim',[1 size(L_matrixDYD,2)],'YLim',[1 size(L_matrixDYD,1)]);%�������귶Χdatagrid������ı����귶Χ
SaveImage(name);%����ͼƬ
end

%% windLevel
%����ɫͼ
function [ec] = windLevel( ec )
ec(ec<3)=1;
ec(ec>=3&ec<5)=2;
ec(ec>=5&ec<7)=3;
ec(ec>=7&ec<9)=4;
ec(ec>=9&ec<11)=5;
ec(ec>=11&ec<13)=6;
ec(ec>=13&ec<15)=7;
ec(ec>=15&ec<17)=8;
ec(ec>=17)=9;
end

%% SaveImage
%����ͼƬ,input_argsΪͼ����
function [  ] = SaveImage( input_args )
global outputDirectory yesterday
axis off;% �ر�������
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[ outputDirectory,yesterday,'\default.png']);% ���ͼƬ
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
global Dimensions  outputDirectory yesterday
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
%set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 250 250]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);%get(0,'ScreenPixelsPerInch')

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%����ɫ�����췽ʽ
colormap(jet(256));
if(exist([outputDirectory,yesterday],'dir')~=7)
    mkdir([outputDirectory,yesterday]);% �ڵ�ǰ�ļ������½�img�ļ��У�����Ѵ��ڻ�warning����Ӱ������
end
end