function [ output_args ] = DATtoImageDYD( importFile,outputDir,timeInterval )
%  ��ȡDAT��ʽ��ֵԤ����Ʒ����������ת�����ڲ壬������ɵ��㵺��������ͼƬ
%  importFileΪ�����ļ�
%  outputDirΪ����ļ���
%  output_args����1Ϊ�������У�0Ϊ����
%  ��ͼ���ݸ�ʽ��
%  Wave_��ƷDYD_ʱ��_ʱ��_����
%  Wave_HSDYD_0_20121121_D0
%  MFILE:   DATtoImage.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
% importFile = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\hsjinhai620130121.dat';%hsjinhai620121121
% outputDir = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\';
% timeInterval = 12;

global Dimensions L_range B_range Time_interval VectorPicSize yesterday outputDirectory
% �ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�ʱ��
Dimensions = [751,1201,121];
%ʸ��ͼ�γ�ͼ��С�������㣩
VectorPicSize = [547,255];
% ����ͼ���ʱ����������Դ����6Сʱ���������Ҫ��6�ı���
Time_interval = timeInterval;
% ��ȡ�ļ����е����ڣ�����
[~, name, ~] = fileparts(importFile);
yesterday=name(end-7:end);
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
outputDirectory=outputDir;
% wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
L_range = linspace(105,130,Dimensions(1));
B_range = linspace(45,5,Dimensions(2));
%% main do
try
    % �жϴ�����ļ�����
    if(size(strfind(name,'hsjinhai'),1) == 1)
        output_args = HStoImage(importFile);
    end
catch ME
    output_args = strcat(ME.stack.line,'*',ME.identifier,'*',ME.message);
end
end

%% HStoImage
% HS�ļ�����ͼƬ���˸���ɫͼ
function [ output_args ] = HStoImage( input_args )
global Dimensions Time_interval yesterday VectorPicSize L_range B_range L_matrixDYD B_matrixDYD outputDirectory
try
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    %fid = fopen(input_args, 'r');% ���ļ�
    dat = load(input_args);% ���ļ�
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %��ͼ�㣬3-5����
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    cla;
    i=0;
    while i<Dimensions(3)
        name=['Wave_HSDYD_',num2str(i), '_',yesterday,'_D0'];
        SaveImage([outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %��6��ͼ��
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        ec(ec(:,:)==-9)=nan;% ��-9999��Ϊnan
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*20+1,2*10+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');

        name=['Wave_HSDYD_',num2str(i), '_',yesterday,'_D6'];
        DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %��7��ͼ��
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        ec(ec(:,:)==-9)=nan;% ��-9999��Ϊnan
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*40+1,2*20+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        
        name=['Wave_HSDYD_',num2str(i), '_',yesterday,'_D7'];
        DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %��8��ͼ��
    set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    hold off;
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        ec(ec(:,:)==-9)=nan;% ��-9999��Ϊnan
        % �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        DimensionsDYD = [2*80+1,2*40+1,121];
        L_rangeDYD = linspace(118,130,DimensionsDYD(1));
        B_rangeDYD = linspace(29,24,DimensionsDYD(2));
        % �����ֵ������Ҫ����ľ�γ�Ⱦ������
        [L_matrixDYD B_matrixDYD] = GeographicToMercatorToGeographic(L_rangeDYD,B_rangeDYD);
        ec=interp2(L_range,B_range,ec,L_matrixDYD,B_matrixDYD,'linear');
        
        name=['Wave_HSDYD_',num2str(i), '_',yesterday,'_D8'];
        DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        i=i+Time_interval;
        clear ec;
    end
    output_args = 1;
catch ME
    output_args = strcat(ME.stack.line,'*',ME.identifier,'*',ME.message);
end
clear dat;
end

%% DrawHS
%����ɫͼ
function [] = DrawHS( eci,name )
global L_matrixDYD
hold off;
datagrid(eci,1,3);% ������ͼ
set(gca,'XLim',[1 size(L_matrixDYD,2)],'YLim',[1 size(L_matrixDYD,1)]);%�������귶Χdatagrid������ı����귶Χ
SaveImage(name);%����ͼƬ
end


%% SaveImage
%����ͼƬ,input_argsΪͼ����
function [ ] = SaveImage( input_args )
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
function [ ] = SetImageLayout( )
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